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
 * Constants and structs
 *
 * ---------------------------------------------------------------- */ 

#import "src/constants.asm"
#import "src/structs.asm"
#import "src/zpregisters.asm"


/* -------------------------------------------------------------------
 *
 * Main program
 *
 * ---------------------------------------------------------------- */ 

BasicUpstart2(mainProgram)

mainProgram:
{
    jsr setupRasterInterrupt

    lda #BLACK
    sta VIC.BORDERCOLOR
    sta VIC.BACKGROUND_COLOR_0
    
    /*lda #WHITE
    sta KERNAL.TEXTCOLOR
    jsr KERNAL.CLS*/

    jsr screenClear
    lda #RED
    jsr screenClearColor

    screenPutStringColor(0, 0, introtext, RED)
    screenDrawRectangleColor(3, 2, 35, 21, YELLOW)
    screenDrawRectangleColor(4, 3, 10, 10, GREEN)

    screenPutChar(0, 0, test)
    screenPutChar(1, 0, $ab)
    screenPutColor(0, 0, BLUE)
    screenPutCharColor(39, 24, $51, GREEN)
    screenPutColorLength(4, 3, 12, BLUE)

    jsr userinterfaceDrawMain

waitLoop:
    lda ZP.CURRENT_PRESSED_KEY
    sta currentPressedKey

    jmp waitLoop

quit:
    jsr KERNAL.CLS
    rts

    test: .byte($00)
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
    jsr updateCurrentNote
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
 * Interprets the currently pressed key as a note
 *
 * Reads global variables:  keyboardPianoKeyCodes, currentPressedKey
 * Writes global variables: currentNote, noteChange
 *
 * ---------------------------------------------------------------- */ 

updateCurrentNote:
{
    lda #<keyboardPianoKeyCodes
    sta ZPR_1_LO
    lda #>keyboardPianoKeyCodes
    sta ZPR_1_HI
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
    lda #$10
    sta SID.VOICE_1_CONTROL_REGISTER

    lda #$00
    sta SID.VOICE_1_ATTACK_DECAY

    lda #$FA
    sta SID.VOICE_1_SUSTAIN_RELEASE

    // Aktuelle Note laden, mit 48 (4 Oktaven) dazu addieren und im Y-Register ablegen
    lda currentNote
    clc
    adc #48
    tay

    // LO Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    lda #<FreqTablePalLo
    sta ZPR_1_LO
    lda #>FreqTablePalLo
    sta ZPR_1_HI
    lda (ZPR_1), y
    sta SID.VOICE_1_FREQUENCY_LO

    // HI Byte der Frequenz der aktuellen Note laden und für Stimme 1 setzen
    lda #<FreqTablePalHi
    sta ZPR_1_LO
    lda #>FreqTablePalHi
    sta ZPR_1_HI
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
 * Reads global variables:  previousNote, currentNote, noteChange
 * Writes global variables: None
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
    sta ZPR_1_LO
    lda #>noteNames
    sta ZPR_1_HI

    lda (ZPR_1), y
    sta SCREENMEM+120
    iny
    lda (ZPR_1), y
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
    sta ZPR_1_LO
    lda #>noteNames
    sta ZPR_1_HI

    lda (ZPR_1), y
    sta SCREENMEM+80
    iny
    lda (ZPR_1), y
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

#import "src/math.asm"
#import "src/screen.asm"
#import "src/userinterface.asm"


/* -------------------------------------------------------------------
 *
 * Global variables
 *
 * ---------------------------------------------------------------- */ 

.segmentdef Data [startAfter="Code"]

#import "src/strings.asm"
#import "src/globals.asm"
