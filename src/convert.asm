#importonce 

#import "zpregisters.asm"
#import "math.asm"

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Convert an (16 bit) integer to a null-terminated string
 *
 * Parameters:   ZPR_0: offset into PETSCII-table (to be able to differentiate 
 *                      between normal and inverted numerals)
 *               ZPR_1: (16 bit) integer, set ZPR_1_HI to zero if not needed
 *               ZPR_2: address of buffer to hold the result string,
 *                      the buffer must be great enough to hold at least 6 chars,
 *                      "65535" + null byte
 *
 * Return value: ZPR_0: length of the return string 
 *
 * ---------------------------------------------------------------- */ 

convertIntegerToString:
{
    // copy ZPR_2 to ZPR_4, because we need ZPR_2 as paramter for the division-subroutine
    copyZPR(ZPR_2, ZPR_4)

    // copy ZPR_1 to ZPR_2, because the division-subroutine uses this for the divident
    copyZPR(ZPR_1, ZPR_2)

    // load the base of 10 as divisor
    lda #$0A
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI

    // use ZPR_5_LO as the length counter of the string
    lda #$00
    sta ZPR_5_LO

digitLoop:
    // divide ZPR_2 by ZPR_1 (result gets written back to ZPR_2, remainder gets written to ZPR_3)
    jsr mathDivide16Bit

    // because we divide by 10, the remainder cannot be greater than 9, so we use only the low byte of ZPR_3
    // the character corresponding to the value of the remainder is number VALUE + 48 ($30 hex)
    lda ZPR_3_LO
    clc
    adc ZPR_0

    // push the value of PETSCII-character to the stack and increment the length counter
    pha
    inc ZPR_5_LO

    // check if divident (in ZPR_2) is zero
    // because it is a 16 bit value, OR low and high byte together and check for zero flag set
    lda ZPR_2_LO
    ora ZPR_2_HI
    beq finished

    // if not finished, loop
    jmp digitLoop
     
    // pull the characters from the stack and write them to the return buffer
finished:
    
    // copy the buffer-address to ZPR_2 again, we do not want to alter the the pointer of the calling routine
    copyZPR(ZPR_4, ZPR_2)
    
    // init the index register with zero
    ldy #$00

    // load the length counter into accu, store it in ZPR_0 as the return value and check if it is greater than zero
    lda ZPR_5_LO
    sta ZPR_0
    cmp #$00
    beq writeNullByte

    // copy the string from the stack into the buffer (effectivley mirroring it in the process)
copyLoop:    
    pla
    sta (ZPR_2), y
    iny
    dec ZPR_5_LO
    bne copyLoop

    // write the null byte to terminate the string
writeNullByte:
    lda #$00
    sta (ZPR_2), y

    rts
}