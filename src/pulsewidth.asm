#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input "mod pulse"
 *
 * Reads global variable:  voice3FeaturesModulatePulseWidth
 *
 * Writes global variable: currentVoice3EnvelopeModulatePulseWidth
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthUpdateVoice3EnvelopeModulatePulseWidthValue:
{
    // load the current value of the "Voice 3 special features" input "mod pulse"
    loadPointerToZPR(voice3FeaturesModulatePulseWidth, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVoice3EnvelopeModulatePulseWidth

    // check if voice #3 envelope should modulate the pulse width
    lda currentVoice3EnvelopeModulatePulseWidth
    cmp #0
    bne exit

    // No, so reset the SID registers to the values from the UI for all voices.
    // This may be neccessary, if the pulse width is currently modulated
    // but the user just now switched of the pulse width modulation.

    // update the pulse width register for voice #1
    lda currentSidVoice1PulseWidth
    sta SID.VOICE_1_PULSE_WAVE_LO
    lda currentSidVoice1PulseWidth+1
    sta SID.VOICE_1_PULSE_WAVE_HI

    // update the pulse width register for voice #2
    lda currentSidVoice2PulseWidth
    sta SID.VOICE_2_PULSE_WAVE_LO
    lda currentSidVoice2PulseWidth+1
    sta SID.VOICE_2_PULSE_WAVE_HI

    // update the pulse width register for voice #3
    lda currentSidVoice3PulseWidth
    sta SID.VOICE_3_PULSE_WAVE_LO
    lda currentSidVoice3PulseWidth+1
    sta SID.VOICE_3_PULSE_WAVE_HI

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input "pulse"
 *
 * Reads global variable:  voice3FeaturesPulseWidth
 *
 * Writes global variable: currentVoice3PulseWidth
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthUpdateVoice3PulseWidthValue:
{
    // load the current value of the "Voice 3 special features" input "pulse"
    loadPointerToZPR(voice3FeaturesPulseWidth, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    stx currentVoice3PulseWidth
    sta currentVoice3PulseWidth+1
    
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input (pulse) "neg"
 *
 * Reads global variable:  voice3FeaturesPulseWidthNegative
 *
 * Writes global variable: currentVoice3PulseWidthNegative
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthUpdateVoice3PulseWidthNegativeValue:
{
    // load the current value of the "Voice 3 special features" input (pulse) "neg"
    loadPointerToZPR(voice3FeaturesPulseWidthNegative, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVoice3PulseWidthNegative
    
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the modulation value for voice #3 envelope pulse width modulation
 *
 * Reads global variable:  currentVoice3PulseWidth
 *
 * Returns: ZPR_1 - 16 bit unsigned modulation value
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthCalculateModulationValue:
{
    // load current value of voice #3 envelope (0-255)
    // and save it into ZPR_1
    lda SID.ENVELOPE_VOICE_3
    sta ZPR_1_LO
    lda #0
    sta ZPR_1_HI
    
    // copy the value of currentVoice3PulseWidth to ZPR_3
    lda currentVoice3PulseWidth
    sta ZPR_3_LO
    lda currentVoice3PulseWidth+1
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
 * Calculates the modulated pulse width values for a specific voice
 *
 * Reads global variables:  currentSidVoice1PulseWidth, currentSidVoice2PulseWidth,
 *                          currentSidVoice3PulseWidth, currentVoice3PulseWidthNegative
 *
 * Parameters: accu - zero based index of the voice (0 through 2)
 *             ZPR_1 - filter cutoff modulation value
 *
 * Writes global variable:  currentSidVoice1ModulatedPulseWidth,
 *                          currentSidVoice2ModulatedPulseWidth,
 *                          currentSidVoice3ModulatedPulseWidth,
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthCalculateModulatedValueForVoice:
{
    // index for voice is in A, shift left to multiply by 2
    // save it into ZPR_0 and X
    asl
    sta ZPR_0
    tax

    // load current pulse width value for selected voice into ZPR_2
    lda currentSidVoice1PulseWidth, x
    sta ZPR_2_LO
    inx
    lda currentSidVoice1PulseWidth, x
    sta ZPR_2_HI

    // check if the pulse width modulation should be negative
    lda currentVoice3PulseWidthNegative
    cmp #0
    bne substract

    // -----------------------------------------------
    // not negative, add the modulation value
    // -----------------------------------------------

    // ZPR_1 = ZPR_1 (pulse width modulation value) + ZPR_2 (currentSidVoice1PulseWidth)
    clc 
    lda ZPR_1_LO
    adc ZPR_2_LO
    sta ZPR_1_LO
    lda ZPR_1_HI
    adc ZPR_2_HI
    sta ZPR_1_HI

    // load max. pulse width (4095) into ZPR_2
    lda #$FF
    sta ZPR_2_LO
    lda #$0F
    sta ZPR_2_HI

    // 16-bit comparison ZPR_1 (modulation value) < ZPR_2 (max. pulse width: 4095)
    lda ZPR_1_HI   // compare high bytes
    cmp ZPR_2_HI
    bcc save       // if ZPR_1_HI < ZPR_2_HI then modulation value < 4095
    bne wrapAround // if ZPR_1_HI <> ZPR_2_HI then modulation value > 4095 (so modulation value >= 4095)
    lda ZPR_1_LO   // compare low bytes
    cmp ZPR_2_LO
    bcc save       // if ZPR_1_LO < ZPR_2_LO then modulation value < 4095

wrapAround:
    // wrap around: substract 4095 from the calculated value
    sec
    lda ZPR_1_LO
    sbc ZPR_2_LO
    sta ZPR_1_LO
    lda ZPR_1_HI
    sbc ZPR_2_HI
    sta ZPR_1_HI
    jmp save

substract:
    // -----------------------------------------------
    // negative, substract the modulation value
    // -----------------------------------------------

    // if (currentPulseWidth >= modulationValue) {
    //     result = currentPulseWidth - modulationValue
    // } else {
    //     result = 4095 - (modulationValue - currentPulseWidth)
    // }

    lda ZPR_2_HI             // compare high bytes
    cmp ZPR_1_HI
    bcc negativeWrapAround   // if ZPR_2_HI < ZPR_1_HI then current pulse width < modulation value
    bne negativeNoWrapAround // if ZPR_2_HI <> ZPR_1_HI then current pulse width > modulation value (so current pulse width >= modulation value)
    lda ZPR_2_LO             // compare low bytes
    cmp ZPR_1_LO
    bcs negativeNoWrapAround // if ZPR_2_LO >= ZPR_1_LO then current pulse width >= modulation value
    jmp negativeWrapAround
    
negativeNoWrapAround:
    // ZPR_1 = ZPR_2 (currentPulseWidth) - ZPR_1 (modulationValue)
    sec
    lda ZPR_2_LO
    sbc ZPR_1_LO
    sta ZPR_1_LO
    lda ZPR_2_HI
    sbc ZPR_1_HI
    sta ZPR_1_HI
    jmp save

negativeWrapAround:
    // ZPR_1 = ZPR_1 (modulationValue) - ZPR_2 (currentPulseWidth)
    sec
    lda ZPR_1_LO
    sbc ZPR_2_LO
    sta ZPR_1_LO
    lda ZPR_1_HI
    sbc ZPR_2_HI
    sta ZPR_1_HI

    // ZPR_2 = 4095
    lda #$FF
    sta ZPR_2_LO
    lda #$0F
    sta ZPR_2_HI

    // ZPR_1 = ZPR_2 (4095) - ZPR_1 (modulationValue - currentPulseWidth)
    sec
    lda ZPR_2_LO
    sbc ZPR_1_LO
    sta ZPR_1_LO
    lda ZPR_2_HI
    sbc ZPR_1_HI
    sta ZPR_1_HI

save:

    // -----------------------------------------------
    // save value
    // -----------------------------------------------

    lda ZPR_1_HI
    sta currentSidVoice1ModulatedPulseWidth, x
    dex
    lda ZPR_1_LO
    sta currentSidVoice1ModulatedPulseWidth, x

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the modulated pulse width values for all voices
 *
 * Reads global variables:  currentSidVoice1PulseWidth, currentSidVoice2PulseWidth,
 *                          currentSidVoice3PulseWidth, currentVoice3PulseWidthNegative
 *
 * Writes global variable:  currentSidVoice1ModulatedPulseWidth,
 *                          currentSidVoice2ModulatedPulseWidth,
 *                          currentSidVoice3ModulatedPulseWidth,
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthCalculateModulatedValuesForAllVoices:
{
    // calculate the modulation value (the same for all voices)
    jsr pulseWidthCalculateModulationValue

    // calculate the individual modulated pulse width values for all voices
    lda #0
    jsr pulseWidthCalculateModulatedValueForVoice
    lda #1
    jsr pulseWidthCalculateModulatedValueForVoice
    lda #2
    jsr pulseWidthCalculateModulatedValueForVoice

    /*ldx currentSidVoice1ModulatedPulseWidth
    ldy currentSidVoice1ModulatedPulseWidth+1
    jsr debugDumpWord*/

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
 * Reads global variables:  currentSidVoice1PulseWidth, currentSidVoice2PulseWidth,
 *                          currentSidVoice3PulseWidth, currentVoice3PulseWidthNegative,
 *                          currentVoice3EnvelopeModulatePulseWidth
 *
 * Writes global variable:  currentSidVoice1ModulatedPulseWidth,
 *                          currentSidVoice2ModulatedPulseWidth,
 *                          currentSidVoice3ModulatedPulseWidth,
 *
 * ---------------------------------------------------------------- */ 
 
pulseWidthUpdateModulatedValuesIfNeccessary:
{
    // check if voice #3 envelope should modulate the pulse width
    lda currentVoice3EnvelopeModulatePulseWidth
    cmp #0
    beq exit

    // yes, so calculate the individual values for all voices
    jsr pulseWidthCalculateModulatedValuesForAllVoices

    // update the pulse width register for voice #1
    lda currentSidVoice1ModulatedPulseWidth
    sta SID.VOICE_1_PULSE_WAVE_LO
    lda currentSidVoice1ModulatedPulseWidth+1
    sta SID.VOICE_1_PULSE_WAVE_HI

    // update the pulse width register for voice #2
    lda currentSidVoice2ModulatedPulseWidth
    sta SID.VOICE_2_PULSE_WAVE_LO
    lda currentSidVoice2ModulatedPulseWidth+1
    sta SID.VOICE_2_PULSE_WAVE_HI

    // update the pulse width register for voice #3
    lda currentSidVoice3ModulatedPulseWidth
    sta SID.VOICE_3_PULSE_WAVE_LO
    lda currentSidVoice3ModulatedPulseWidth+1
    sta SID.VOICE_3_PULSE_WAVE_HI

exit:
    rts
}
