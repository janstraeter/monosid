#importonce

/* -------------------------------------------------------------------
 *
 * Detected model of the C64 system (PAL, NTSC1, NTSC2, DREAN)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

detectedC64model:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Is true if a PAL system was detected, false for NTSC systems
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

detectedPALSystem:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Currently selected program mode
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentMode:
    .byte(MODE.MAIN)


/* -------------------------------------------------------------------
 *
 * Currently selected sub mode of the current program mode
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentSubMode:
    .byte(MODE_MAIN_SUBMODE.SELECT_INPUT)


/* -------------------------------------------------------------------
 *
 * Currently visible page with modules (for the program mode MODE.MAIN)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentPage:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * If set to one, the Kernal ISR emulation should be called in the main loop
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

callEmulationOfKernalISR:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Is true if the current note changed in the last input cycle
 * and the player routine needs to update the SID
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

noteHasChangedFlag:
    .byte($00)


/* -------------------------------------------------------------------
 *
 * Current note to be played (index into the frequency-table)
 * 255 = no note
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentNote:
    .byte($FF)


/* -------------------------------------------------------------------
 *
 * Last note that is currently/or was played (index into the frequency-table)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

lastPlayedNote:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Previously played note (index into the frequency-table)
 * 255 = no note
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

previousNote:
    .byte($FF)


/* -------------------------------------------------------------------
 *
 * Current note volume (calculated from the MIDI note velocity value)
 * possible value: 0 to 15 (initialized with 15)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentNoteVolume:
    .byte(15)


/* -------------------------------------------------------------------
 *
 * Currently pressed key (read from zero page addr. 203)
 * 64 = no key
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentPressedKey:
    .byte($40)


/* -------------------------------------------------------------------
 *
 * Current note relative to the currently selected octave of the
 * keyboard piano), a value between 0-11
 * 255 = no note
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentNoteOfOctave:
    .byte($FF)


/* -------------------------------------------------------------------
 *
 * Currently selected octave of the keyboard piano
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentKeyboardPianoOctave:
    .byte($04)


/* -------------------------------------------------------------------
 *
 * Note-offset for the currently selected octave of the keyboard piano
 * (currentKeyboardPianoOctave * 12)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentKeyboardPianoNoteOffset:
    .byte($30)


/* -------------------------------------------------------------------
 *
 * Flag to keep track if the current note was played via the C64
 * keyboard and not by MIDI.
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

currentNoteWasPlayedByKeyboardFlag:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "VOICE 1"
 *
 * ---------------------------------------------------------------- */ 

voice1InputWaveform:
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 4, 5, strInputNameVoiceWaveform, WAVEFORM.SQUARE, $00, sidUpdateVoice1WaveFormControl,
                      IID.V1_WAVE, IID.V1_RING, IID.V1_PULSE, IID.LFO_PITCH, IID.V2_WAVE)

voice1InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 4, 6, strInputNameVoicePulseWidth, $FF, $07, sidUpdateVoice1PulseWidth,
                      IID.V1_PULSE, IID.V1_WAVE, IID.V1_ATC, IID.LFO_PITCH_NEG, IID.V2_PULSE)

voice1InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 4, 4, strInputNameVoiceAttack, $00, $00, sidUpdateVoice1AttackDecay,
                      IID.V1_ATC, IID.V1_PULSE, IID.V1_DCY, IID.LFO_PULSE, IID.V2_ATC)

voice1InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 4, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice1AttackDecay,
                      IID.V1_DCY, IID.V1_ATC, IID.V1_SUS, IID.LFO_PULSE, IID.V2_DCY)

voice1InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 4, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice1SustainRelease,
                      IID.V1_SUS, IID.V1_DCY, IID.V1_RLS, IID.LFO_PULSE_NEG, IID.V2_SUS)

voice1InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 4, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice1SustainRelease,
                      IID.V1_RLS, IID.V1_SUS, IID.V1_RING, IID.LFO_CUTOFF, IID.V2_RLS)

voice1InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 3, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice1WaveFormControl,
                      IID.V1_USE, IID.V1_RLS, IID.V1_WAVE, IID.LFO_CUTOFF_NEG, IID.V1_SYNC)

voice1InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 4, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice1WaveFormControl,
                      IID.V1_SYNC, IID.V1_RLS, IID.V1_WAVE, IID.V1_USE, IID.V1_RING)

voice1InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 5, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice1WaveFormControl,
                      IID.V1_RING, IID.V1_RLS, IID.V1_WAVE, IID.V1_SYNC, IID.V2_USE)

voice1InputArray:
    .byte(<voice1InputWaveform)
    .byte(>voice1InputWaveform)
    .byte(<voice1InputPulseWidth)
    .byte(>voice1InputPulseWidth)
    .byte(<voice1InputAttack)
    .byte(>voice1InputAttack)
    .byte(<voice1InputDecay)
    .byte(>voice1InputDecay)
    .byte(<voice1InputSustain)
    .byte(>voice1InputSustain)
    .byte(<voice1InputRelease)
    .byte(>voice1InputRelease)
    .byte(<voice1InputUse)
    .byte(>voice1InputUse)
    .byte(<voice1InputSync)
    .byte(>voice1InputSync)
    .byte(<voice1InputRingMod)
    .byte(>voice1InputRingMod)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "VOICE 2"
 *
 * ---------------------------------------------------------------- */ 

voice2InputWaveform:
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 10, 5, strInputNameVoiceWaveform, WAVEFORM.SAWTOOTH, $00, sidUpdateVoice2WaveFormControl,
                      IID.V2_WAVE, IID.V2_RING, IID.V2_PULSE, IID.V1_WAVE, IID.V3_WAVE)

voice2InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 10, 6, strInputNameVoicePulseWidth, $FF, $00, sidUpdateVoice2PulseWidth,
                      IID.V2_PULSE, IID.V2_WAVE, IID.V2_ATC, IID.V1_PULSE, IID.V3_PULSE)

voice2InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 10, 4, strInputNameVoiceAttack, $00, $00, sidUpdateVoice2AttackDecay,
                      IID.V2_ATC, IID.V2_PULSE, IID.V2_DCY, IID.V1_ATC, IID.V3_ATC)

voice2InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 10, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice2AttackDecay,
                      IID.V2_DCY, IID.V2_ATC, IID.V2_SUS, IID.V1_DCY, IID.V3_DCY)

voice2InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 10, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice2SustainRelease,
                      IID.V2_SUS, IID.V2_DCY, IID.V2_RLS, IID.V1_SUS, IID.V3_SUS)

voice2InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 10, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice2SustainRelease,
                      IID.V2_RLS, IID.V2_SUS, IID.V2_RING, IID.V1_RLS, IID.V3_RLS)

voice2InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 9, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice2WaveFormControl,
                      IID.V2_USE, IID.V2_RLS, IID.V2_WAVE, IID.V1_RING, IID.V2_SYNC)

voice2InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 10, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice2WaveFormControl,
                      IID.V2_SYNC, IID.V2_RLS, IID.V2_WAVE, IID.V2_USE, IID.V2_RING)

voice2InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 11, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice2WaveFormControl,
                      IID.V2_RING, IID.V2_RLS, IID.V2_WAVE, IID.V2_SYNC, IID.V3_USE)

voice2InputArray:
    .byte(<voice2InputWaveform)
    .byte(>voice2InputWaveform)
    .byte(<voice2InputPulseWidth)
    .byte(>voice2InputPulseWidth)
    .byte(<voice2InputAttack)
    .byte(>voice2InputAttack)
    .byte(<voice2InputDecay)
    .byte(>voice2InputDecay)
    .byte(<voice2InputSustain)
    .byte(>voice2InputSustain)
    .byte(<voice2InputRelease)
    .byte(>voice2InputRelease)
    .byte(<voice2InputUse)
    .byte(>voice2InputUse)
    .byte(<voice2InputSync)
    .byte(>voice2InputSync)
    .byte(<voice2InputRingMod)
    .byte(>voice2InputRingMod)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "VOICE 3"
 *
 * ---------------------------------------------------------------- */ 

voice3InputWaveform:
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 16, 5, strInputNameVoiceWaveform, WAVEFORM.TRIANGULAR, $00, sidUpdateVoice3WaveFormControl,
                      IID.V3_WAVE, IID.V3_RING, IID.V3_PULSE, IID.V2_WAVE, IID.FILTER_CUTOFF)

voice3InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 16, 6, strInputNameVoicePulseWidth, $F0, $0F, sidUpdateVoice3PulseWidth,
                      IID.V3_PULSE, IID.V3_WAVE, IID.V3_ATC, IID.V2_PULSE, IID.FILTER_RES)

voice3InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 16, 4, strInputNameVoiceAttack, $0F, $00, sidUpdateVoice3AttackDecay,
                      IID.V3_ATC, IID.V3_PULSE, IID.V3_DCY, IID.V2_ATC, IID.FILTER_V1)

voice3InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 16, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice3AttackDecay,
                      IID.V3_DCY, IID.V3_ATC, IID.V3_SUS, IID.V2_DCY, IID.FILTER_V1)

voice3InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 16, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice3SustainRelease,
                      IID.V3_SUS, IID.V3_DCY, IID.V3_RLS, IID.V2_SUS, IID.FILTER_LOWPASS)

voice3InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 16, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice3SustainRelease,
                      IID.V3_RLS, IID.V3_SUS, IID.V3_RING, IID.V2_RLS, IID.FILTER_LOWPASS)

voice3InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 15, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice3WaveFormControl,
                      IID.V3_USE, IID.V3_RLS, IID.V3_WAVE, IID.V2_RING, IID.V3_SYNC)

voice3InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 16, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice3WaveFormControl,
                      IID.V3_SYNC, IID.V3_RLS, IID.V3_WAVE, IID.V3_USE, IID.V3_RING)

voice3InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 17, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice3WaveFormControl,
                      IID.V3_RING, IID.V3_RLS, IID.V3_WAVE, IID.V3_SYNC, IID.MAIN_VOL)

voice3InputArray:
    .byte(<voice3InputWaveform)
    .byte(>voice3InputWaveform)
    .byte(<voice3InputPulseWidth)
    .byte(>voice3InputPulseWidth)
    .byte(<voice3InputAttack)
    .byte(>voice3InputAttack)
    .byte(<voice3InputDecay)
    .byte(>voice3InputDecay)
    .byte(<voice3InputSustain)
    .byte(>voice3InputSustain)
    .byte(<voice3InputRelease)
    .byte(>voice3InputRelease)
    .byte(<voice3InputUse)
    .byte(>voice3InputUse)
    .byte(<voice3InputSync)
    .byte(>voice3InputSync)
    .byte(<voice3InputRingMod)
    .byte(>voice3InputRingMod)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "FILTER"
 *
 * ---------------------------------------------------------------- */ 

filterInputCutoff:
    createStructInput(INPUT_TYPE.INTEGER_11_BITS, 1, 22, 6, strInputNameFilterCutoff, $00, $00, sidUpdateFilterCutoffFrequency,
                      IID.FILTER_CUTOFF, IID.MAIN_VOL, IID.FILTER_RES, IID.V3_WAVE, IID.DETUNING_V1)

filterInputResonance:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 8, 22, 4, strInputNameFilterResonance, $00, $00, sidUpdateFilterSwitchesAndResonance,
                      IID.FILTER_RES, IID.FILTER_CUTOFF, IID.FILTER_V3, IID.V3_PULSE, IID.DETUNING_V1_NEG)

filterInputVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 21, 7, strInputNameFilterVoice1, $01, $00, sidUpdateFilterSwitchesAndResonance,
                      IID.FILTER_V1, IID.FILTER_RES, IID.FILTER_LOWPASS, IID.V3_ATC, IID.FILTER_V2)

filterInputVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 22, 7, strInputNameFilterVoice2, $01, $00, sidUpdateFilterSwitchesAndResonance,
                      IID.FILTER_V2, IID.FILTER_RES, IID.FILTER_HIGHPASS, IID.FILTER_V1, IID.FILTER_V3)

filterInputVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 23, 7, strInputNameFilterVoice3, $01, $00, sidUpdateFilterSwitchesAndResonance,
                      IID.FILTER_V3, IID.FILTER_RES, IID.FILTER_BANDWIDTH, IID.FILTER_V2, IID.DETUNING_V2)

filterInputLowpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 21, 7, strInputNameFilterLowpass, $01, $00, sidUpdateFilterModesAndVolume,
                      IID.FILTER_LOWPASS, IID.FILTER_V1, IID.MAIN_VOL, IID.V3_SUS, IID.FILTER_HIGHPASS)

filterInputHighpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 22, 7, strInputNameFilterHighpass, $00, $00, sidUpdateFilterModesAndVolume,
                      IID.FILTER_HIGHPASS, IID.FILTER_V2, IID.MAIN_VOL, IID.FILTER_LOWPASS, IID.FILTER_BANDWIDTH)

filterInputBandwidth:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 23, 7, strInputNameFilterBandwidth, $00, $00, sidUpdateFilterModesAndVolume,
                      IID.FILTER_BANDWIDTH, IID.FILTER_V3, IID.MAIN_VOL, IID.FILTER_HIGHPASS, IID.DETUNING_V2_NEG)

filterInputArray:
    .byte(<filterInputCutoff)
    .byte(>filterInputCutoff)
    .byte(<filterInputResonance)
    .byte(>filterInputResonance)
    .byte(<filterInputVoice1)
    .byte(>filterInputVoice1)
    .byte(<filterInputVoice2)
    .byte(>filterInputVoice2)
    .byte(<filterInputVoice3)
    .byte(>filterInputVoice3)
    .byte(<filterInputLowpass)
    .byte(>filterInputLowpass)
    .byte(<filterInputHighpass)
    .byte(>filterInputHighpass)
    .byte(<filterInputBandwidth)
    .byte(>filterInputBandwidth)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "MAIN"
 *
 * ---------------------------------------------------------------- */ 

mainInputVol:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 35, 22, 4, strInputNameMainVol, $0F, $00, sidUpdateFilterModesAndVolume,
                      IID.MAIN_VOL, IID.FILTER_BANDWIDTH, IID.FILTER_CUTOFF, IID.V3_RING, IID.DETUNING_V3_NEG)

mainInputArray:
    .byte(<mainInputVol)
    .byte(>mainInputVol)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "DETUNING"
 *
 * ---------------------------------------------------------------- */ 

detuningInputVoice1:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 1, 4, 6, strInputNameDetuningInputVoice1, $00, $00, pitchUpdateDetuningInputVoice1,
                      IID.DETUNING_V1, IID.DETUNING_V3_NEG, IID.DETUNING_V1_NEG, IID.FILTER_CUTOFF, IID.RESOSC_V1)

detuningInputDetuneDownVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 8, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice1,
                      IID.DETUNING_V1_NEG, IID.DETUNING_V1, IID.DETUNING_V2, IID.FILTER_RES, IID.RESOSC_V2)

detuningInputVoice2:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 14, 4, 6, strInputNameDetuningInputVoice2, $00, $00, pitchUpdateDetuningInputVoice2,
                      IID.DETUNING_V2, IID.DETUNING_V1_NEG, IID.DETUNING_V2_NEG, IID.FILTER_V3, IID.RESOSC_V3)

detuningInputDetuneDownVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice2,
                      IID.DETUNING_V2_NEG, IID.DETUNING_V2, IID.DETUNING_V3, IID.FILTER_BANDWIDTH, IID.RESOSC_V3)

detuningInputVoice3:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 27, 4, 6, strInputNameDetuningInputVoice3, $00, $00, pitchUpdateDetuningInputVoice3,
                      IID.DETUNING_V3, IID.DETUNING_V2_NEG, IID.DETUNING_V3_NEG, IID.FILTER_BANDWIDTH, IID.VELOCITY_USE)

detuningInputDetuneDownVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice3,
                      IID.DETUNING_V3_NEG, IID.DETUNING_V3, IID.DETUNING_V1, IID.MAIN_VOL, IID.VELOCITY_SUS)

detuningInputArray:
    .byte(<detuningInputVoice1)
    .byte(>detuningInputVoice1)
    .byte(<detuningInputDetuneDownVoice1)
    .byte(>detuningInputDetuneDownVoice1)
    .byte(<detuningInputVoice2)
    .byte(>detuningInputVoice2)
    .byte(<detuningInputDetuneDownVoice2)
    .byte(>detuningInputDetuneDownVoice2)
    .byte(<detuningInputVoice3)
    .byte(>detuningInputVoice3)
    .byte(<detuningInputDetuneDownVoice3)
    .byte(>detuningInputDetuneDownVoice3)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "RESET OSCILLATORS"
 *
 * ---------------------------------------------------------------- */ 

resetOscillatorVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 1, 10, 6, strInputNameResetOscillatorVoice1, $00, $00, sidUpdateResetOscillatorVoice1,
                      IID.RESOSC_V1, IID.VELOCITY_SUS, IID.RESOSC_V2, IID.DETUNING_V1, IID.LFO_CYCLE_LENGTH)

resetOscillatorVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 8, 10, 6, strInputNameResetOscillatorVoice2, $00, $00, sidUpdateResetOscillatorVoice2,
                      IID.RESOSC_V2, IID.RESOSC_V1, IID.RESOSC_V3, IID.DETUNING_V1_NEG, IID.LFO_MOD_PITCH)

resetOscillatorVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 15, 10, 6, strInputNameResetOscillatorVoice3, $00, $00, sidUpdateResetOscillatorVoice3,
                      IID.RESOSC_V3, IID.RESOSC_V2, IID.VELOCITY_USE, IID.DETUNING_V2, IID.LFO_MOD_PITCH)

resetOscillatorsInputArray:
    .byte(<resetOscillatorVoice1)
    .byte(>resetOscillatorVoice1)
    .byte(<resetOscillatorVoice2)
    .byte(>resetOscillatorVoice2)
    .byte(<resetOscillatorVoice3)
    .byte(>resetOscillatorVoice3)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "VELOCITY"
 *
 * ---------------------------------------------------------------- */ 

velocityUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 24, 10, 4, strInputNameVelocityUse, $00, $00, sidUpdateVelocityUse,
                      IID.VELOCITY_USE, IID.RESOSC_V3, IID.VELOCITY_SUS, IID.DETUNING_V3, IID.LFO_SQUARE_WAVE)

velocitySustain:
    createStructInput(INPUT_TYPE.BOOLEAN, 29, 10, 4, strInputNameVelocitySustain, $00, $00, sidUpdateVelocitySustain,
                      IID.VELOCITY_SUS, IID.VELOCITY_USE, IID.RESOSC_V1, IID.DETUNING_V3_NEG, IID.LFO_SQUARE_WAVE)

velocityInputArray:
    .byte(<velocityUse)
    .byte(>velocityUse)
    .byte(<velocitySustain)
    .byte(>velocitySustain)


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "LFO"
 *
 * ---------------------------------------------------------------- */ 

lfoCycleLength:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 1, 16, 6, strInputNameLfoCycleLength, $01, $00, lfoUpdateLfoCycleLengthValue,
                      IID.LFO_CYCLE_LENGTH, IID.LFO_MOD_WITH_V3_EG, IID.LFO_MOD_FILTER, IID.RESOSC_V1, IID.LFO_PITCH)

lfoModulatePitch:
    createStructInput(INPUT_TYPE.BOOLEAN, 9, 15, 10, strInputNameLfoModulatePitch, $00, $00, lfoUpdateLfoModulatePitchValue,
                      IID.LFO_MOD_PITCH, IID.LFO_CYCLE_LENGTH, IID.LFO_SQUARE_WAVE, IID.RESOSC_V2, IID.LFO_MOD_PULSE)

lfoModulatePulseWidth:
    createStructInput(INPUT_TYPE.BOOLEAN, 9, 16, 10, strInputNameLfoModulatePulseWidth, $00, $00, pulseWidthUpdateLfoModulatePulseWidthValue,
                      IID.LFO_MOD_PULSE, IID.LFO_CYCLE_LENGTH, IID.LFO_RESET_OSC, IID.LFO_MOD_PITCH, IID.LFO_MOD_FILTER)

lfoModulateFilter:
    createStructInput(INPUT_TYPE.BOOLEAN, 9, 17, 11, strInputNameLfoModulateFilter, $00, $00, filterUpdateLfoModulateFilterValue,
                      IID.LFO_MOD_FILTER, IID.LFO_CYCLE_LENGTH, IID.LFO_MOD_WITH_V3_EG, IID.LFO_MOD_PULSE, IID.LFO_PITCH_NEG)

lfoSquareWave:
    createStructInput(INPUT_TYPE.BOOLEAN, 22, 15, 12, strInputNameLfoSquareWave, $00, $00, lfoUpdateLfoSquareWaveValue,
                      IID.LFO_SQUARE_WAVE, IID.LFO_MOD_PITCH, IID.LFO_CYCLE_LENGTH, IID.VELOCITY_USE, IID.LFO_RESET_OSC)

lfoResetOscillator:
    createStructInput(INPUT_TYPE.BOOLEAN, 22, 16, 16, strInputNameLfoResetOscillator, $00, $00, lfoUpdateLfoResetOscillatorValue,
                      IID.LFO_RESET_OSC, IID.LFO_MOD_PULSE, IID.LFO_CYCLE_LENGTH, IID.LFO_SQUARE_WAVE, IID.LFO_MOD_WITH_V3_EG)

lfoModulateWithVoice3Envelope:
    createStructInput(INPUT_TYPE.BOOLEAN, 22, 17, 15, strInputNameLfoModulateWithVoice3Envelope, $00, $00, lfoUpdateLfoModulateWithVoice3EnvelopeValue,
                      IID.LFO_MOD_WITH_V3_EG, IID.LFO_MOD_FILTER, IID.LFO_CYCLE_LENGTH, IID.LFO_RESET_OSC, IID.LFO_MUTE_VOICE_3)

lfoInputMuteVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 22, 18, 13, strInputNameLfoInputMuteVoice3, $00, $00, sidUpdateFilterModesAndVolume,
                      IID.LFO_MUTE_VOICE_3, IID.LFO_MOD_FILTER, IID.LFO_CYCLE_LENGTH, IID.LFO_MOD_WITH_V3_EG, IID.LFO_PULSE_NEG)

lfoPitch:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 1, 22, 6, strInputNameLfoPitch, $01, $00, lfoUpdateLfoPitchValue,
                      IID.LFO_PITCH, IID.LFO_CUTOFF_NEG, IID.LFO_PITCH_NEG, IID.LFO_CYCLE_LENGTH, IID.V1_WAVE)

lfoPitchNegative:
    createStructInput(INPUT_TYPE.BOOLEAN, 8, 23, 5, strInputNameLfoPitchNegative, $00, $00, lfoUpdateLfoPitchNegativeValue,
                      IID.LFO_PITCH_NEG, IID.LFO_PITCH, IID.LFO_PULSE, IID.LFO_MOD_FILTER, IID.V1_PULSE)

lfoPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 14, 22, 6, strInputNameLfoPulseWidth, $FF, $0F, pulseWidthUpdateLfoPulseWidthValue,
                      IID.LFO_PULSE, IID.LFO_PITCH_NEG, IID.LFO_PULSE_NEG, IID.LFO_MOD_FILTER, IID.V1_ATC)

lfoPulseWidthNegative:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 23, 5, strInputNameLfoPulseWidthNegative, $00, $00, pulseWidthUpdateLfoPulseWidthNegativeValue,
                      IID.LFO_PULSE_NEG, IID.LFO_PULSE, IID.LFO_CUTOFF, IID.LFO_MUTE_VOICE_3, IID.V1_SUS)

lfoFilterCutoff:
    createStructInput(INPUT_TYPE.INTEGER_11_BITS, 27, 22, 6, strInputNameLfoFilterCutoff, $FF, $07, filterUpdateLfoFilterCutoffValue,
                      IID.LFO_CUTOFF, IID.LFO_PULSE_NEG, IID.LFO_CUTOFF_NEG, IID.LFO_MUTE_VOICE_3, IID.V1_RLS)

lfoFilterCutoffNegative:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 23, 5, strInputNameLfoFilterCutoffNegative, $00, $00, filterUpdateLfoFilterCutoffNegativeValue,
                      IID.LFO_CUTOFF_NEG, IID.LFO_CUTOFF, IID.LFO_CYCLE_LENGTH, IID.LFO_MUTE_VOICE_3, IID.V1_USE)

lfoInputArray:
    .byte(<lfoCycleLength)
    .byte(>lfoCycleLength)
    .byte(<lfoModulatePitch)
    .byte(>lfoModulatePitch)
    .byte(<lfoModulatePulseWidth)
    .byte(>lfoModulatePulseWidth)
    .byte(<lfoModulateFilter)
    .byte(>lfoModulateFilter)
    .byte(<lfoSquareWave)
    .byte(>lfoSquareWave)
    .byte(<lfoResetOscillator)
    .byte(>lfoResetOscillator)
    .byte(<lfoModulateWithVoice3Envelope)
    .byte(>lfoModulateWithVoice3Envelope)
    .byte(<lfoInputMuteVoice3)
    .byte(>lfoInputMuteVoice3)
    .byte(<lfoPitch)
    .byte(>lfoPitch)
    .byte(<lfoPitchNegative)
    .byte(>lfoPitchNegative)
    .byte(<lfoPulseWidth)
    .byte(>lfoPulseWidth)
    .byte(<lfoPulseWidthNegative)
    .byte(>lfoPulseWidthNegative)
    .byte(<lfoFilterCutoff)
    .byte(>lfoFilterCutoff)
    .byte(<lfoFilterCutoffNegative)
    .byte(>lfoFilterCutoffNegative)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE1"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice1:
    createStructModule(strModuleNameVoice1, 0,  2, 38, 3, GRAY, 9, voice1InputArray, 0)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE2"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice2:
    createStructModule(strModuleNameVoice2, 0,  8, 38, 3, GRAY, 9, voice2InputArray, 0)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE3"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice3:
    createStructModule(strModuleNameVoice3, 0, 14, 38, 3, GRAY, 9, voice3InputArray, 0)


/* -------------------------------------------------------------------
 *
 * Definition of module "FILTER"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleFilter:
    createStructModule(strModuleNameFilter, 0, 20, 31, 3, LIGHT_RED, 8, filterInputArray, 0)


/* -------------------------------------------------------------------
 *
 * Definition of module "MAIN"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleMain:
    createStructModule(strModuleNameMain,  34, 20,  4, 3, PURPLE, 1, mainInputArray, 0)


/* -------------------------------------------------------------------
 *
 * Definition of module "DETUNING"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleDetuning:
    createStructModule(strModuleNameDetuning, 0,  2, 38, 3, GRAY, 6, detuningInputArray, 1)


/* -------------------------------------------------------------------
 *
 * Definition of module "RESET OSCILLATORS"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleResetOscillators:
    createStructModule(strModuleNameResetOscillators, 0,  9, 20, 1, GRAY, 3, resetOscillatorsInputArray, 1)


/* -------------------------------------------------------------------
 *
 * Definition of module "VELOCITY"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVelocity:
    createStructModule(strModuleNameVelocity, 23,  9, 15, 1, GRAY, 2, velocityInputArray, 1)


/* -------------------------------------------------------------------
 *
 * Definition of module LFO
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleLfo:
    createStructModule(strModuleNameLfo, 0,  14, 38, 9, LIGHT_RED, 14, lfoInputArray, 1)


/* -------------------------------------------------------------------
 *
 * List of all the modules
 *
 * Type: Array of 16-bit pointers
 *
 * ---------------------------------------------------------------- */ 

modules:
    .byte(<moduleVoice1)
    .byte(>moduleVoice1)
    .byte(<moduleVoice2)
    .byte(>moduleVoice2)
    .byte(<moduleVoice3)
    .byte(>moduleVoice3)
    .byte(<moduleFilter)
    .byte(>moduleFilter)
    .byte(<moduleMain)
    .byte(>moduleMain)
    .byte(<moduleDetuning)
    .byte(>moduleDetuning)
    .byte(<moduleResetOscillators)
    .byte(>moduleResetOscillators)
    .byte(<moduleVelocity)
    .byte(>moduleVelocity)
    .byte(<moduleLfo)
    .byte(>moduleLfo)


/* -------------------------------------------------------------------
 *
 * Number of modules
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

modulesNum:
    .byte($09)


/* -------------------------------------------------------------------
 *
 * The index of the currently selected module
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentModuleIndex:
    .byte($00)


/* -------------------------------------------------------------------
 *
 * The index of the currently selected input in the currently
 * selected module
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentInputIndex:
    .byte($00)


/* -------------------------------------------------------------------
 *
 * The content of the input editor
 *
 * Type: Null-terminated string (max. 4 characters)
 *
 * ---------------------------------------------------------------- */ 

currentInputEditorText:
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)
    .byte(0)


/* -------------------------------------------------------------------
 *
 * The current values of the SID waveform control registers
 * (voice 1 through 3)
 *
 * Because we need to change the gate bit (bit 0  of the waveform
 * register) on every note-change - but the control registers of 
 * the SID chip are write-only - we have to store it here globally.
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentWaveFormControlRegisterVoice1:
    .byte(0)

sidCurrentWaveFormControlRegisterVoice2:
    .byte(0)

sidCurrentWaveFormControlRegisterVoice3:
    .byte(0)



/* -------------------------------------------------------------------
 *
 * The current values of the "Use voice" inputs (voices 1 through 3)
 *
 * Saved here globally so the values are easier (and computational faster)
 * to access, because we need to check these values often
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentActiveVoice1:
    .byte(0)

sidCurrentActiveVoice2:
    .byte(0)

sidCurrentActiveVoice3:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * The current values of the "Reset oscillator" inputs (voices 1 through 3)
 *
 * Saved here globally so the values are easier (and computational faster)
 * to access, because we need to check these values often
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentResetOscillatorVoice1:
    .byte(0)

sidCurrentResetOscillatorVoice2:
    .byte(0)

sidCurrentResetOscillatorVoice3:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Indiactes if an MIDI interface is present and should be used
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

midiDetectedCartridge:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * 128 byte ring buffer for recieved MIDI bytes
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

.label MIDI_BUFFER_SIZE = 128
.label MIDI_BUFFER_MASK = MIDI_BUFFER_SIZE - 1

midiBuffer:
    .fill MIDI_BUFFER_SIZE, 0

midiWritePtr:
    .byte(0)

midiReadPtr:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Value of the status of the current MIDI message
 * (also used as running status)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiCurrentStatus:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Buffer to hold the data bytes of the current MIDI message (max. 2)
 *
 * Type: Array of bytes
 *
 * ---------------------------------------------------------------- */ 

midiDataBuffer:
midiDataBufferFirstByte:
    .byte(0)
midiDataBufferSecondByte:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Current number of bytes in the MIDI data byte buffer
 *
 * Type: Integer (zero means buffer is empty)
 *
 * ---------------------------------------------------------------- */ 

midiDataBufferCount:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Number of expected data bytes for the current MIDI message (0-2)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiExpectedDataBytes:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Flag to indicate that the current MIDI message should be ignored
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

midiIgnoreDataBytesUntilNewStatus:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Contains the number of the current MIDI message (see constants.asm)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiCurrentMessage:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Contains the number of the current MIDI channel (255 for any channel)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiChannel:
    .byte(255)


/* -------------------------------------------------------------------
 *
 * Buffer to remember the last played notes (currently played/to play last,
 * oldest note first)
 *
 * Type: Array of bytes
 *
 * ---------------------------------------------------------------- */ 

midiActiveNotesBuffer:
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


/* -------------------------------------------------------------------
 *
 * Number of notes in buffer 
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiActiveNotesNum:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of MIDI the pitch bend controller (converted to cent) 
 *
 * Type: 16-bit signed integer
 *
 * ---------------------------------------------------------------- */ 

midiPitchBendValue:
midiPitchBendValueLo:
    .byte(0)
midiPitchBendValueHi:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Flag to keep track if the MIDI pitch bend value has changed
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

midiPitchBendValueChangedFlag:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current values of the frequencies voice 1 trough 3
 *
 * Type: array of 16-bit integers
 *
 * ---------------------------------------------------------------- */ 

voiceFrequencies:
voice1Frequeny:
voice1FrequenyLo:
    .byte(0)
voice1FrequenyHi:
    .byte(0)
voice2Frequeny:
voice2FrequenyLo:
    .byte(0)
voice2FrequenyHi:
    .byte(0)
voice3Frequeny:
voice3FrequenyLo:
    .byte(0)
voice3FrequenyHi:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current values of the detuning for voice 1 trough 3 in cent
 *
 * Type: array of 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

voiceDetunings:
voice1Detuning:
voice1DetuningLo:
    .byte(0)
voice1DetuningHi:
    .byte(0)
voice2Detuning:
voice2DetuningLo:
    .byte(0)
voice2DetuningHi:
    .byte(0)
voice3Detuning:
voice3DetuningLo:
    .byte(0)
voice3DetuningHi:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the global detuning in cent
 *
 * Type: 16-bit signed integer
 *
 * ---------------------------------------------------------------- */ 

globalDetuning:
globalDetuningLo:
    .byte(0)
globalDetuningHi:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input "mod pulse"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentLfoModulatePulseWidth:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input "pulse"
 *
 * Type: 16 bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentLfoPulseWidth:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input (pulse) "neg"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentLfoPulseWidthNegative:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input "mod filter"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentLfoModulateFilter:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input "cutoff"
 *
 * Type: 16 bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentLfoFilterCutoff:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current value of the LFO input (cutoff) "neg"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentLfoFilterCutoffNegative:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current values of the pulse width for voice 1 trough 3
 *
 * Types: 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

sidCurrentVoice1PulseWidth:
    .word(0)

sidCurrentVoice2PulseWidth:
    .word(0)

sidCurrentVoice3PulseWidth:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current values of the calculated modulated pulse width for voice 1 trough 3
 *
 * Types: 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

sidCurrentVoice1ModulatedPulseWidth:
    .word(0)

sidCurrentVoice2ModulatedPulseWidth:
    .word(0)

sidCurrentVoice3ModulatedPulseWidth:
    .word(0)   


/* -------------------------------------------------------------------
 *
 * current value of the filter cutoff frequency
 *
 * Type: 16-bit signed integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentFilterCutoffFrequency:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current value of the calculated modulated filter cutoff frequency
 *
 * Type: 16-bit signed integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentModulatedFilterCutoffFrequency:
    .word(0)    


/* -------------------------------------------------------------------
 *
 * current value of the calculated filter modes
 * (upper 4 bits of the corresponding register)
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentFilterModesValue:
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * current value of the main volume
 * (lower 4 bits of the corresponding register)
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

sidCurrentMainVolumeValue:
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * current value of of the use velocity input field
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentVelocityUse:
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * current value of of the use velocity for sustain input field
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentVelocitySustain:
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * index of the currently active patch
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentPatchIndex:
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * address of the currently active patch
 *
 * Type: 16-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentPatchAddress:
    .byte(0)    
    .byte(0)    


/* -------------------------------------------------------------------
 *
 * current values of the patch selector
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentPatchSelectorColumn:
    .byte(0)

currentPatchSelectorRow:
    .byte(0)

currentPatchSelectorIndex:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current values of the main menu
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentMenuIndex:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Device number from which the program was startet
 *
 * Type: Unsigned integer
 *
 * ---------------------------------------------------------------- */ 

diskDriveDeviceNumber:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Buffer to hold the last disk drive error message
 *
 * Type: 40 byte buffer
 *
 * ---------------------------------------------------------------- */ 

diskDriveErrorBuffer:
    .fill 40, 0


/* -------------------------------------------------------------------
 *
 * Length of error message in the disk drive error message buffer
 *
 * Type: 8-bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

diskDriveErrorLength:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Global variables for the main menu`s input editor
 *
 * ---------------------------------------------------------------- */ 

menuInputEditorBuffer:
    .fill 9, 0

menuInputEditorX:
    .byte(0)

menuInputEditorY:
    .byte(0)

menuInputEditorMaxLength:
    .byte(0)

menuInputEditorAllowedCharactersMin:
    .byte(0)

menuInputEditorAllowedCharactersMax:
    .byte(0)    



/* -------------------------------------------------------------------
 *
 * Global variables for the LFO
 *
 * ---------------------------------------------------------------- */ 

lfoCycleLengthValue:
    .word(0)

lfoModuloInc:
    .word(0)

lfoModuloCounter:
    .word(0)

lfoValue:
    .byte(0)

lfoSquareWaveValue:
    .byte(0)

lfoResetOscillatorValue:
    .byte(0)

lfoModulateWithVoice3EnvelopeValue:
    .byte(0)

lfoModulatePitchValue:
    .byte(0)

lfoPitchValue:
    .word(0)

lfoPitchNegativeValue:
    .byte(0)
