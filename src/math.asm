#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 8 bit unsigned multiplication, algorithm by Damon Slye
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
 * Unsigned addition of two 16 bit integers
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
 * 16x16-bit unsigned multiplication - adapted from Toby Lobster
 * (see https://github.com/TobyLobster/multiply_test/blob/main/tests/mult64.a)
 * 
 * Original comment from the author:
 * -------------------------------------------------------------------
 * mult64.a
 * based on Dr Jefyll, http://forum.6502.org/viewtopic.php?f=9&t=689&start=0#p19958
 * - adjusted to use fixed zero page addresses
 * - removed 'decrement to avoid clc' as this is slower on average
 * - rearranged memory use to remove final memory copy and give LSB first order to result
 * - removed temp zp storage bytes
 * - unrolled the outer loop
 * - unrolled the two inner loops fully
 * 16 bit x 16 bit unsigned multiply, 32 bit result
 * Average cycles: 386.00
 * 279 bytes
 * -------------------------------------------------------------------
 *
 * Parameters:   ZPR_1: multiplier (16 bit integer)
 *               ZPR_3: multiplicand (16 bit integer)
 *
 * Return value: ZPR_1/ZPR_2: result (32 bit integer)
 *
 * ---------------------------------------------------------------- */ 

mathMultiply16Bit:
{
    .label multiplicand    = ZPR_3   // 2 bytes
    .label multiplier      = ZPR_1   // 2 bytes
    .label result          = ZPR_1   // 4 bytes   (note: shares memory with multiplier)

    ldy multiplicand    // Y is 'multiplicand' (low byte) throughout
                        // To avoid using Y, just 'lda multiplicand' instead of 'tya' throughout.
                        // This increases the average cycle count of the routine by only 4.5 cycles.
    lda #0              //
    sta result+2        // 16 bits of zero in A, result+2
                        //  Note:    First 8 shifts are  A -> result+2 -> result
                        //           Final 8 shifts are  A -> result+2 -> result+1

    // --- 1st byte ---
    lsr result

    // first time
    bcc !next+
    sty result+2
    lda multiplicand+1

    lsr                 // shift
    ror result+2
!next:                  // normally this should be two instructions earlier but as this
                        // is the first iteration we know A=result+2=0 and carry clear
                        // so those shift instructions have no effect.
    ror result

    // second time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // third time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // fourth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // fifth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // sixth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // seventh time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // eighth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result

    // --- 2nd byte ---
    lsr result+1

    // first time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // second time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // third time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // fourth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // fifth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // sixth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // seventh time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    // eighth time
    bcc !next+
    tax                 // retain A
    tya                 // equivalent to lda multiplicand
    clc
    adc result+2
    sta result+2
    txa                 // recall A
    adc multiplicand+1

!next:
    ror                 // shift
    ror result+2
    ror result+1

    sta result+3        // ms byte of hi-word of result
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 16-bit unsigned division - adapted from codebase64.org
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
