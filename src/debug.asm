#importonce 


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
