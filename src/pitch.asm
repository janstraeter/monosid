#importonce

pitchCalculateVoiceFrequency:
{
    // index for voice is in A, shift left to multiply by 2
    // save it into ZPR_0 and X
    asl
    sta ZPR_0
    tax
    
    // load the detuning value for the voice in cent (signed 16 bit integer)
    // and save it into "local" variable voiceDetuning
    lda voiceDetunings, x
    sta voiceDetuningLo
    inx
    lda voiceDetunings, x
    sta voiceDetuningHi

    // add the value of the MIDI pitch bend wheel
    // in cent (signed 16 bit integer) and save the result
    clc
    lda midiPitchBendValueLo
    adc voiceDetuningLo
    sta detuningLo
    lda midiPitchBendValueHi
    adc voiceDetuningHi
    sta detuningHi

    // ldx voiceDetuningLo
    // ldy voiceDetuningHi
    // jsr debugDumpWord

    // check if resulting detuning value is negative 
    // (flags from adding the high bytes still set, check for negative flag)
    bmi detuneDown

    // check if resulting detuning value is zero
    // (OR high and low byte together and test for zero flag)
    ora detuningLo
    beq notDetuning

    // if the resulting detuning value is not zero and not negative it's positive, obviously
    jmp detuneUp

notDetuning:
    
    // ***************************************************************
    // Simplest case: no detuning, just load the current note and save it
    // ***************************************************************

    // load index of voice and save it into X
    lda ZPR_0
    tax
    
    // load current note and use it as index in Y
    lda lastPlayedNote
    tay

    // load the low byte of the frequency and save it
    lda freqTablePalLo, y
    sta voiceFrequencies, x

    // load the hight byte of the frequency and save it
    lda freqTablePalHi, y
    inx
    sta voiceFrequencies, x

    rts

detuneDown:

    // ***************************************************************
    // Detune down
    // ***************************************************************

    // Invert the sign of the negative detuning value by substracting
    // first the low- then high byte from zero
    sec
    lda #0
    sbc detuningLo
    sta detuningLo
    lda #0
    sbc detuningHi
    sta detuningHi

    // load 100 as divisor (ZPR_1)
    lda #100
    sta ZPR_1_LO
    lda #0
    sta ZPR_1_HI

    // load the detuning value as dividend (ZPR_2)
    lda detuningLo
    sta ZPR_2_LO
    lda detuningHi
    sta ZPR_2_HI

    // divide ZPR_2 by ZPR_1 (16 bit unsigned division)
    jsr mathDivide16Bit

    // ZPR_2 now contains the result of the division, which is the number of halftones to detune down
    // because the lookup table for the detuning in cent only covers 0-100 cent (no negative numbers)
    // add one to the calculated number of halftones.
    inc ZPR_2_LO

    // now check, if the resulting base note index (lastPlayedNote - ZPR_2_LO) would still be zero or greater
    lda ZPR_2_LO
    cmp lastPlayedNote
    bcs detuningDownToLow

    // detunedBaseNote = lastPlayedNote - ZPR_2_LO
    sec
    lda lastPlayedNote
    sbc ZPR_2_LO
    sta detunedBaseNote

    // ZPR_3 contains the remainder of the division, which is the number of cents to detune the
    // calculated new base-note (0-100 cent), substract this value from 100 to get the correct value to downtune
    lda #100
    sec
    sbc ZPR_3_LO
    sta detuningOfBaseNoteInCent

    // jump over the code for detuning up
    jmp calculateVoiceFrequency

detuningDownToLow:

    // ***************************************************************
    // The detuned frequency would be out of range for the SID chip
    // ***************************************************************

    lda #0
    sta ZPR_2_LO
    sta ZPR_2_HI
    jmp saveDetunedVoiceFrequency

detuneUp:
    
    // ***************************************************************
    // Detune up
    // ***************************************************************

    // load 100 as divisor (ZPR_1)
    lda #100
    sta ZPR_1_LO
    lda #0
    sta ZPR_1_HI

    // load the detuning value as dividend (ZPR_2)
    lda detuningLo
    sta ZPR_2_LO
    lda detuningHi
    sta ZPR_2_HI

    // divide ZPR_2 by ZPR_1 (16 bit unsigned division)
    jsr mathDivide16Bit

    // ZPR_2 now contains the result of the division, which the number of semi notes to detune up
    // add lastPlayedNote to this value and check if the target note is in our range of 8 octaves
    clc
    lda lastPlayedNote
    adc ZPR_2_LO
    cmp #MAX_NOTE_INDEX
    bcs detuningUpToHigh

    // it is in the range, save the result as the new base note
    sta detunedBaseNote

    // ZPR_3 now contains the remainder of the division, which is the number of cents to detune the
    // calculated new base-note (0-100 cent)
    lda ZPR_3_LO
    sta detuningOfBaseNoteInCent
    
calculateVoiceFrequency:

    // ***************************************************************
    // This part is the same for detuning up and down
    // ***************************************************************

    // load the frequency of the calculated new base note
    // first, copy detunedBaseNote to X as index
    lda detunedBaseNote
    tax

    // load the low byte of the base frequency
    lda freqTablePalLo, x
    sta baseFrequencyLo

    // load the high byte of the base frequency
    lda freqTablePalHi, x
    sta baseFrequencyHi

    // now load the detuning factor from the lookup table
    // first, multiply detuningOfBaseNoteInCent by 2 and save it into to X as index
    lda detuningOfBaseNoteInCent
    asl
    tax

    // load the low byte of the detuning factor
    lda detuningTable, x
    sta detuningLo

    // load the high byte of the detuning factor
    inx
    lda detuningTable, x
    sta detuningHi

    // load baseFrequency for multiplication into ZPR_1
    lda baseFrequencyLo
    sta ZPR_1_LO
    lda baseFrequencyHi
    sta ZPR_1_HI

    // load detuning factor for multiplication into ZPR_3
    lda detuningLo
    sta ZPR_3_LO
    lda detuningHi
    sta ZPR_3_HI

    // multiply (16 bit unsigned multiplication, result 32 bit)
    jsr mathMultiply16Bit

    // the result is now in ZPR_1/ZPR_2 (32 bit)
    // because the detuning factor was multiplied with 32768,
    // we need to divide the result by this value (truncate the fraction part actually).
    // That can be done by shifting the result 15 bit to the right -
    // which would result for 4 bytes in 15 * 4 = 60 shifts left = 120 clock cycles
    // BUT... we do not use the least significant byte (ZPR_1_LO) at all
    // and from the second least significant byte (ZPR_1_HI) we only need the most
    // significant bit. So we can use a ROL on ZPR_1_HI to shift bit 7 of ZPR_1_HI into the carry flag
    // then ROL the two most significant bytes one position to the left and ignore the
    // two least significant bytes alltogether.
    rol ZPR_1_HI
    rol ZPR_2_LO
    rol ZPR_2_HI

    // The result divided by 32768 is now in ZPR_2_LO and ZPR_2_HI (16 bit unsigned integer).
    // on PAL systems it can happen that the result of the multiplication is (slightly)
    // bigger than the maximum value of an 16 bit unsigned integer. 
    // That has to do with the way the frequency values for the SID chip are calculated
    // (see https://gist.github.com/matozoid/18cddcbc9cfade3c455bc6230e1f6da6),
    // the value of the highest note would be 67280 on a PAL system vs. 64815 on a NTSC system.
    // But this problem can be easily detected in our case: 
    // If the result is (slightly) bigger than 65535 the most significant bit of the 32 bit result will be set.
    // That is exactly the bit we shift into the carry flag with the last ROL above.
    // So we can just test for a set carry and jump if the result happend to be out of range.
    bcs detuningUpToHigh

saveDetunedVoiceFrequency:

    // ***************************************************************
    // This part is the same for all cases
    // ***************************************************************

    // load index of voice from ZPR_0
    lda ZPR_0
    tax
    
    // save the 16 bit value in ZPR_2 to the voice frequency array
    lda ZPR_2_LO
    sta voiceFrequencies, x
    lda ZPR_2_HI
    inx
    sta voiceFrequencies, x

    // done
    rts

detuningUpToHigh:

    // ***************************************************************
    // The detuned frequency would be out of range for the SID chip
    // ***************************************************************

    lda #$FF
    sta ZPR_2_LO
    sta ZPR_2_HI
    jmp saveDetunedVoiceFrequency

voiceDetuningLo:
    .byte(0)
voiceDetuningHi:
    .byte(0)
detuningLo:
    .byte(0)
detuningHi:
    .byte(0)
baseFrequencyLo:
    .byte(0)
baseFrequencyHi:
    .byte(0)
detunedBaseNote:
    .byte(0)
detuningOfBaseNoteInCent:
    .byte(0)
}

pitchCalculateAllVoiceFrequencies:
{
    lda #0
    jsr pitchCalculateVoiceFrequency
    lda #1
    jsr pitchCalculateVoiceFrequency
    lda #2
    jsr pitchCalculateVoiceFrequency
    rts
}