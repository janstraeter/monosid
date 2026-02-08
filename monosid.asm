/* -------------------------------------------------------------------
 *
 * monosid
 * -------
 *
 * A litte software mono-synth for the good old C64
 *
 * ---------------------------------------------------------------- */ 

.file [name="monosid.prg", segments="Start, Data, Subroutines, MainProgram"]


// *******************************************************************
.segment Start [start=$801, modify="BasicUpstart", _start=mainProgram]
// *******************************************************************


// *******************************************************************
.segment Data [start=$80e]
// *******************************************************************


/* -------------------------------------------------------------------
 *
 * Constants, ZP registers, memory functions and structs
 *
 * ---------------------------------------------------------------- */ 

#import "src/constants.asm"
#import "src/zpregisters.asm"
#import "src/screenmemoryfunctions.asm"
#import "src/structs.asm"


/* -------------------------------------------------------------------
 *
 * Strings and global variables
 *
 * ---------------------------------------------------------------- */ 

#import "src/spritedata.asm"
#import "src/strings.asm"
#import "src/lookuptables.asm"
#import "src/globals.asm"


// *******************************************************************
.segment Subroutines [startAfter="Data"]
// *******************************************************************


/* -------------------------------------------------------------------
 *
 * Subroutines
 *
 * ---------------------------------------------------------------- */ 

#import "src/string.asm"
#import "src/math.asm"
#import "src/convert.asm"
#import "src/screen.asm"
#import "src/sprites.asm"
#import "src/logo.asm"
#import "src/userinterface.asm"
#import "src/input.asm"
#import "src/sid.asm"
#import "src/midi.asm"
#import "src/pitch.asm"
#import "src/pulsewidth.asm"
#import "src/filter.asm"


// *******************************************************************
.segment MainProgram [startAfter="Subroutines"]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Main program
 *
 * ---------------------------------------------------------------- */ 

mainProgram:
{
    // Setup logo sprites, but do not show yet
    jsr logoSetupSprites

    // Draw the UI in it's inital state
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus

    // initialize the SID chip with the initial state of the UI
    jsr sidUpdateAllRegisters

    // initialize a custom ISR for the Kernal functionality
    jsr setupCustomInterruptServiceRoutine

    // initialize the MIDI interface (if any is present)
    jsr midiInit

waitLoop:
    // check if the CIA interrupt called our custom ISR,
    // if so, call the emulation of the default Kernal ISR
    // so the Kernal routines can work properly
    lda callEmulationOfKernalISR
    cmp #0
    beq doNotCallEmulationOfKernalISR
    lda #0
    sta callEmulationOfKernalISR
    jsr emulateStandardKernalISR

doNotCallEmulationOfKernalISR:
    // read the current pressed key and save it in a global variable
    lda ZP.CURRENT_PRESSED_KEY
    sta currentPressedKey

    // check if the last note was played not by MIDI but the C64 keyboard
    // instead. If so ignore the MIDI notes in this loop iteration
    lda currentNoteWasPlayedByKeyboardFlag
    bne ignoreMidiNote
    
    // update the current note according to the currently active MIDI notes
    jsr midiUpdateCurrentNote

ignoreMidiNote:

    // Update the SID chip
    jsr updateVoiceFrequenciesIfNecessary
    jsr pulseWidthUpdateModulatedValuesIfNeccessary
    jsr playCurrentNote

	// Switch for the current program mode
	lda currentMode
	cmp #MODE.MAIN
	beq modeMain
	cmp #MODE.MENU
	beq modeMain
    jmp waitLoop

modeMain:
    //lda SID.ENVELOPE_VOICE_3
    // jsr debugDumpByte
	// Switch for the current program mode sub mode
	lda currentSubMode
	cmp #MODE_MAIN_SUBMODE.SELECT_INPUT
	beq subModeMainSelectInput
	cmp #MODE_MAIN_SUBMODE.INPUT_EDITOR
	beq subModeMainInputEditor
    jmp waitLoop

subModeMainSelectInput:
    // check for pressed keys,
    // play notes or move the focus of the currently selected module/input
    jsr updateCurrentKeyboardPianoOctave
    jsr updateCurrentKeyboardNote
    jsr mainModeHandleKeyboardInputForSubModeSelectInput
    jmp waitLoop

subModeMainInputEditor:
    // check for pressed keys, update content of editor,
    // remove editor and update value if return key pressed
    jsr inputHandleKeyboardInputForEditor
    jmp waitLoop

modeMenu:
    //** @TODO: Implement menu */
    jmp waitLoop
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up the custom ISR. Because the C64 is so slow, we need
 * a very, very fast interrupt routine. Almost everything must be
 * done in the main loop, only reading the MIDI input can be
 * done via interrupt. But we need a machanism to get the timing
 * for the jiffy clock, cursor blinking and keyboard reading right.
 * So we setup a custom RSI - this RSI is called 60 times per second,
 * as setup by the Kernal. This custom RSI only indicates to the
 * main loop, that the usual Kernal stuff is due - but does not do the
 * actual updating in the ISR itself. 
 *
 * ---------------------------------------------------------------- */ 

setupCustomInterruptServiceRoutine:
{
    // if an interrup would occur while we are not finished
    // changing the vector (4 instructions)
    // the computer would freeze, not likely but possible
    sei

    // set the interrupt vector to our custom ISR
    lda #<customInterruptServiceRoutine
    sta INTERRUPT_VECTOR_LO
    lda #>customInterruptServiceRoutine
    sta INTERRUPT_VECTOR_HI

    // now interrupts are allowed again
    cli

    rts
}


/* -------------------------------------------------------------------
 * Interrupt Service Routine
 * -------------------------
 *
 * The actual ISR, for explaination see above.
 *
 * ---------------------------------------------------------------- */ 

customInterruptServiceRoutine:
{
    // acknowledge the interrupt
    lda CIA.INTERRUPT_CONTROL_STATE
    
    // set the variable to 1, to indicate the main loop
    // to call the Kernal ISR emulation
    lda #1
    sta callEmulationOfKernalISR
    
    // restore the registers from the stack and return
    pla
    tay
    pla
    tax
    pla
    rti
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * This routine is an adaption of the disassembly of the
 * original ISR of the C64 Kernal.
 *
 * See: http://www.unusedino.de/ec64/technical/misc/c64/romlisting.html#kernal
 *
 * It is called from the main loop, whenever the custom ISR indicates
 * that it is time (60 times per second).
 *
 * It returns via RTS, not RTI as in the original, of course.
 *
 * ---------------------------------------------------------------- */ 

emulateStandardKernalISR:
{
    jsr $FFEA           // do clock
    lda $CC             // flash cursor
    bne Kernal_EA61
    dec $CD
    bne Kernal_EA61
    lda #$14
    sta $CD
    ldy $D3
    lsr $CF
    ldx $0287
    lda ($D1),Y
    bcs Kernal_EA5C
    inc $CF
    sta $CE
    jsr $EA24
    lda ($F3),Y
    sta $0287
    ldx $0286
    lda $CE
Kernal_EA5C:
    eor #$80
    jsr $EA1C           // display cursor
Kernal_EA61:
    lda $01             // checl cassette sense
    and #$10
    beq Kernal_EA71
    ldy #$00
    sty $C0
    lda $01
    ora #$20
    bne Kernal_EA79
Kernal_EA71:
    lda $C0
    bne Kernal_EA7B
    lda $01
    and #$1F
Kernal_EA79:    
    sta $01
Kernal_EA7B:
    jsr $EA87           // scan keyboard

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the current pressed key is one of the keys 1-8.
 * If it is, sets the current keyboard piano octave accordingly.
 *
 * Reads global variables:  currentPressedKey, keyboardPianoOctaveKeyCodes,
 *                          keyboardPianoOctaveOffsets
 *
 * Writes global variables: currentKeyboardPianoOctave,
 *                          currentKeyboardPianoNoteOffset
 *
 * ---------------------------------------------------------------- */ 

updateCurrentKeyboardPianoOctave:
{
    lda currentPressedKey
    cmp #64
    beq notFound

    loadPointerToZPR(keyboardPianoOctaveKeyCodes, ZPR_1)
    ldy #$00

arrayLoop:
    lda (ZPR_1), y
    cmp currentPressedKey
    beq found
    iny
    cpy #$08
    bne arrayLoop
    jmp notFound

found:
    sty currentKeyboardPianoOctave
    loadPointerToZPR(keyboardPianoOctaveOffsets, ZPR_1)
    lda (ZPR_1), y
    sta currentKeyboardPianoNoteOffset

    jsr userInterfaceOutputCurrentKeyboardPianoOctave

notFound:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Interprets the currently pressed key as a note
 *
 * Reads global variables:  keyboardPianoKeyCodes, currentPressedKey,
 *                          keyboardPianoKeyCodes, currentKeyboardPianoNoteOffset,
 *                          maxFreqTableNum
 *
 * Writes global variables: currentNote, noteChange, currentNoteOfOctave
 *
 * ---------------------------------------------------------------- */ 

updateCurrentKeyboardNote:
{
    // load the current pressed key and check if the value is not 64 (which means no key pressed)
    lda currentPressedKey
    cmp #64
    beq notFound

    // load the pointer to the key codes which are used as a piano octave
    loadPointerToZPR(keyboardPianoKeyCodes, ZPR_1)
    ldy #$00

arrayLoop:
    // check if current array item corresponds to the value of the pressed key
    // if yes, jump to to the found label
    lda (ZPR_1), y
    cmp currentPressedKey
    beq found
    
    // goto next key code in array,
    iny

    // Check if last item in array is reached.
    // If no, loop again. If yes, jump to not found label
    cpy #$0D
    bne arrayLoop
    jmp notFound

found:
    // store the index of the found key code in tempCurrentNote
    sty tempCurrentNote
    
    // add the value in currentKeyboardPianoNoteOffset to tempCurrentNote
    tya
    clc
    adc currentKeyboardPianoNoteOffset
    sta tempCurrentNote

    // check if resulting note value is greater than highest playable note
    cmp #$60
    bcs notFound

    // set the flag to indicate the main loop that the note was
    // played on the C64 keyboard and should override any note from MIDI
    lda #1
    sta currentNoteWasPlayedByKeyboardFlag

    // now check if note as changed
    jmp checkForNoteChange

notFound:
    
    // check if the last note was played by the C64 keyboard
    // if no, then ignore the fact that no note was found.
    // Otherwise we would falsly assume that the currently played note should be ended
    lda currentNoteWasPlayedByKeyboardFlag
    cmp #0
    beq noteHasNotChanged

    // reset the flag, the C64 keyboard now does not play a note anymore
    lda #0
    sta currentNoteWasPlayedByKeyboardFlag

    // note was not found, so save 255 into tempCurrentNote
    lda #$FF
    sta tempCurrentNote

checkForNoteChange:
    // load current note and compare it with the new note
    lda currentNote
    cmp tempCurrentNote
    beq noteHasNotChanged

    // note has changed, store the new note as the current
    // (and last played) and the current as the previous
    lda currentNote
    sta previousNote
    lda tempCurrentNote
    sta currentNote

    // update lastPlayedNote, but only if there is an actual note to play
    cmp #$FF
    beq doNotUpdateLastPlayedNote
    sta lastPlayedNote

doNotUpdateLastPlayedNote:
    // set the flag to indicate that the note has changed
    lda #$01
    sta noteHasChangedFlag
    rts

noteHasNotChanged:
    rts

    // Local variables
    tempCurrentNote: .byte($ff)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the voice frequencies need to be calculated and
 * the frequency registers of the SID chip have to be updated.
 *
 * Reads global variables:  currentNote, noteHasChangedFlag,
 *                          midiPitchBendValueChangedFlag

 * Writes global variables: midiPitchBendValueChangedFlag
 *
 * ---------------------------------------------------------------- */ 

updateVoiceFrequenciesIfNecessary:
{
    // first check if the pitch bend wheel was moved,
    // if yes, update frequencies and set the pitch bend value change flag to zero
    lda midiPitchBendValueChangedFlag
    bne pitchBendValueHasChanged

    // if the pitch bend wheel was not moved check if the currently played note has changed
    // and the new note is a playable note (and not 255 indicating "no note")
    // if either of this checks is false, note frequency update is neccessary
    lda noteHasChangedFlag
    beq frequenciesHaveNotChanged
    lda currentNote
    cmp #$FF
    beq frequenciesHaveNotChanged

    // note has changed and is not a playable note, update the voice frequencies
    jmp updateFrequencies

pitchBendValueHasChanged:
    // set the MIDI pitch bend value has changed flag to zero again
    lda #0
    sta midiPitchBendValueChangedFlag

updateFrequencies:
    // calculate the (possibly detuned) frequencies for all voices and update the SID chip
    jsr pitchCalculateAllVoiceFrequencies
    jsr sidUpdateVoiceFrequencies

frequenciesHaveNotChanged:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Plays the current note via the SID chip
 *
 * Reads global variables:  currentNote, noteHasChangedFlag
 * Writes global variables: noteHasChangedFlag
 *
 * ---------------------------------------------------------------- */ 

playCurrentNote:
{
    lda noteHasChangedFlag
    cmp #$01
    bne exit

    jsr sidUpdateGateBitsForAllVoices

    lda #$00
    sta noteHasChangedFlag

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the keyboard input while the program is in main mode,
 * submode select input.
 * 
 * Checks if the currently selected module/input element
 * should be updated and if so updates the corresponding global
 * variables accordingly, then updates the user interface.
 *
 * Reads global variables:  currentModuleIndex, currentInputIndex,
 *                          modules, moduleNum
 *
 * Writes global variables: currentModuleIndex, currentInputIndex
 *
 * ---------------------------------------------------------------- */ 

mainModeHandleKeyboardInputForSubModeSelectInput:
{
    // Read pressed keycode, if no key pressed, exit
    jsr KERNAL.GETIN
    cmp #$00
    beq exit

	// Switch for the handled keys.
    // Because the subroutine is rather long, use a little trick to avoid the
    // problems with branching instructions on the 6502, which only can jump -127/+127 bytes.
    // see here: https://www.lemon64.com/forum/viewtopic.php?t=81358
    cmp #PETSCII.CURSOR_DOWN
	bne *+5
    jmp cursorDownKeyPressed
	cmp #PETSCII.CURSOR_RIGHT
	bne *+5
    jmp cursorRightKeyPressed
	cmp #PETSCII.CURSOR_UP
	bne *+5
    jmp cursorUpKeyPressed
	cmp #PETSCII.CURSOR_LEFT
	bne *+5
    jmp cursorLeftKeyPressed
	cmp #PETSCII.RETURN
	bne *+5
    jmp returnKeyPressed
	cmp #PETSCII.SPACE
	bne *+5
    jmp spaceKeyPressed
	cmp #PETSCII.PLUS
	bne *+5
    jmp plusKeyPressed
	cmp #PETSCII.MINUS
	bne *+5
    jmp minusKeyPressed

    // If no key pressed we can handle here, exit
exit:
    rts

cursorDownKeyPressed:
    // Cursor down: increase current module index,
    // wrap around if number of modules is reached
    jsr userinterfaceRemoveModuleFocus
    jsr userinterfaceRemoveInputFocus
    inc currentModuleIndex
    lda currentModuleIndex
    cmp modulesNum
    bne cursorDownNoWrap
    lda #$00
    sta currentModuleIndex

cursorDownNoWrap:
    jsr correctCurrentInputIndex
    jsr switchPageIfNeccessary
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus
    rts

cursorRightKeyPressed:
    // Cursor right: increase current input index,
    // wrap around if current module´s input number is reached
    jsr userinterfaceRemoveInputFocus
    jsr loadCurrentModuleInputNumToAccu
    sta currentModuleInputNum
    inc currentInputIndex
    lda currentInputIndex
    cmp currentModuleInputNum
    bne cursorRightNoWrap
    lda #$00
    sta currentInputIndex

cursorRightNoWrap:
    jsr userinterfaceAddInputFocus
    rts

cursorUpKeyPressed:
    // Cursor up: decrease current module index,
    // wrap around if below zero is reached
    jsr userinterfaceRemoveModuleFocus
    jsr userinterfaceRemoveInputFocus
    dec currentModuleIndex
    bpl cursorUpNoWrap
    lda modulesNum
    sec
    sbc #1
    sta currentModuleIndex

cursorUpNoWrap:
    jsr correctCurrentInputIndex
    jsr switchPageIfNeccessary
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus
    rts

cursorLeftKeyPressed:
    // Cursor left: decrease current input index,
    // wrap around if below zero is reached
    jsr userinterfaceRemoveInputFocus
    jsr loadCurrentModuleInputNumToAccu
    sta currentModuleInputNum
    dec currentInputIndex
    bpl cursorLeftNoWrap
    lda currentModuleInputNum
    sec
    sbc #1
    sta currentInputIndex

cursorLeftNoWrap:
    jsr userinterfaceAddInputFocus
    rts

returnKeyPressed:
    // for number input fields: start the editor mode
    // for waveform inputs: switch to next waveform
    // for boolean inputs: toggle
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleReturnKeyPressed
    rts

spaceKeyPressed:
    // for waveform inputs: switch to next waveform
    // for boolean inputs: toggle
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleSpaceKeyPressed
    rts

plusKeyPressed:
    // for number input fields: increase value by 1 (if max value is not reached)
    // for waveform inputs: switch to next waveform
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandlePlusKeyPressed
    rts

minusKeyPressed:
    // for number input fields: decrease value by 1 (if greater than zero)
    // for waveform inputs: switch to previous waveform
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleMinusKeyPressed
    rts

currentModuleInputNum:
	.byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Loads the number of input elements of the currently selected module
 * into the accu register
 *
 * Reads global variables:  modules, currentModuleIndex
 * Writes global variables: none
 * 
 * ---------------------------------------------------------------- */ 

loadCurrentModuleInputNumToAccu:
{
	loadPointerToZPR(modules, ZPR_6)
    stuctLoadPointerArrayItemToZPR(ZPR_6, currentModuleIndex, ZPR_7);
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INPUT_ARRAY_NUM)
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the current input index is bigger than the max
 * input index of the current module and sets it to the max
 * value if neccessary
 *
 * Reads global variables:  modules, currentModuleIndex, currentInputIndex
 * Writes global variables: none
 * 
 * ---------------------------------------------------------------- */ 

correctCurrentInputIndex:
{
    jsr loadCurrentModuleInputNumToAccu
    sta inputNum
    lda currentInputIndex
    cmp inputNum
    bcc exit

    lda inputNum
    sec
    sbc #1
    sta currentInputIndex

exit:
    rts

inputNum:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the newly selected input should be displayed on a different
 * page and switches to this page if neccessary.
 *
 * Reads global variables:  modules, currentModuleIndex
 * Writes global variables: currentPage
 * 
 * ---------------------------------------------------------------- */ 

switchPageIfNeccessary:
{
	// load the designated page for the current module
    loadPointerToZPR(modules, ZPR_6)
    stuctLoadPointerArrayItemToZPR(ZPR_6, currentModuleIndex, ZPR_7);
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.PAGE)
    
    // check if it matches the current page
    cmp currentPage
    beq exit

    // no, set the new page and redraw the UI
    sta currentPage
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain

    // if second page, show the logo, otherwise hide the logo
    lda #1
    cmp currentPage
    bne hideLogo
    jsr logoShow
    rts

hideLogo:
    jsr logoHide

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * prints the value of the accu register at the top left corner of
 * the screen
 *
 * ---------------------------------------------------------------- */ 

debugDumpByte:
{
    sta byteValue
    pha
    txa
    pha
    tya
    pha
    lda ZPR_0
    pha
    lda ZPR_1_LO
    pha
    lda ZPR_1_HI
    pha
    lda ZPR_2_LO
    pha
    lda ZPR_2_HI
    pha
    lda ZPR_3_LO
    pha
    lda ZPR_3_HI
    pha
    lda ZPR_4_LO
    pha
    lda ZPR_4_HI
    pha
    lda ZPR_5_LO
    pha
    lda ZPR_5_HI
    pha

    lda byteValue
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI

    loadPointerToZPR(stringBuffer, ZPR_2)
    
    lda #$30
    sta ZPR_0
    
    jsr convertIntegerToString

    screenPutCharColor(0, 0, $20, WHITE)
    screenPutCharColor(1, 0, $20, WHITE)
    screenPutCharColor(2, 0, $20, WHITE)

    screenPutString(0, 0, stringBuffer)

    pla
    sta ZPR_5_HI
    pla
    sta ZPR_5_LO
    pla
    sta ZPR_4_HI
    pla
    sta ZPR_4_LO
    pla
    sta ZPR_3_HI
    pla
    sta ZPR_3_LO
    pla
    sta ZPR_2_HI
    pla
    sta ZPR_2_LO
    pla
    sta ZPR_1_HI
    pla
    sta ZPR_1_LO
    pla
    sta ZPR_0
    pla
    tay
    pla
    tax
    pla

    rts

stringBuffer:
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
byteValue:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * prints the value of the X/Y register at the top left corner of
 * the screen
 *
 * ---------------------------------------------------------------- */ 

debugDumpWord:
{
    pha
    
    txa
    sta wordValue
    tya
    sta wordValue+1

    lda ZPR_0
    pha
    lda ZPR_1_LO
    pha
    lda ZPR_1_HI
    pha
    lda ZPR_2_LO
    pha
    lda ZPR_2_HI
    pha
    lda ZPR_3_LO
    pha
    lda ZPR_3_HI
    pha
    lda ZPR_4_LO
    pha
    lda ZPR_4_HI
    pha
    lda ZPR_5_LO
    pha
    lda ZPR_5_HI
    pha

    lda wordValue
    sta ZPR_1_LO
    lda wordValue+1
    sta ZPR_1_HI

    loadPointerToZPR(stringBuffer, ZPR_2)
    
    lda #$30
    sta ZPR_0
    
    jsr convertIntegerToString

    screenPutCharColor(0, 0, $20, WHITE)
    screenPutCharColor(1, 0, $20, WHITE)
    screenPutCharColor(2, 0, $20, WHITE)
    screenPutCharColor(3, 0, $20, WHITE)
    screenPutCharColor(4, 0, $20, WHITE)

    screenPutString(0, 0, stringBuffer)

    pla
    sta ZPR_5_HI
    pla
    sta ZPR_5_LO
    pla
    sta ZPR_4_HI
    pla
    sta ZPR_4_LO
    pla
    sta ZPR_3_HI
    pla
    sta ZPR_3_LO
    pla
    sta ZPR_2_HI
    pla
    sta ZPR_2_LO
    pla
    sta ZPR_1_HI
    pla
    sta ZPR_1_LO
    pla
    sta ZPR_0
    pla

    rts

stringBuffer:
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
wordValue:
    .byte(0)
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * prints the value of the accu register at the top left corner of
 * the screen
 *
 * ---------------------------------------------------------------- */ 

debugDumpNoteBuffer:
{
    pha
    lda ZPR_0
    pha
    lda ZPR_1_LO
    pha
    lda ZPR_1_HI
    pha
    lda ZPR_2_LO
    pha
    lda ZPR_2_HI
    pha
    
    lda #$30
    sta ZPR_0
    lda midiActiveNotesBuffer
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    jsr convertIntegerToString
    screenPutCharColor(0, 1, $20, WHITE)
    screenPutCharColor(1, 1, $20, WHITE)
    screenPutCharColor(2, 1, $20, WHITE)
    screenPutString(0, 1, stringBuffer)

    lda #$30
    sta ZPR_0    
    lda midiActiveNotesBuffer+1
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    jsr convertIntegerToString
    screenPutCharColor(3, 1, $20, WHITE)
    screenPutCharColor(4, 1, $20, WHITE)
    screenPutCharColor(5, 1, $20, WHITE)
    screenPutString(3, 1, stringBuffer)

    lda #$30
    sta ZPR_0    
    lda midiActiveNotesBuffer+2
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    jsr convertIntegerToString
    screenPutCharColor(6, 1, $20, WHITE)
    screenPutCharColor(7, 1, $20, WHITE)
    screenPutCharColor(8, 1, $20, WHITE)
    screenPutString(6, 1, stringBuffer)

    lda #$30
    sta ZPR_0    
    lda midiActiveNotesBuffer+3
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    jsr convertIntegerToString
    screenPutCharColor(9, 1, $20, WHITE)
    screenPutCharColor(10, 1, $20, WHITE)
    screenPutCharColor(11, 1, $20, WHITE)
    screenPutString(9, 1, stringBuffer)

    lda #$30
    sta ZPR_0    
    lda midiActiveNotesBuffer+4
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    jsr convertIntegerToString
    screenPutCharColor(12, 1, $20, WHITE)
    screenPutCharColor(13, 1, $20, WHITE)
    screenPutCharColor(14, 1, $20, WHITE)
    screenPutString(12, 1, stringBuffer)


    pla
    sta ZPR_2_HI
    pla
    sta ZPR_2_LO
    pla
    sta ZPR_1_HI
    pla
    sta ZPR_1_LO
    pla
    sta ZPR_0
    pla

    rts

stringBuffer:
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
byteValue:
    .byte(0)
}
