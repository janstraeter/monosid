#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentLfoModulateFilter" which the
 * current value of the LFO input "mod filter"
 *
 * Reads global variable:  lfoModulateFilter
 *
 * Writes global variable: currentLfoModulateFilter
 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateLfoModulateFilterValue:
{
    // load the current value of the LFO input "mod filter"
    loadPointerToZPR(lfoModulateFilter, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentLfoModulateFilter

    // check if voice #3 envelope should modulate the filter cutoff
    lda currentLfoModulateFilter
    cmp #0
    bne exit

    // No, so reset the SID register for the filter cutoff from the UI.
    // This may be neccessary, if the filter cutoff is currently modulated
    // but the user just now switched of the filter cutoff modulation.
    lda sidCurrentFilterCutoffFrequency
    sta ZPR_1_LO
    lda sidCurrentFilterCutoffFrequency+1
    sta ZPR_1_HI
    jsr sidSetFilterCutoffFrequency

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentLfoModulatePulseWidth" which the
 * current value of the LFO input "cutoff"
 *
 * Reads global variable:  lfoFilterCutoff
 *
 * Writes global variable: currentLfoFilterCutoff:

 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateLfoFilterCutoffValue:
{
    // load the current value of the LFO input "cutoff"
    loadPointerToZPR(lfoFilterCutoff, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    stx currentLfoFilterCutoff
    sta currentLfoFilterCutoff+1

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentLfoModulatePulseWidth" which the
 * current value of the LFO input (cutoff) "neg"
 *
 * Reads global variable:  lfoFilterCutoffNegative
 *
 * Writes global variable: currentLfoFilterCutoffNegative
 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateLfoFilterCutoffNegativeValue:
{
    // load the current value of the LFO input (cutoff) "neg"
    loadPointerToZPR(lfoFilterCutoffNegative, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentLfoFilterCutoffNegative
    
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the modulation value for voice #3 envelope filter cutoff modulation
 *
 * Reads global variable:  currentLfoFilterCutoff
 *
 * Returns: ZPR_1 - 16 bit unsigned modulation value
 *
 * ---------------------------------------------------------------- */ 
 
filterCalculateModulationValue:
{
    // load current value of voice #3 envelope (0-255)
    // and save it into ZPR_1
    lda lfoValue
    sta ZPR_1_LO
    lda #0
    sta ZPR_1_HI
    
    // copy the value of currentLfoFilterCutoff to ZPR_3
    lda currentLfoFilterCutoff
    sta ZPR_3_LO
    lda currentLfoFilterCutoff+1
    sta ZPR_3_HI
    
    // multiply ZPR_1 and ZPR_3 (16 bit unsigned multiplication)
    // from the resulting 32 bit value in ZPR_1 and ZPR_2
    // we take the two middle bytes. That works because
    // we have only multiplied in fact an 8-bit value with an 12-bit value
    // AND we have to divide the result by 256 (shift right 8 bit)
    // to get our desired result.
    // Well, to be precise not EXACTLY the desired result, as
    // we would have needed to divide the result by 255. But this would be
    // computationally expensive on the 6502/6510. Division by 256 is
    // close enough - the difference should be barely audible.
    jsr mathMultiply16Bit
    lda ZPR_1_HI
    sta ZPR_1_LO
    lda ZPR_2_LO
    sta ZPR_1_HI

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the filter cutoff value modulated by voice #3 envelope
 *
 * Reads global variables:  sidCurrentFilterCutoffFrequency,
 *                          currentLfoFilterCutoffNegative
 *
 * Parameter: ZPR_1 - filter cutoff modulation value
 *
 * Writes global variable:  sidCurrentModulatedFilterCutoffFrequency
 *
 * ---------------------------------------------------------------- */ 
 
filterCalculateModulatedCutoffValue:
{
    // load current pulse width value for selected voice into ZPR_2
    lda sidCurrentFilterCutoffFrequency
    sta ZPR_2_LO
    lda sidCurrentFilterCutoffFrequency+1
    sta ZPR_2_HI

    // check if the filter cutoff modulation should be negative
    lda currentLfoFilterCutoffNegative
    cmp #0
    bne substract

    // -----------------------------------------------
    // not negative, add the modulation value
    // -----------------------------------------------

    // ZPR_1 = ZPR_1 (filter cutoff modulation value) + ZPR_2 (sidCurrentVoice1PulseWidth)
    clc 
    lda ZPR_1_LO
    adc ZPR_2_LO
    sta ZPR_1_LO
    lda ZPR_1_HI
    adc ZPR_2_HI
    sta ZPR_1_HI

    // load max. filter cutoff (2047) into ZPR_2
    lda #$FF
    sta ZPR_2_LO
    lda #$07
    sta ZPR_2_HI

    // 16-bit comparison ZPR_1 (modulation value) < ZPR_2 (max. filter cutoff: 2047)
    lda ZPR_1_HI   // compare high bytes
    cmp ZPR_2_HI
    bcc save       // if ZPR_1_HI < ZPR_2_HI then modulation value < 2047
    bne clampToMax // if ZPR_1_HI <> ZPR_2_HI then modulation value > 2047 (so modulation value >= 2047)
    lda ZPR_1_LO   // compare low bytes
    cmp ZPR_2_LO
    bcc save       // if ZPR_1_LO < ZPR_2_LO then modulation value < 2047

substract:
    // -----------------------------------------------
    // negative, substract the modulation value
    // -----------------------------------------------

    // if (currentFilterCutoff >= modulationValue) {
    //     result = currentFilterCutoff - modulationValue
    // } else {
    //     result = 0
    // }

    lda ZPR_2_HI             // compare high bytes
    cmp ZPR_1_HI
    bcc clampToMin           // if ZPR_2_HI < ZPR_1_HI then current filter cutoff < modulation value
    bne negativeNoClamp      // if ZPR_2_HI <> ZPR_1_HI then current filter cutoff > modulation value (so current filter cutoff >= modulation value)
    lda ZPR_2_LO             // compare low bytes
    cmp ZPR_1_LO
    bcs negativeNoClamp      // if ZPR_2_LO >= ZPR_1_LO then current filter cutoff >= modulation value
    jmp clampToMin
    
negativeNoClamp:
    // ZPR_1 = ZPR_2 (currentFilterCutoff) - ZPR_1 (modulationValue)
    sec
    lda ZPR_2_LO
    sbc ZPR_1_LO
    sta ZPR_1_LO
    lda ZPR_2_HI
    sbc ZPR_1_HI
    sta ZPR_1_HI

    // -----------------------------------------------
    // save result to global value
    // -----------------------------------------------

save:
    // save calculated value
    lda ZPR_1_LO
    sta sidCurrentModulatedFilterCutoffFrequency
    lda ZPR_1_HI
    sta sidCurrentModulatedFilterCutoffFrequency+1
    rts

clampToMin:
    // save clamped to min. filter cutoff value of 0
    lda #0
    sta sidCurrentModulatedFilterCutoffFrequency
    sta sidCurrentModulatedFilterCutoffFrequency+1
    rts

clampToMax:
    // save clamped to to max. filter cutoff value of 2047
    lda #$FF
    sta sidCurrentModulatedFilterCutoffFrequency
    lda #$07
    sta sidCurrentModulatedFilterCutoffFrequency+1
    rts

}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if voice #3 envelope should modulate the pulse width
 * and calculates the modulated pulse widths for all voices
 * if neccessary.
 *
 * Reads global variables:  currentLfoModulateFilter,
 *                          sidCurrentFilterCutoffFrequency,
 *                          currentLfoFilterCutoffNegative
 *                          
 * Writes global variable:  sidCurrentModulatedFilterCutoffFrequency
 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateModulatedCutoffValueIfNeccessary:
{
    // check if voice #3 envelope should modulate the pulse width
    lda currentLfoModulateFilter
    cmp #0
    beq exit

    // yes, so calculate the modulated filter cutoff value
    jsr filterCalculateModulationValue
    jsr filterCalculateModulatedCutoffValue

    // update the filter cutoff register
    lda sidCurrentModulatedFilterCutoffFrequency
    sta ZPR_1_LO
    lda sidCurrentModulatedFilterCutoffFrequency+1
    sta ZPR_1_HI
    jsr sidSetFilterCutoffFrequency

exit:
    rts
}