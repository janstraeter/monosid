/* -------------------------------------------------------------------
 *
 * monosid
 * -------
 *
 * A litte software mono-synth for the good old C64
 *
 * ---------------------------------------------------------------- */ 

.file [name="monosid.prg", segments="Code, Data"]

.segment Code [start=$801]


/* -------------------------------------------------------------------
 *
 * Main program
 *
 * ---------------------------------------------------------------- */ 

#import "src/constants.asm"

BasicUpstart2(mainProgram)

mainProgram:
{
    jsr setupRasterInterrupt

    lda #BLACK
    sta VIC.BORDERCOLOR
    sta VIC.BACKGROUND_COLOR_0
    lda #WHITE
    sta KERNAL.TEXTCOLOR
    jsr KERNAL.CLS
    ldx #$0

introloop:
    lda introtext,x
    beq charloop
    sta SCREENMEM,x
    inx
    jmp introloop

charloop:    
/*    jsr KERNAL.CHRIN
    cmp #$00
    beq charloop
    cmp #$103
    beq quit
    sec
    sbc #$40
    ldx #$00*/

waitLoop:
    lda ZEROPAGE.CURRENT_PRESSED_KEY
    sta currentPressedKey
    jmp waitLoop

/*screenloop:
    sta SCREENMEM, x
    sta SCREENMEM+255, x
    sta SCREENMEM+510, x
    sta SCREENMEM+744, x
    inx
    bne screenloop
    jmp charloop*/

quit:
    jsr KERNAL.CLS
    rts
}

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up the raster interrupt
 *
 * Parameters:   None
 * Return value: None     
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
 * Parameters:   None
 * Return value: None
 *
 * Reads global variables: currentNote, noteChange
 * Writes global varibles: currentNote, noteChange
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
    
    jsr updateCurrentNote
    jsr playCurrentNote

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
 * Interprets the currently pressed key as a note
 *
 * Parameters:   None
 * Return value: None
 *
 * Reads global variables: None
 * Writes global varibles: None
 *
 * ---------------------------------------------------------------- */ 

updateCurrentNote:
{
    lda #<keyboardPianoKeyCodes
    sta ZEROPAGE.TEMP_1_LO
    lda #>keyboardPianoKeyCodes
    sta ZEROPAGE.TEMP_1_HI
    ldy #$00

arrayLoop:
    lda (ZEROPAGE.TEMP_1), y
    cmp currentPressedKey
    beq found
    iny
    cpy #$0D
    bne arrayLoop
    jmp notFound

found:
    sty tempCurrentNote
    jmp checkForNotChange

notFound:
    lda #$FF
    sta tempCurrentNote
    jmp checkForNotChange

checkForNotChange:
    lda currentNote
    cmp tempCurrentNote
    beq noteHasNotChanged

noteHasChanged:
    lda currentNote
    sta previousNote
    lda tempCurrentNote
    sta currentNote
    lda #$01
    sta noteChange
    rts

noteHasNotChanged:
    lda #$00
    sta noteChange
    rts

tempCurrentNote:
    .byte($ff)
}

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updated the control registers of the SID chip according to the 
 * settings
 *
 * Parameters:   None
 * Return value: None
 *
 * Reads global variables: None
 * Writes global varibles: None
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
    lda #$10
    sta SID.VOICE_1_CONTROL_REGISTER

    lda #$29
    sta SID.VOICE_1_ATTACK_DECAY

    lda #$05
    sta SID.VOICE_1_SUSTAIN_RELEASE

    // Aktuelle Note laden, mit 48 (4 Oktaven) multiplizieren und im Y-Register ablegen
    lda currentNote
    clc
    adc #48
    tay

    // LO Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    lda #<FreqTablePalLo
    sta ZEROPAGE.TEMP_1_LO
    lda #>FreqTablePalLo
    sta ZEROPAGE.TEMP_1_HI
    lda (ZEROPAGE.TEMP_1), y
    sta SID.VOICE_1_FREQUENCY_LO

    // HI Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    lda #<FreqTablePalHi
    sta ZEROPAGE.TEMP_1_LO
    lda #>FreqTablePalHi
    sta ZEROPAGE.TEMP_1_HI
    lda (ZEROPAGE.TEMP_1), y
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
 * Reads global variables: previousNote, currentNote, noteChange
 * Writes global varibles: None
 *
 * ---------------------------------------------------------------- */ 

playCurrentNote:
{

    lda previousNote
    cmp #$FF
    beq noNoteToPlay2

    lda previousNote
    clc
    asl
    tay

    lda #<noteNames
    sta ZEROPAGE.TEMP_1_LO
    lda #>noteNames
    sta ZEROPAGE.TEMP_1_HI

    lda (ZEROPAGE.TEMP_1), y
    sta SCREENMEM+120
    iny
    lda (ZEROPAGE.TEMP_1), y
    sta SCREENMEM+121
    jmp test

noNoteToPlay2:
    lda #$2D
    sta SCREENMEM+120
    sta SCREENMEM+121
test:

    // lda currentNote
    // cmp previousNote
    // beq outputNoteName

    lda noteChange
    cmp #$01
    bne outputNoteName

playNewNote:
    inc VIC.BORDERCOLOR
    // lda currentNote
    // sta previousNote
    jsr updateSid

outputNoteName:
    lda currentNote
    cmp #$FF
    beq noNoteToPlay

    clc
    asl
    tay

    lda #<noteNames
    sta ZEROPAGE.TEMP_1_LO
    lda #>noteNames
    sta ZEROPAGE.TEMP_1_HI

    lda (ZEROPAGE.TEMP_1), y
    sta SCREENMEM+80
    iny
    lda (ZEROPAGE.TEMP_1), y
    sta SCREENMEM+81
    jmp exit

noNoteToPlay:
    lda #$2D
    sta SCREENMEM+80
    sta SCREENMEM+81

exit:
    rts
}


/* -------------------------------------------------------------------
 *
 * Subroutines
 *
 * ---------------------------------------------------------------- */ 

#import "src/screen.asm"


/* -------------------------------------------------------------------
 *
 * Global variables
 *
 * ---------------------------------------------------------------- */ 

.segmentdef Data [startAfter="Code"]

#import "src/globals.asm"