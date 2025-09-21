#importonce

#import "zpregisters.asm"


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 8 bit multiplication, algorithm by Damon Slye
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
    .label MULTIPLIER = ZPR_0

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
 * Parameters:   ZPR_1: first 16 bit integer
 *               ZPR_2: second 16 bit integer
 *
 * Return value: ZPR_3: result
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


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 16-bit division - adapted from codebase64.org
 * (https://codebase64.org/doku.php?id=base:16bit_division_16-bit_result)
 *
 * Parameters:   ZPR_1: divisor (16 bit integer)
 *               ZPR_2: dividend (16 bit integer)
 *
 * Return value: ZPR_2: result (16 bit integer)
 *               ZPR_3: remainder (16 bit integer)
 *
 * ---------------------------------------------------------------- */ 

mathDivide16Bit:
{
    .label divisor = ZPR_1
    .label dividend = ZPR_2
    .label remainder = ZPR_3    
    .label result = dividend // save memory by reusing divident to store the result

divide:
    // preset remainder to 0
    lda #0
	sta remainder
	sta remainder+1

    // repeat for each bit: ...
	ldx #16
divloop:
    
    // dividend lb & hb*2, msb -> Carry
    asl dividend
	rol dividend+1	
	
    // remainder lb & hb * 2 + msb from carry
    rol remainder
	rol remainder+1
	lda remainder
	
    // substract divisor to see if it fits in
    sec
	sbc divisor
	
    // lb result -> Y, for we may need it later
    tay
	lda remainder+1
	sbc divisor+1
	
    // if carry=0 then divisor didn't fit in yet
    bcc skip

	// else save substraction result as new remainder,
    sta remainder+1
	sty remainder	
	
    // and INCrement result cause divisor fit in 1 times
    inc result

skip:
	dex
	bne divloop

	rts
}
