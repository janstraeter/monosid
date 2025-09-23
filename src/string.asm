#importonce

#import "zpregisters.asm"


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * return the length of null terminated string
 *
 * Parameters:    ZPR_1_LO: Low byte of 16 bit address of string
 *                ZPR_1_HI: High byte of 16 bit address of string
 *
 * Return values: Accu: length of string in ZPR_1
 *
 * ---------------------------------------------------------------- */ 

stringGetLength:
{
    ldy #$00
    
loop:
    lda (ZPR_1), y
    beq exit
    iny
    jmp loop

exit:
    tya
    rts
}