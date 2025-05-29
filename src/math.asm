#importonce

#import "zpregisters.asm"

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
 * ---------------------------------------------------------------- */ 

mathMultiply:
{
    // some zeropage adress instead of
    // a local variable, because speed
    .label MULTIPLIER = ZPR_7

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
 * Parameters:   ZPR_1_LO: Low byte of first 16 bit integer
 *               ZPR_1_HI: High byte of first 16 bit integer
 *               ZPR_2_LO: Low byte of second 16 bit integer
 *               ZPR_2_HI: High byte of second 16 bit integer
 *
 * Return value: ZPR_3_LO: Low byte of result
 *               ZPR_3_HI: High byte of result
 *
 * ---------------------------------------------------------------- */ 

mathAdd16Bit:
{
    clc
    lda ZPR_1_LO
    adc ZPR_2_LO
    sta ZPR_3_LO
    lda ZPR_1_HI
    adc ZPR_2_HI
    sta ZPR_3_HI
    rts
}
