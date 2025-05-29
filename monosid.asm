/* -------------------------------------------------------------------
 *
 * monosid
 * -------
 *
 * A litte software mono-synth for the good old C64
 *
 * ---------------------------------------------------------------- */ 

.file [name="monosid.prg", segments="Data, Subroutines, MainProgram"]


// *******************************************************************
.segment Data [start=$80d]
// *******************************************************************


/* -------------------------------------------------------------------
 *
 * Constants and structs
 *
 * ---------------------------------------------------------------- */ 

#import "src/constants.asm"
#import "src/structs.asm"
#import "src/zpregisters.asm"

/* -------------------------------------------------------------------
 *
 * Global variables
 *
 * ---------------------------------------------------------------- */ 

#import "src/strings.asm"
#import "src/globals.asm"


// *******************************************************************
.segment Subroutines [startAfter="Data"]
// *******************************************************************


/* -------------------------------------------------------------------
 *
 * Subroutines
 *
 * ---------------------------------------------------------------- */ 

#import "src/math.asm"
#import "src/screen.asm"
#import "src/userinterface.asm"


// *******************************************************************
.segment MainProgram [startAfter="Subroutines", modify="BasicUpstart", _start=mainProgram]
// *******************************************************************


/* -------------------------------------------------------------------
 *
 * Main program
 *
 * ---------------------------------------------------------------- */ 

mainProgram:
{
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain
    jsr setupRasterInterrupt

waitLoop:
    lda ZP.CURRENT_PRESSED_KEY
    sta currentPressedKey

    jsr updateCurrentKeyboardPianoOctave
    jsr updateCurrentNote

    jmp waitLoop

quit:
//    jsr KERNAL.CLS
    rts
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
                            currentKeyboardPianoNoteOffset
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
 * Updated the control registers of the SID chip according to the 
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
