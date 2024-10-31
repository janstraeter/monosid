/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 8 bit multiplication, written by Damon Slye
 *
 * Parameters:   Accu:       multiplier
 *               X-Register: multiplicant
 *
 * Return value: Accu:       High byte of result
 *               X-register  Low byte of result
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

mathMultiply:
{
    // some zeropage adress instead of
    // a local variable, because speed
    .label MULTIPLIER = ZEROPAGE.TEMP_7

multiply:
    cpx #$00
    beq end
    dex
    stx modify+1
    lsr
    sta MULTIPLIER
    lda #$00
    ldx #$08

loop:
    bcc skip

modify:
    adc #$00

skip:
    ror
    ror MULTIPLIER
    dex
    bne loop
    ldx MULTIPLIER
    rts

end:
    txa
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Addition of two 16 bit integers
 *
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of first 16 bit integer
 *               ZEROPAGE.TEMP_1_HI: High byte of first 16 bit integer
 *               ZEROPAGE.TEMP_2_LO: Low byte of second 16 bit integer
 *               ZEROPAGE.TEMP_2_HI: High byte of second 16 bit integer
 *
 * Return value: ZEROPAGE.TEMP_3_LO: Low byte of result
 *               ZEROPAGE.TEMP_3_HI: High byte of result
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

mathAdd16Bit:
{
    clc
    lda ZEROPAGE.TEMP_1_LO
    adc ZEROPAGE.TEMP_2_LO
    sta ZEROPAGE.TEMP_3_LO
    lda ZEROPAGE.TEMP_1_HI
    adc ZEROPAGE.TEMP_2_HI
    sta ZEROPAGE.TEMP_3_HI
    rts
}
