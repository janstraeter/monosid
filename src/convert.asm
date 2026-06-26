#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Convert an (16 bit) integer to a null-terminated string
 *
 * DEFINITLY NOT optimized for speed!
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
 * -------------------------------------------------------------*/ 

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

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Converts a null-terminated string to (unsigned) 16-bit value
 * Expects a string containing only characters 0-9, no sanity checks are done
 *
 * DEFINITLY NOT optimized for speed!
 *
 * Parameters:   ZPR_0: offset into PETSCII-table (to be able to differentiate 
 *                      between normal and inverted numerals)
 *               ZPR_1: address of null-terminated string to be converted
 *
 * Return value: ZPR_2: result of conversion
 *
 * -------------------------------------------------------------*/ 

convertStringToInteger:
{
    // initialize result with zero
    lda #0
    sta result
    sta result+1

    // start with first character from the left of the string
    ldy #0

loop:
    // read next character from string and check if null byte reached, if so exit
    lda (ZPR_1), y
    beq lastCharacterReached

    // multiply current result by 10
    // multiply by 10 can be done with multiple register shifts and additions
    // adapted from here: https://llx.com/Neil/a2/mult.html
    lda result       // start with resultBy10 = result
    sta resultBy10
    lda result+1
    sta resultBy10+1
    asl resultBy10
    rol resultBy10+1  // resultBy10 = 2*result
    asl resultBy10
    rol resultBy10+1  // resultBy10 = 4*result
    clc
    lda result
    adc resultBy10
    sta resultBy10
    lda result+1
    adc resultBy10+1
    sta resultBy10+1  // resultBy10 = 5*result
    asl resultBy10
    rol resultBy10+1  // resultBy10 = 10*result

    // save the result of the multiplaction by 10 back to the result
    lda resultBy10
    sta result
    lda resultBy10+1
    sta result+1

    // subtract the PETSCII table offset
    // from the character code to get the numerical value, save result in "numberToAdd"
    lda (ZPR_1), y
    sec
    sbc ZPR_0
    sta numberToAdd

    // add the numerical value of the current character to the result (16-bit addition)
    clc
    lda result
    adc numberToAdd
    sta result
    lda result+1
    adc #0
    sta result+1

    // increase character index by one and loop
    iny
    jmp loop

lastCharacterReached:
    // write the result to ZPR_2 and exit
    lda result
    sta ZPR_2_LO
    lda result+1
    sta ZPR_2_HI
    rts

numberToAdd:
    .byte(0)
result:
    .byte(0)
    .byte(0)
resultBy10:
    .byte(0)
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Converts a PETSCII character byte to its screen code equivalent.
 * Assumes that the upper case character set is used.
 *
 * Source of conversion table: https://sta.c64.org/cbm64pettoscr.html
 *
 * Parameters:   Accu - PETSCII character
 *
 * Return value: Accu - screen code
 *
 * ------------------------------------------------------------------- */ 

convertPetsciiToScreenCode:
{
    // $00–$1F: control codes -> $80–$9F
    cmp #$20
    bcs notCtrl1
    clc
    adc #$80
    rts

notCtrl1:
    // $20–$3F: punctuation/digits -> unchanged
    cmp #$40
    bcs notPunctuation
    rts

notPunctuation:
    // $40–$5F: @, A–Z, [\]^_ -> $00–$1F
    cmp #$60
    bcs notUpper
    sec
    sbc #$40
    rts

notUpper:
    // $60–$7F: graphics/lowercase -> $40–$5F
    cmp #$80
    bcs notGfx1
    sec
    sbc #$20
    rts

notGfx1:
    // $80–$9F: control codes -> $C0–$DF
    cmp #$A0
    bcs notCtrl2
    clc
    adc #$40
    rts

notCtrl2:
    // $A0–$BF: shifted graphics -> $60–$7F
    cmp #$C0
    bcs notGfx2
    sec
    sbc #$40
    rts

notGfx2:
    // $C0–$DF: Shift-@, Shift-A–Z … -> $40–$5F
    cmp #$E0
    bcs notUpper2
    sec
    sbc #$80
    rts

notUpper2:
    // $FF: pi symbol -> $5E (checkerboard)
    cmp #$FF
    beq isPi
    // $E0–$FE: graphics mirror -> $60–$7E
    sec
    sbc #$80
    rts

isPi:
    lda #$5E
    rts
}