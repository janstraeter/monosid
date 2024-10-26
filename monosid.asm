#import "src/constants.asm"

.file [name="monosid.prg", segments="Code, Data"]

.segment Code [start=$8000, modify="BasicUpstart", _start=$8000]

// ******************************************************************
// 
// Hauptprogramm
//
// ******************************************************************

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

// ******************************************************************
// 
// Setup Raster Interrupt Routine
//
// ******************************************************************

setupRasterInterrupt:
{
    sei                                 // Interrupts sperren

    lda #<rasterInterrupRoutine         // LSB der Interrupt-Routine in den Interrupt Vector schreiben
    sta INTERRUPT_VECTOR_LO            
    lda #>rasterInterrupRoutine         // und MSB
    sta INTERRUPT_VECTOR_HI

    lda #$00                            // Raster-IRQ soll bei Zeile 0 ausgelöst werden
    sta VIC.RASTER_COUNTER             

    lda VIC.CONTROL_REGISTER_1          // Zur Sicherheit auch noch
    and #%01111111                      // das höhste Bit für den
    sta VIC.CONTROL_REGISTER_1          // gewünschten Raster-IRQ löschen 

    lda VIC.INTERRUPT_ENABLED           // IRQs vom
    ora #%00000001                      // VIC-II aktivieren
    sta VIC.INTERRUPT_ENABLED

    cli                                 // Interrupts wieder erlauben

    rts
}

// ******************************************************************
// 
// Raster Interrupt Routine
//
// ******************************************************************

rasterInterrupRoutine:
{    
    lda VIC.INTERRUPT_REGISTER
    bmi doRasterIrq                     // wenn ja -> Raster IRQ
    lda CIA.INTERRUPT_CONTROL_STATE     // sonst, CIA-IRQ bestätigen  
    cli                                 // IRQs erlauben
    jmp KERNAL.INTERRUPT_ROUTINE        // und zur ROM-Routine springen

doRasterIrq:
    sta VIC.INTERRUPT_REGISTER          // IRQ bestätigen

    // inc VIC.BORDERCOLOR                 // zum Testen Rahmenfarbe hochzählen

/*    lda $C5
    sta SCREENMEM+1
    lda $CB
    sta SCREENMEM*/

    jsr updateCurrentNote
    
    /*lda currentNote
    clc
    adc #$30
    sta SCREENMEM*/

    lda currentNote
    cmp #$FF
    beq noNoteToPlay

    clc
    asl
    tay

    // ldy #$00

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
    pla                                 // Y vom Stack
    tay
    pla                                 // X vom Stack
    tax
    pla                                 // Akku vom Stack
    rti                                 // Interrupt verlassen
}

// ******************************************************************
// 
// Funktion um Keyboard-Eingaben als Noten interpretieren
//
// ******************************************************************

updateCurrentNote:
{
    lda ZEROPAGE.CURRENT_PRESSED_KEY
    sta currentPressedKey

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
    sty currentNote
    rts

notFound:
    lda #$FF
    sta currentNote
    rts

currentPressedKey:
    .byte(0)
}


.segmentdef Data [startAfter="Code"]

.encoding "screencode_upper"

// ******************************************************************
// TEMP
// ******************************************************************
introtext:
    .text "MONOSID - USE WASD TO PLAY NOTES"
    .byte 0


// ******************************************************************
// 
// Globale Variable: Aktuell gespielte Note (255 = keine)
//
// ******************************************************************
currentNote:
    .byte($FF)

// ******************************************************************
//
// Keyboard-Piano (1 Oktave C-C)
// 
//  w e   t y u
// a s d f g h j k
//
// ******************************************************************
keyboardPianoKeyCodes:
    .byte(10) // A
    .byte(9)  // W
    .byte(13) // S
    .byte(14) // E
    .byte(18) // D
    .byte(21) // F
    .byte(22) // T
    .byte(26) // G
    .byte(25) // Y
    .byte(29) // H
    .byte(30) // U
    .byte(34) // J
    .byte(37) // K

// ******************************************************************
// 
// Noten Namen für alle 12 (Halb)töne
// 
// ******************************************************************
noteNames:
    .text "C "
    .text "C#"
    .text "D "
    .text "D#"
    .text "E "
    .text "F "
    .text "F#"
    .text "G "
    .text "G#"
    .text "A "
    .text "A#"
    .text "B "
    .text "C "
