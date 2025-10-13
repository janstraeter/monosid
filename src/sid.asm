#importonce

#import "constants.asm"
#import "globals.asm"
#import "zpregisters.asm"


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the control registers of the SID chip concerning 
 * note frequency and gate for all 3 voices according to the
 * current value in the global variable "currentNote"
 *
 * Reads global variables:
 * currentNote, FreqTablePalLo, FreqTablePalHi, currentSidWaveFormControlRegisterVoice1,
 * currentSidWaveFormControlRegisterVoice2, currentSidWaveFormControlRegisterVoice3,
 * currentSidActiveVoice1, currentSidActiveVoice2, currentSidActiveVoice3
 *
 * Writes global variables:
 * currentSidWaveFormControlRegisterVoice1, currentSidWaveFormControlRegisterVoice2,
 * currentSidWaveFormControlRegisterVoice3, currentSidActiveVoice1,
 * currentSidActiveVoice2, currentSidActiveVoice3
 *
 * ---------------------------------------------------------------- */ 

sidUpdateVoicesForCurrentNote:
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

    // load current note and use it as index in Y
    lda currentNote
    tay

    // load the low byte of the frequency for the note to play
    // and save it into the voice frequency register of the SID chip vor all 3 voices
    loadPointerToZPR(freqTablePalLo, ZPR_1)
    lda (ZPR_1), y
    sta SID.VOICE_1_FREQUENCY_LO
    sta SID.VOICE_2_FREQUENCY_LO
    sta SID.VOICE_3_FREQUENCY_LO

    // now the high byte
    loadPointerToZPR(freqTablePalHi, ZPR_1)
    lda (ZPR_1), y
    sta SID.VOICE_1_FREQUENCY_HI
    sta SID.VOICE_2_FREQUENCY_HI
    sta SID.VOICE_3_FREQUENCY_HI

    // -------------------------------------
    // Gate bit for Voice 1
    // -------------------------------------

    // check if voice 1 is active
    lda currentSidActiveVoice1
    cmp #0
    beq doNotUseVoice1

    // yes, use voice 1 -> set the gate bit
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

    // yes, use voice 2 -> set the gate bit
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

    // yes, use voice 3 -> set the gate bit
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
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates all SID registers with the values of the input fields
 * in all modules (voices 1, 2 and 3, filter and main)
 *
 * Reads global variables: all input structs
 *
 * ---------------------------------------------------------------- */ 

sidUpdateAllRegisters:
{
    // update voice 1
    jsr sidUpdateVoice1PulseWidth
    jsr sidUpdateVoice1WaveFormControl
    jsr sidUpdateVoice1AttackDecay
    jsr sidUpdateVoice1SustainRelease

    // update voice 2
    jsr sidUpdateVoice2PulseWidth
    jsr sidUpdateVoice2WaveFormControl
    jsr sidUpdateVoice2AttackDecay
    jsr sidUpdateVoice2SustainRelease

    // update voice 3
    jsr sidUpdateVoice3PulseWidth
    jsr sidUpdateVoice3WaveFormControl
    jsr sidUpdateVoice3AttackDecay
    jsr sidUpdateVoice3SustainRelease

    // update filter
    jsr sidUpdateFilterCutoffFrequency
    jsr sidUpdateFilterSwitchesAndResonance
    jsr sidUpdateFilterModesAndVolume

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
    // load the current value of the sustain input for voice 1
    loadPointerToZPR(voice1InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

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
    // load the current value of the sustain input for voice 1
    loadPointerToZPR(voice2InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // shift 4 times to the left and save into controlByte
    asl
    asl
    asl
    asl
    sta controlByte

    // load the current value of the release input for voice 1
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
//    pha
//    jsr debugDumpByte
//    pla

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
    // load the current value of the sustain input for voice 3
    loadPointerToZPR(voice3InputSustain, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

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
 * Updates the SID registers regarding the filter cutoff frequency
 *
 * Reads global variables: filterInputCutoff
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterCutoffFrequency:
{
    loadPointerToZPR(filterInputCutoff, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx SID.FILTER_CUTOFF_LO
    sta SID.FILTER_CUTOFF_HI
    
    /*stx loByte
    sta hiByte

    lsr loByte
    rol hiByte
    lsr loByte
    rol hiByte
    lsr loByte
    rol hiByte
    lsr loByte
    rol hiByte
    lsr loByte
    rol hiByte

    lda loByte
    sta SID.FILTER_CUTOFF_LO
    pha
    jsr debugDumpByte
    pla
    lda hiByte
    sta SID.FILTER_CUTOFF_HI*/


    rts

loByte:
    .byte(0)
hiByte:
    .byte(0)
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
    // if yes, set the first bit to 1, of no set the first bit to zero
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
    // if yes, set the second bit to 1, of no set the second bit to zero
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
    // if yes, set the third bit to 1, of no set the third bit to zero
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
 * Updates the SID registers regarding the filter modes and the main volume
 *
 * Reads global variables: mainInputVol, filterInputLowpass, 
 *                         filterInputHighpass, filterInputBandwidth
 *
 * ---------------------------------------------------------------- */ 
 
sidUpdateFilterModesAndVolume:
{
    // -----------------------------------------
    // Use highpass filter
    // -----------------------------------------

    // load the current value of the use highfilter input
    loadPointerToZPR(filterInputHighpass, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // check if the highpass filter sould be used 
    // if yes, set the seventh bit to 1, of no set the seventh bit to zero
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
    // if yes, set the sixth bit to 1, of no set the sixth bit to zero
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
    // if yes, set the fifth bit to 1, of no set the fifth bit to zero
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
    // Main volume
    // -----------------------------------------

    // load the current value of the main volume input
    loadPointerToZPR(mainInputVol, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // OR the value of the volume (least 4 bits) together with the higher bits
    ora controlByte


    // -----------------------------------------
    // Finish
    // -----------------------------------------

    // save it into the SID control register
    sta SID.FILTER_MODE_MAIN_VOLUME

    rts

controlByte:
    .byte(0)
}

