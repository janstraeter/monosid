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
.segment Data [startAfter="MainProgram"]
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

#import "src/strings.asm"
#import "src/globals.asm"

// *******************************************************************
.segment Subroutines [start=$80d]
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
#import "src/userinterface.asm"
#import "src/input.asm"
#import "src/sid.asm"
#import "src/midi.asm"

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
    // Draw the UI in it's inital state
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus

    // initialize the SID chip with the initial state of the UI
    jsr sidUpdateAllRegisters

    // setup the raster interrup which plays the sounds
    // jsr setupRasterInterrupt

    jsr setupCustomInterruptServiceRoutine

    // initialize the MIDI interface (if any is present)
    // jsr midiInit

waitLoop:
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

    // Update the SID chip
    jsr playCurrentNote

	// Switch for the current program mode
	lda currentMode
	cmp #MODE.MAIN
	beq modeMain
	cmp #MODE.MENU
	beq modeMain
    jmp waitLoop

modeMain:
	// Switch for the current program mode sub mode
	lda currentSubMode
	cmp #MODE_MAIN_SUBMODE.SELECT_INPUT
	beq subModeMainSelectInput
	cmp #MODE_MAIN_SUBMODE.INPUT_EDITOR
	beq subModeMainInputEditor
    jmp waitLoop

subModeMainSelectInput:
    // check for pressed keys, play notes or move the focus of the currently selected module/input
    jsr updateCurrentKeyboardPianoOctave
    jsr updateCurrentNote
    jsr mainModeHandleKeyboardInputForSubModeSelectInput
    jmp waitLoop

subModeMainInputEditor:
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
 * Subroutine
 * ----------
 *
 * The actual RSI, for explaination see above.
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
    
    // load the registers from the stack and return
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
 * Sets up the raster interrupt
 *
 * ---------------------------------------------------------------- */ 

/*setupRasterInterrupt:
{
    sei

    lda #<rasterInterrupRoutine
    sta INTERRUPT_VECTOR_LO
    lda #>rasterInterrupRoutine
    sta INTERRUPT_VECTOR_HI

    lda #$00
    sta VIC.RASTER_COUNTER             

    lda VIC.CONTROL_REGISTER_1
    and #%01111111
    sta VIC.CONTROL_REGISTER_1

    lda VIC.INTERRUPT_ENABLED
    ora #%00000001
    sta VIC.INTERRUPT_ENABLED

    cli
    rts
}*/


/* -------------------------------------------------------------------
 * Interrupt routine
 * -----------------
 *
 * Raster interrupt routine to play the currently selected note
 *
 * Reads global variables:  currentNote, noteChange
 *
 * Writes global variables: currentNote, noteChange
 *
 * ---------------------------------------------------------------- */ 

/*rasterInterrupRoutine:
{    
    lda VIC.INTERRUPT_REGISTER
    bmi doRasterIrq
    // and #%10000001
    // cmp #%10000001
    // beq doRasterIrq

    lda CIA.INTERRUPT_CONTROL_STATE
    cli
    jmp KERNAL.INTERRUPT_ROUTINE

doRasterIrq:

    // lda VIC.INTERRUPT_REGISTER
    sta VIC.INTERRUPT_REGISTER

    // Save ZPR_1 on stack, because the interrupt subroutines use it
    lda ZPR_1_LO
    pha
    lda ZPR_1_HI
    pha
    
    // Call the subroutines
    jsr playCurrentNote

    // Restore ZPR_1 from stack
    pla
    sta ZPR_1_HI
    pla
    sta ZPR_1_LO
 
exit:
    pla
    tay
    pla
    tax
    pla
    rti
}*/


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

updateCurrentNote:
{
    lda currentPressedKey
    cmp #64
    beq notFound

    loadPointerToZPR(keyboardPianoKeyCodes, ZPR_1)
    ldy #$00

arrayLoop:
    lda (ZPR_1), y
    cmp currentPressedKey
    beq found
    iny
    cpy #$0D
    bne arrayLoop
    jmp notFound

found:
    sty tempCurrentNote
    tya
    clc
    adc currentKeyboardPianoNoteOffset
    sta tempCurrentNote

    cmp maxFreqTableNum
    bcs notFound

    jmp checkForNoteChange

notFound:
    lda #$FF
    sta tempCurrentNote

checkForNoteChange:
    lda currentNote
    cmp tempCurrentNote
    beq noteHasNotChanged

    lda currentNote
    sta previousNote
    lda tempCurrentNote
    sta currentNote

    cmp #$FF
    beq doNotSubstractNoteOffset
    sec
    sbc currentKeyboardPianoNoteOffset

doNotSubstractNoteOffset:
    sta currentNoteOfOctave

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
 * Plays the current note via the SID chip
 *
 * Parameters:   None
 * Return value: None
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

    jsr sidUpdateVoicesForCurrentNote
    jsr userinterfaceOutputCurrentNote

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
 * prints the value of the accu register at the top left corner of
 * the screen
 *
 * ---------------------------------------------------------------- */ 

debugDumpByte:
{
    sta byteValue

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
    sta ZPR_2_HI
    pla
    sta ZPR_2_LO
    pla
    sta ZPR_1_HI
    pla
    sta ZPR_1_LO
    pla
    sta ZPR_0

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
