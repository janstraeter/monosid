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
    
    // setup the raster interrup which plays the sounds
    jsr setupRasterInterrupt

waitLoop:
    // read the current pressed key and save it in a global variable
    lda ZP.CURRENT_PRESSED_KEY
    sta currentPressedKey

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
 * Sets up the raster interrupt
 *
 * ---------------------------------------------------------------- */ 

setupRasterInterrupt:
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
}


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

rasterInterrupRoutine:
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
 * Updates the control registers of the SID chip according to the 
 * settings
 *
 * Reads global variables:  currentNote, FreqTablePalLo, FreqTablePalHi
 *
 * ---------------------------------------------------------------- */ 

updateSid:
{
    // Volume volle Pulle
    lda #$0F
    sta SID.FILTER_MODE_MAIN_VOLUME

    // Aktuelle Note laden und testen, ob überhaupt etwas gespielt werde soll
    lda currentNote
    cmp #$FF
    bne playNote
    
    // Keine Note soll gespielt werden: Gate für Stimme 1 auf FALSE setzen
    lda #$10
    sta SID.VOICE_1_CONTROL_REGISTER
    jmp return

playNote:
    // Eine Note soll gespielt werden

    // lda #$10
    // sta SID.VOICE_1_CONTROL_REGISTER

    lda #$00
    sta SID.VOICE_1_ATTACK_DECAY

    lda #$FA
    sta SID.VOICE_1_SUSTAIN_RELEASE

    // Aktuelle Note laden und im Y-Register ablegen
    lda currentNote
    tay

    // LO Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    loadPointerToZPR(freqTablePalLo, ZPR_1)
    lda (ZPR_1), y
    sta SID.VOICE_1_FREQUENCY_LO

    // HI Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    loadPointerToZPR(freqTablePalHi, ZPR_1)
    lda (ZPR_1), y
    sta SID.VOICE_1_FREQUENCY_HI

    // Gate für Stimme 1 auf TRUE setzen und Waveform auf TRIANGLE
    lda #$11
    sta SID.VOICE_1_CONTROL_REGISTER

return:
    rts
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

    jsr updateSid
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
    // lda #0
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

    rts

stringBuffer:
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
}
