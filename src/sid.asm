#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the voice control registers of the SID chip.
 * Sets for each voice the the gate bit to 1 if a note is actually played
 * and the voice is active.
 *
 * Reads global variables:
 * currentNote, currentSidWaveFormControlRegisterVoice1,
 * currentSidWaveFormControlRegisterVoice2, currentSidWaveFormControlRegisterVoice3,
 * currentSidActiveVoice1, currentSidActiveVoice2, currentSidActiveVoice3
 *
 * Writes global variables:
 * currentSidWaveFormControlRegisterVoice1, currentSidWaveFormControlRegisterVoice2,
 * currentSidWaveFormControlRegisterVoice3, currentSidActiveVoice1,
 * currentSidActiveVoice2, currentSidActiveVoice3
 *
 * ---------------------------------------------------------------- */ 

sidUpdateGateBitsForAllVoices:
{
    // check the current note to determine if any voice should be active
    lda currentNote
    cmp #$FF
    bne playNote
    
    // no note should be played, so set the gate bit for all voices to zero
    lda currentSidWaveFormControlRegisterVoice1
    and #%11111110
    sta SID.VOICE_1_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice1

    lda currentSidWaveFormControlRegisterVoice2
    and #%11111110
    sta SID.VOICE_2_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice2

    lda currentSidWaveFormControlRegisterVoice3
    and #%11111110
    sta SID.VOICE_3_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice3

    rts

playNote:
    // -------------------------------------
    // Note frequency for all voices
    // -------------------------------------

    jsr sidUpdateVoiceFrequencies

    // -------------------------------------
    // Gate bit for Voice 1
    // -------------------------------------

    // check if voice 1 is active
    lda currentSidActiveVoice1
    cmp #0
    beq doNotUseVoice1

    // check if test bit for voice 1 should be set
    lda currentSidResetOscillatorVoice1
    cmp #0
    beq setGateBitVoice1
    
    // yes, the test bit should be set (and cleared again) before opening the gate
    // first check if the gate is currently closed, because we want to reset the oscillator only
    // before opening the gate, not on every note change
    lda currentSidWaveFormControlRegisterVoice1
    bit gateBitSet
    bne setGateBitVoice1

    // gate is currently closed, set the test bit to reset the oscillator
    // and then clear it again, immediatly
    ora #%00001000
    sta SID.VOICE_1_CONTROL_REGISTER
    lda currentSidWaveFormControlRegisterVoice1
    sta SID.VOICE_1_CONTROL_REGISTER

    // yes, use voice 1 -> set the gate bit
setGateBitVoice1:    
    lda currentSidWaveFormControlRegisterVoice1
    ora #%00000001
    jmp saveVoice1

doNotUseVoice1:
    // no, do not use voice 1 -> clear the gate bit
    lda currentSidWaveFormControlRegisterVoice1
    and #%11111110

saveVoice1:
    // save the control register for voice 1
    sta SID.VOICE_1_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice1

    // -------------------------------------
    // Gate bit for Voice 2
    // -------------------------------------

    // check if voice 2 is active
    lda currentSidActiveVoice2
    cmp #0
    beq doNotUseVoice2

    // check if test bit for voice 2 should be set
    lda currentSidResetOscillatorVoice2
    cmp #0
    beq setGateBitVoice2
    
    // yes, the test bit should be set (and cleared again) before opening the gate
    // first check if the gate is currently closed, because we want to reset the oscillator only
    // before opening the gate, not on every note change
    lda currentSidWaveFormControlRegisterVoice2
    bit gateBitSet
    bne setGateBitVoice2

    // gate is currently closed, set the test bit to reset the oscillator
    // and then clear it again, immediatly
    ora #%00001000
    sta SID.VOICE_2_CONTROL_REGISTER
    lda currentSidWaveFormControlRegisterVoice2
    sta SID.VOICE_2_CONTROL_REGISTER

    // yes, use voice 2 -> set the gate bit
setGateBitVoice2:
    lda currentSidWaveFormControlRegisterVoice2
    ora #%00000001
    jmp saveVoice2

doNotUseVoice2:
    // no, do not use voice 2 -> clear the gate bit
    lda currentSidWaveFormControlRegisterVoice2
    and #%11111110

saveVoice2:
    // save the control register for voice 2
    sta SID.VOICE_2_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice2

    // -------------------------------------
    // Gate bit for Voice 3
    // -------------------------------------

    // check if voice 3 is active
    lda currentSidActiveVoice3
    cmp #0
    beq doNotUseVoice3

    // check if test bit for voice 3 should be set
    lda currentSidResetOscillatorVoice3
    cmp #0
    beq setGateBitVoice3
    
    // yes, the test bit should be set (and cleared again) before opening the gate
    // first check if the gate is currently closed, because we want to reset the oscillator only
    // before opening the gate, not on every note change
    lda currentSidWaveFormControlRegisterVoice3
    bit gateBitSet
    bne setGateBitVoice3

    // gate is currently closed, set the test bit to reset the oscillator
    // and then clear it again, immediatly
    ora #%00001000
    sta SID.VOICE_3_CONTROL_REGISTER
    lda currentSidWaveFormControlRegisterVoice3
    sta SID.VOICE_3_CONTROL_REGISTER

    // yes, use voice 3 -> set the gate bit
setGateBitVoice3:
    lda currentSidWaveFormControlRegisterVoice3
    ora #%00000001
    jmp saveVoice3

doNotUseVoice3:
    // no, do not use voice 3 -> clear the gate bit
    lda currentSidWaveFormControlRegisterVoice3
    and #%11111110

saveVoice3:
    // save the control register for voice 3
    sta SID.VOICE_3_CONTROL_REGISTER
    sta currentSidWaveFormControlRegisterVoice3

    rts

gateBitSet:
    // gate bit is the LSB
    .byte(%00000001)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates all SID registers / global variables with the values
 * of the input fields in all modules
 *
 * Reads global variables: all input structs
 *
 * ---------------------------------------------------------------- */ 

sidUpdateAllRegisters:
{
    // update velocity (do this first, because the values
    // of the sustain/release and the filter modes/main volume registers
    // depend on the velocity settings)
    jsr sidUpdateVelocityUse
    jsr sidUpdateVelocitySustain

    // update voice 1
    jsr sidUpdateVoice1PulseWidth
    jsr sidUpdateVoice1WaveFormControl
    jsr sidUpdateVoice1AttackDecay
    // jsr sidUpdateVoice1SustainRelease -> called by sidUpdateVelocityUse / sidUpdateVelocitySustain

    // update voice 2
    jsr sidUpdateVoice2PulseWidth
    jsr sidUpdateVoice2WaveFormControl
    jsr sidUpdateVoice2AttackDecay
    // jsr sidUpdateVoice2SustainRelease -> called by sidUpdateVelocityUse / sidUpdateVelocitySustain

    // update voice 3
    jsr sidUpdateVoice3PulseWidth
    jsr sidUpdateVoice3WaveFormControl
    jsr sidUpdateVoice3AttackDecay
    // jsr sidUpdateVoice3SustainRelease -> called by sidUpdateVelocityUse / sidUpdateVelocitySustain

    // update filter
    jsr sidUpdateFilterCutoffFrequency
    jsr sidUpdateFilterSwitchesAndResonance
    jsr sidUpdateFilterModesAndVolume

    // update detunings for all voices
    jsr pitchUpdateDetuningInputVoice1
    jsr pitchUpdateDetuningInputVoice2
    jsr pitchUpdateDetuningInputVoice3

    // update reset oscillator for all voices
    jsr sidUpdateResetOscillatorVoice1
    jsr sidUpdateResetOscillatorVoice2
    jsr sidUpdateResetOscillatorVoice3

    // update voice 3 special features
    jsr pulseWidthUpdateVoice3EnvelopeModulatePulseWidthValue
    jsr filterUpdateVoice3EnvelopeModulateFilterValue
    jsr pulseWidthUpdateVoice3PulseWidthValue
    jsr pulseWidthUpdateVoice3PulseWidthNegativeValue
    jsr filterUpdateVoice3FilterCutoffValue
    jsr filterUpdateVoice3FilterCutoffNegativeValue

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the pulse width of voice 1
 *
 * Reads global variables: voice1InputPulseWidth
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice1PulseWidth:
{
    loadPointerToZPR(voice1InputPulseWidth, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx SID.VOICE_1_PULSE_WAVE_LO
    sta SID.VOICE_1_PULSE_WAVE_HI
    stx currentSidVoice1PulseWidth
    sta currentSidVoice1PulseWidth+1
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the waveform control of voice 1
 *
 * Reads global variables: voice1InputWaveform, voice1InputSync,
 *                         voice1InputRingMod, voice1InputUse
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice1WaveFormControl:
{
    // -----------------------------------------
    // Waveform
    // -----------------------------------------

    // load the current value of the waveform input for voice 1
    loadPointerToZPR(voice1InputWaveform, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // switch to the current value
    cmp #WAVEFORM.TRIANGULAR
    beq waveformTriangular
    cmp #WAVEFORM.SAWTOOTH
    beq waveformSawtooth
    cmp #WAVEFORM.SQUARE
    beq waveformSquare
    cmp #WAVEFORM.NOISE
    beq waveformNoise

waveformTriangular:
    // triangular -> set bit 5
    lda #%00010000
    jmp waveformEnd

waveformSawtooth:
    // sawtooth -> set bit 6
    lda #%00100000
    jmp waveformEnd

waveformSquare:
    // square -> set bit 7
    lda #%01000000
    jmp waveformEnd

waveformNoise:
    // noise -> set bit 8
    lda #%10000000

waveformEnd:
    // save the value for the waveform
    sta controlByte


    // -----------------------------------------
    // Sync
    // -----------------------------------------

    // load the current value of the snyc input for voice 1
    loadPointerToZPR(voice1InputSync, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if sync input is set to active and set the bit mask accordingly
    cmp #0
    bne setSyncFlag
    lda #%00000000
    jmp saveSyncFlag

setSyncFlag:
    lda #%00000010

saveSyncFlag:
    // OR the sync bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Ring mod
    // -----------------------------------------

    // load the current value of the ring mod input for voice 1
    loadPointerToZPR(voice1InputRingMod, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if ring mod input is set to active and set the bit mask accordingly
    cmp #0
    bne setRingModFlag
    lda #%00000000
    jmp saveRingModFlag

setRingModFlag:
    lda #%00000100

saveRingModFlag:
    // OR the ring mod bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Gate flag
    // -----------------------------------------

    // load the current value of the use input for voice 1
    loadPointerToZPR(voice1InputUse, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into global variable for later easy access
    sta currentSidActiveVoice1

    // check if the voice should be used and set the gate bit to zero if not used,
    // or the the current value if used
    cmp #0
    bne useVoice
    lda #%00000000

useVoice:
    // set the gate bit according to the current value in the control register
    lda currentSidWaveFormControlRegisterVoice1
    and #%00000001

    // OR the gate bit to the current value in controlByte
    ora controlByte


    // -----------------------------------------
    // Finish
    // -----------------------------------------

    // save the value in controlByte into the global variable
    sta currentSidWaveFormControlRegisterVoice1

    // finally save it into the control register of the SID chip
    sta SID.VOICE_1_CONTROL_REGISTER

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding attack and decay of voice 1
 *
 * Reads global variables: voice1InputAttack, voice1InputDecay
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice1AttackDecay:
{
    // load the current value of the attack input for voice 1
    loadPointerToZPR(voice1InputAttack, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the decay input for voice 1
    loadPointerToZPR(voice1InputDecay, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_1_ATTACK_DECAY

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding sustain and release of voice 1
 *
 * Reads global variables: voice1InputSustain, voice1InputRelease
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice1SustainRelease:
{
    // check if (currentVelocitySustain AND currentVelocityUse)
    lda currentVelocitySustain
    and currentVelocityUse
    bne caluclateVelocityForSustain

    // no, just load the current value of the sustain input for voice 1
    loadPointerToZPR(voice1InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    jmp saveRegister

caluclateVelocityForSustain:   
    // calculate the the sustain volume, using a lookup table
    // (current note volume * current sustain volume / 15)
    // the accu contains in the end the lower 4 bits of the register
    loadPointerToZPR(voice1InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    asl
    asl
    asl
    asl
    clc
    adc currentNoteVolume
    tax
    lda multiplyVolumeByVolumeTable, x

saveRegister:
    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the release input for voice 1
    loadPointerToZPR(voice1InputRelease, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_1_SUSTAIN_RELEASE

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the pulse width of voice 2
 *
 * Reads global variables: voice2InputPulseWidth
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice2PulseWidth:
{
    loadPointerToZPR(voice2InputPulseWidth, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx SID.VOICE_2_PULSE_WAVE_LO
    sta SID.VOICE_2_PULSE_WAVE_HI
    stx currentSidVoice2PulseWidth
    sta currentSidVoice2PulseWidth+1
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the waveform control of voice 2
 *
 * Reads global variables: voice2InputWaveform, voice2InputSync,
 *                         voice2InputRingMod, voice1InputUse
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice2WaveFormControl:
{
    // -----------------------------------------
    // Waveform
    // -----------------------------------------

    // load the current value of the waveform input for voice 2
    loadPointerToZPR(voice2InputWaveform, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // switch to the current value
    cmp #WAVEFORM.TRIANGULAR
    beq waveformTriangular
    cmp #WAVEFORM.SAWTOOTH
    beq waveformSawtooth
    cmp #WAVEFORM.SQUARE
    beq waveformSquare
    cmp #WAVEFORM.NOISE
    beq waveformNoise

waveformTriangular:
    // triangular -> set bit 5
    lda #%00010000
    jmp waveformEnd

waveformSawtooth:
    // sawtooth -> set bit 6
    lda #%00100000
    jmp waveformEnd

waveformSquare:
    // square -> set bit 7
    lda #%01000000
    jmp waveformEnd

waveformNoise:
    // noise -> set bit 8
    lda #%10000000

waveformEnd:
    // save the value for the waveform
    sta controlByte


    // -----------------------------------------
    // Sync
    // -----------------------------------------

    // load the current value of the snyc input for voice 2
    loadPointerToZPR(voice2InputSync, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if sync input is set to active and set the bit mask accordingly
    cmp #0
    bne setSyncFlag
    lda #%00000000
    jmp saveSyncFlag

setSyncFlag:
    lda #%00000010

saveSyncFlag:
    // OR the sync bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Ring mod
    // -----------------------------------------

    // load the current value of the ring mod input for voice 2
    loadPointerToZPR(voice2InputRingMod, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if ring mod input is set to active and set the bit mask accordingly
    cmp #0
    bne setRingModFlag
    lda #%00000000
    jmp saveRingModFlag

setRingModFlag:
    lda #%00000100

saveRingModFlag:
    // OR the ring mod bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Gate flag
    // -----------------------------------------

    // load the current value of the use input for voice 2
    loadPointerToZPR(voice2InputUse, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into global variable for later easy access
    sta currentSidActiveVoice2

    // check if the voice should be used and set the gate bit to zero if not used,
    // or the the current value if used
    cmp #0
    bne useVoice
    lda #%00000000

useVoice:
    // set the gate bit according to the current value in the control register
    lda currentSidWaveFormControlRegisterVoice2
    and #%00000001

    // OR the gate bit to the current value in controlByte
    ora controlByte


    // -----------------------------------------
    // Finish
    // -----------------------------------------

    // save the value in controlByte into the global variable
    sta currentSidWaveFormControlRegisterVoice2

    // finally save it into the control register of the SID chip
    sta SID.VOICE_2_CONTROL_REGISTER

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding attack and decay of voice 2
 *
 * Reads global variables: voice2InputAttack, voice2InputDecay
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice2AttackDecay:
{
    // load the current value of the attack input for voice 1
    loadPointerToZPR(voice2InputAttack, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the decay input for voice 1
    loadPointerToZPR(voice2InputDecay, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_2_ATTACK_DECAY

    rts

controlByte:
    .byte(0)}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding sustain and release of voice 2
 *
 * Reads global variables: voice2InputSustain, voice2InputRelease
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice2SustainRelease:
{
    // check if (currentVelocitySustain AND currentVelocityUse)
    lda currentVelocitySustain
    and currentVelocityUse
    bne caluclateVelocityForSustain

    // no, just load the current value of the sustain input for voice 2
    loadPointerToZPR(voice2InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    jmp saveRegister

caluclateVelocityForSustain:   
    // calculate the the sustain volume, using a lookup table
    // (current note volume * current sustain volume / 15)
    // the accu contains in the end the lower 4 bits of the register
    loadPointerToZPR(voice2InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    asl
    asl
    asl
    asl
    clc
    adc currentNoteVolume
    tax
    lda multiplyVolumeByVolumeTable, x

saveRegister:
    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the release input for voice 2
    loadPointerToZPR(voice2InputRelease, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_2_SUSTAIN_RELEASE

    rts

controlByte:
    .byte(0)}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the pulse width of voice 3
 *
 * Reads global variables: voice3InputPulseWidth
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice3PulseWidth:
{
    loadPointerToZPR(voice3InputPulseWidth, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx SID.VOICE_3_PULSE_WAVE_LO
    sta SID.VOICE_3_PULSE_WAVE_HI
    stx currentSidVoice3PulseWidth
    sta currentSidVoice3PulseWidth+1
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the waveform control of voice 3
 *
 * Reads global variables: voice3InputWaveform, voice3InputSync,
 *                         voice3InputRingMod, voice1InputUse
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice3WaveFormControl:
{
    // -----------------------------------------
    // Waveform
    // -----------------------------------------

    // load the current value of the waveform input for voice 3
    loadPointerToZPR(voice3InputWaveform, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // switch to the current value
    cmp #WAVEFORM.TRIANGULAR
    beq waveformTriangular
    cmp #WAVEFORM.SAWTOOTH
    beq waveformSawtooth
    cmp #WAVEFORM.SQUARE
    beq waveformSquare
    cmp #WAVEFORM.NOISE
    beq waveformNoise

waveformTriangular:
    // triangular -> set bit 5
    lda #%00010000
    jmp waveformEnd

waveformSawtooth:
    // sawtooth -> set bit 6
    lda #%00100000
    jmp waveformEnd

waveformSquare:
    // square -> set bit 7
    lda #%01000000
    jmp waveformEnd

waveformNoise:
    // noise -> set bit 8
    lda #%10000000

waveformEnd:
    // save the value for the waveform
    sta controlByte


    // -----------------------------------------
    // Sync
    // -----------------------------------------

    // load the current value of the snyc input for voice 3
    loadPointerToZPR(voice3InputSync, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if sync input is set to active and set the bit mask accordingly
    cmp #0
    bne setSyncFlag
    lda #%00000000
    jmp saveSyncFlag

setSyncFlag:
    lda #%00000010

saveSyncFlag:
    // OR the sync bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Ring mod
    // -----------------------------------------

    // load the current value of the ring mod input for voice 3
    loadPointerToZPR(voice3InputRingMod, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if ring mod input is set to active and set the bit mask accordingly
    cmp #0
    bne setRingModFlag
    lda #%00000000
    jmp saveRingModFlag

setRingModFlag:
    lda #%00000100

saveRingModFlag:
    // OR the ring mod bit to the current value in controlByte
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Gate flag
    // -----------------------------------------

    // load the current value of the use input for voice 3
    loadPointerToZPR(voice3InputUse, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into global variable for later easy access
    sta currentSidActiveVoice3

    // check if the voice should be used and set the gate bit to zero if not used,
    // or the the current value if used
    cmp #0
    bne useVoice
    lda #%00000000

useVoice:
    // set the gate bit according to the current value in the control register
    lda currentSidWaveFormControlRegisterVoice3
    and #%00000001

    // OR the gate bit to the current value in controlByte
    ora controlByte


    // -----------------------------------------
    // Finish
    // -----------------------------------------

    // save the value in controlByte into the global variable
    sta currentSidWaveFormControlRegisterVoice3

    // finally save it into the control register of the SID chip
    sta SID.VOICE_3_CONTROL_REGISTER

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding attack and decay of voice 3
 *
 * Reads global variables: voice3InputAttack, voice3InputDecay
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice3AttackDecay:
{
    // load the current value of the attack input for voice 3
    loadPointerToZPR(voice3InputAttack, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the decay input for voice 3
    loadPointerToZPR(voice3InputDecay, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_3_ATTACK_DECAY

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding sustain and release of voice 3
 *
 * Reads global variables: voice3InputSustain, voice3InputRelease
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoice3SustainRelease:
{
    // check if ((NOT muteVoice3) AND currentVelocitySustain AND currentVelocityUse)
    loadPointerToZPR(voice3FeaturesInputMuteVoice3, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    eor #$FF
    and currentVelocitySustain
    and currentVelocityUse
    bne caluclateVelocityForSustain

    // no, just load the current value of the sustain input for voice 3
    loadPointerToZPR(voice3InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    jmp saveRegister

caluclateVelocityForSustain:   
    // calculate the the sustain volume, using a lookup table
    // (current note volume * current sustain volume / 15)
    // the accu contains in the end the lower 4 bits of the register
    loadPointerToZPR(voice3InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    asl
    asl
    asl
    asl
    clc
    adc currentNoteVolume
    tax
    lda multiplyVolumeByVolumeTable, x

saveRegister:
    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the release input for voice 3
    loadPointerToZPR(voice3InputRelease, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the two values together
    ora controlByte

    // save it into the SID control register
    sta SID.VOICE_3_SUSTAIN_RELEASE

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets the SID filter cutoff register to the value of ZPR_1
 * Because this register works differently than the registers for
 * e.g. the pulse widths this subroutine is a helper function
 * to set the filter cutoff value.
 *
 * The low byte of the register contains the 3 least significant bits
 * while the high register contains the 8 most significant bits.
 * Therefore it is not possible to just write low and high byte
 * of the filter cutoff value into the register, it needs preparation.
 *
 * @link https://www.oxyron.de/html/registers_sid.html
 *
 * Parameter: ZPR_1 - 11 bit cutoff value
 *
 * ---------------------------------------------------------------- */ 
 
sidSetFilterCutoffFrequency:
{
    // save low byte
    lda ZPR_1_LO
    tax

    // shift high and low byte 3 bits to the right
    lsr ZPR_1_HI
    ror ZPR_1_LO
    lsr ZPR_1_HI
    ror ZPR_1_LO
    lsr ZPR_1_HI
    ror ZPR_1_LO

    // the low byte now contains the upper 8 bit of the 11 bit value
    // so write it into the high byte of filter cutoff register
    lda ZPR_1_LO
    sta SID.FILTER_CUTOFF_HI

    // write the beforehand saved low byte of the 11 bit value (which contains
    // the least significant 3 bits) into the the low byte of the filter cutoff register
    txa
    sta SID.FILTER_CUTOFF_LO

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the filter cutoff frequency
 *
 * Reads global variables: filterInputCutoff
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterCutoffFrequency:
{
    // load the value from the input element
    loadPointerToZPR(filterInputCutoff, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    
    // save the value into sidCurrentFilterCutoffFrequency
    stx sidCurrentFilterCutoffFrequency
    sta sidCurrentFilterCutoffFrequency+1
    
    // write the value into the SID filter cutoff registers
    stx ZPR_1_LO
    sta ZPR_1_HI
    jsr sidSetFilterCutoffFrequency

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the filter switches and resonance
 *
 * Reads global variables: filterInputVoice1, filterInputVoice2,
 *                         filterInputVoice3, filterInputResonance
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterSwitchesAndResonance:
{
    // -----------------------------------------
    // Resonance
    // -----------------------------------------

    // load the current value of the filter resonance input
    loadPointerToZPR(filterInputResonance, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // -----------------------------------------
    // Use filter for voice 1
    // -----------------------------------------

    // load the current value of the use filter input for voice 1
    loadPointerToZPR(filterInputVoice1, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the filter sould be used for voice 1
    // if yes, set the first bit to 1, if no set the first bit to zero
    cmp #0
    beq doNotUseFilterForVoice1
    lda #%00000001
    jmp saveUseFilter1

doNotUseFilterForVoice1:
    lda #0

saveUseFilter1:
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Use filter for voice 2
    // -----------------------------------------

    // load the current value of the use filter input for voice 2
    loadPointerToZPR(filterInputVoice2, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the filter sould be used for voice 2
    // if yes, set the second bit to 1, if no set the second bit to zero
    cmp #0
    beq doNotUseFilterForVoice2
    lda #%00000010
    jmp saveUseFilter2

doNotUseFilterForVoice2:
    lda #0

saveUseFilter2:
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Use filter for voice 3
    // -----------------------------------------

    // load the current value of the use filter input for voice 3
    loadPointerToZPR(filterInputVoice3, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the filter sould be used for voice 3
    // if yes, set the third bit to 1, if no set the third bit to zero
    cmp #0
    beq doNotUseFilterForVoice3
    lda #%00000100
    jmp saveUseFilter3

doNotUseFilterForVoice3:
    lda #0

saveUseFilter3:
    ora controlByte


    // -----------------------------------------
    // Finish
    // -----------------------------------------

    // save the end result into the SID control register
    sta SID.FILTER_RESONANCE_ROUTING

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the filter modes global variable
 *
 * Reads global variables: filterInputLowpass, 
 *                         filterInputHighpass, filterInputBandwidth
 *
 * Writes global variables: sidCurrentFilterModesValue
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateCurrentFilterModesValue:
{
    // -----------------------------------------
    // Use highpass filter
    // -----------------------------------------

    // load the current value of the use highfilter input
    loadPointerToZPR(filterInputHighpass, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the highpass filter sould be used 
    // if yes, set the seventh bit to 1, if no set the seventh bit to zero
    cmp #0
    beq doNotUseHighpassFilter
    lda #%01000000
    jmp saveUseHighpassFilter

doNotUseHighpassFilter:
    lda #0

saveUseHighpassFilter:
    sta controlByte


    // -----------------------------------------
    // Use bandwidth filter
    // -----------------------------------------

    // load the current value of the use bandwidth filter input
    loadPointerToZPR(filterInputBandwidth, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the bandwidth filter sould be used
    // if yes, set the sixth bit to 1, if no set the sixth bit to zero
    cmp #0
    beq doNotUseBandwithFilter
    lda #%00100000
    jmp saveUseBandwithFilter

doNotUseBandwithFilter:
    lda #0

saveUseBandwithFilter:
    ora controlByte
    sta controlByte


    // -----------------------------------------
    // Use lowpass filter
    // -----------------------------------------

    // load the current value of the use lowpass filter input
    loadPointerToZPR(filterInputLowpass, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the lowpass filter sould be used
    // if yes, set the fifth bit to 1, if no set the fifth bit to zero
    cmp #0
    beq doNotUseLowpassFilter
    lda #%00010000
    jmp saveUseLowpassFilter

doNotUseLowpassFilter:
    lda #0

saveUseLowpassFilter:
    ora controlByte
    sta controlByte

    // -----------------------------------------
    // Mute voice 3
    // -----------------------------------------

    // load the current value of the mute voice 3 input
    loadPointerToZPR(voice3FeaturesInputMuteVoice3, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if voice #3 should be muted
    // if yes, set the MSB to 1, if no set it to 0
    cmp #0
    beq doNotMuteVoice3
    lda #%10000000
    jmp saveMuteVoice3

doNotMuteVoice3:
    lda #0

saveMuteVoice3:
    ora controlByte
    sta controlByte

    // save it into the global variable, so we do not have to calculate this value
    // everytime the current played note changes
    sta sidCurrentFilterModesValue

    rts

controlByte:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable sidCurrentMainVolumeValue with the
 * current value of the main volume input field.
 *
 * Reads global variables: mainInputVol
 *
 * Writes global variables: sidCurrentMainVolumeValue
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateCurrentMainVolumeValue:
{
    // load the current value of the main volume input
    loadPointerToZPR(mainInputVol, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into global variable, so we do not have to calculate this value
    // everytime the current played note changes
    sta sidCurrentMainVolumeValue

    rts
}

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the filter modes and the main volume
 * If the velocity settings are set to use velocity for main volume,
 * caluclate the current main volume value from the current note volume.
 *
 * Reads global variables: sidCurrentMainVolumeValue, currentNoteVolume,
 *                         sidCurrentFilterModesValue, currentVelocityUse,
 *                         currentVelocitySustain
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterModeMainVolumeRegisterWithVelocity:
{
    // check if ((NOT currentVelocitySustain) AND currentVelocityUse)
    lda currentVelocitySustain
    eor #$FF
    and currentVelocityUse
    bne caluclateVelocityForVolume

    // no, just load the current main volume value
    lda sidCurrentMainVolumeValue
    jmp saveRegister

caluclateVelocityForVolume:   
    // calculate the current main volume, using a lookup table
    // (current note volume * current main volume / 15)
    // the accu contains in the end the lower 4 bits of the register
    lda sidCurrentMainVolumeValue
    asl
    asl
    asl
    asl
    clc
    adc currentNoteVolume
    tax
    lda multiplyVolumeByVolumeTable, x

saveRegister:
    // combine the volume with the filter modes (upper 4 bits of the register)
    ora sidCurrentFilterModesValue

    // save it into the SID control register
    sta SID.FILTER_MODE_MAIN_VOLUME

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers and global variables regarding
 * the filter modes and the main volume.
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterModesAndVolume:
{
    jsr sidUpdateCurrentFilterModesValue
    jsr sidUpdateCurrentMainVolumeValue
    jsr sidUpdateFilterModeMainVolumeRegisterWithVelocity
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the SID registers regarding the voice frequencies
 *
 * Reads global variables: voice1FrequenyLo, voice1FrequenyHi,
 *                         voice2FrequenyLo, voice2FrequenyHi,
 *                         voice3FrequenyLo, voice3FrequenyHi
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVoiceFrequencies:
{
    lda voice1FrequenyLo
    sta SID.VOICE_1_FREQUENCY_LO
    lda voice1FrequenyHi
    sta SID.VOICE_1_FREQUENCY_HI

    lda voice2FrequenyLo
    sta SID.VOICE_2_FREQUENCY_LO
    lda voice2FrequenyHi
    sta SID.VOICE_2_FREQUENCY_HI

    lda voice3FrequenyLo
    sta SID.VOICE_3_FREQUENCY_LO
    lda voice3FrequenyHi
    sta SID.VOICE_3_FREQUENCY_HI

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "resetOscillatorVoice1" which the
 * current value of the input field for voice 1 in the module "Reset oscillators"
 *
 * Reads global variable:  resetOscillatorVoice1
 *
 * Writes global variable: currentSidResetOscillatorVoice1
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateResetOscillatorVoice1:
{
    // load the current value of the reset oscillator for voice 1 input
    loadPointerToZPR(resetOscillatorVoice1, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentSidResetOscillatorVoice1

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "resetOscillatorVoice2" which the
 * current value of the input field for voice 2 in the module "Reset oscillators"
 *
 * Reads global variable:  resetOscillatorVoice2
 *
 * Writes global variable: currentSidResetOscillatorVoice2
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateResetOscillatorVoice2:
{
    // load the current value of the reset oscillator for voice 2 input
    loadPointerToZPR(resetOscillatorVoice2, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentSidResetOscillatorVoice2

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "resetOscillatorVoice3" which the
 * current value of the input field for voice 3 in the module "Reset oscillators"
 *
 * Reads global variable:  resetOscillatorVoice3
 *
 * Writes global variable: currentSidResetOscillatorVoice3
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateResetOscillatorVoice3:
{
    // load the current value of the reset oscillator for voice 3 input
    loadPointerToZPR(resetOscillatorVoice3, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentSidResetOscillatorVoice3

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "velocityUse" which the
 * current value of the input field for use velocity in the module "Velocity"
 *
 * Reads global variable:  velocityUse
 *
 * Writes global variable: currentVelocityUse
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVelocityUse:
{
    // load the current value of the use velocity input
    loadPointerToZPR(velocityUse, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVelocityUse

    // update all registers which may be affected
    jsr sidUpdateFilterModeMainVolumeRegisterWithVelocity
    jsr sidUpdateVoice1SustainRelease
    jsr sidUpdateVoice2SustainRelease
    jsr sidUpdateVoice3SustainRelease

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "velocityUse" which the
 * current value of the input field for use velocity for sustain in the module "Velocity"
 *
 * Reads global variable:  velocitySus
 *
 * Writes global variable: currentVelocitySus
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateVelocitySustain:
{
    // load the current value of the use velocity for sustain input
    loadPointerToZPR(velocitySustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVelocitySustain

    // update all registers which may be affected
    jsr sidUpdateFilterModeMainVolumeRegisterWithVelocity
    jsr sidUpdateVoice1SustainRelease
    jsr sidUpdateVoice2SustainRelease
    jsr sidUpdateVoice3SustainRelease

    rts
}


