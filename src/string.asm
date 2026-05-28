#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * returns the length of null terminated string
 *
 * Parameters:    ZPR_1: Address of string to calculate length
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


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * copies a null terminated string from the address in ZPR_1 to
 * the address in ZPR_2
 *
 * Parameters:    ZPR_1: Address of source string
 *                ZPR_2: Address of buffer to write string into
 *
 * Return values: Accu: length of copied string
 *
 * ---------------------------------------------------------------- */ 

stringCopy:
{
    ldy #$00
    
loop:
    lda (ZPR_1), y
    sta (ZPR_2), y
    beq exit
    iny
    jmp loop

exit:
    tya
    rts
}