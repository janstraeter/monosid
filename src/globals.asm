#importonce

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
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 4, 5, strInputNameVoiceWaveform, WAVEFORM.SQUARE, $00, sidUpdateVoice1WaveFormControl)

voice1InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 4, 6, strInputNameVoicePulseWidth, $00, $00, sidUpdateVoice1PulseWidth)

voice1InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 4, 4, strInputNameVoiceAttack, $00, $00, sidUpdateVoice1AttackDecay)

voice1InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 4, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice1AttackDecay)

voice1InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 4, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice1SustainRelease)

voice1InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 4, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice1SustainRelease)

voice1InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 3, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice1WaveFormControl)

voice1InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 4, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice1WaveFormControl)

voice1InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 5, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice1WaveFormControl)

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
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 10, 5, strInputNameVoiceWaveform, WAVEFORM.TRIANGULAR, $00, sidUpdateVoice2WaveFormControl)

voice2InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 10, 6, strInputNameVoicePulseWidth, $FF, $00, sidUpdateVoice2PulseWidth)

voice2InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 10, 4, strInputNameVoiceAttack, $00, $00, sidUpdateVoice2AttackDecay)

voice2InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 10, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice2AttackDecay)

voice2InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 10, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice2SustainRelease)

voice2InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 10, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice2SustainRelease)

voice2InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 9, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice2WaveFormControl)

voice2InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 10, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice2WaveFormControl)

voice2InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 11, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice2WaveFormControl)

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
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 16, 5, strInputNameVoiceWaveform, WAVEFORM.TRIANGULAR, $00, sidUpdateVoice3WaveFormControl)

voice3InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 16, 6, strInputNameVoicePulseWidth, $F0, $0F, sidUpdateVoice3PulseWidth)

voice3InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 16, 4, strInputNameVoiceAttack, $0C, $00, sidUpdateVoice3AttackDecay)

voice3InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 16, 4, strInputNameVoiceDecay, $00, $00, sidUpdateVoice3AttackDecay)

voice3InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 16, 4, strInputNameVoiceSustain, $0F, $00, sidUpdateVoice3SustainRelease)

voice3InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 16, 4, strInputNameVoiceRelease, $0A, $00, sidUpdateVoice3SustainRelease)

voice3InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 15, 4, strInputNameVoiceUse, $01, $00, sidUpdateVoice3WaveFormControl)

voice3InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 16, 4, strInputNameVoiceSync, $00, $00, sidUpdateVoice3WaveFormControl)

voice3InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 17, 4, strInputNameVoiceRingMod, $00, $00, sidUpdateVoice3WaveFormControl)

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
    createStructInput(INPUT_TYPE.INTEGER_11_BITS, 1, 22, 6, strInputNameFilterCutoff, $F0, $07, sidUpdateFilterCutoffFrequency)

filterInputResonance:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 8, 22, 4, strInputNameFilterResonance, $00, $00, sidUpdateFilterSwitchesAndResonance)

filterInputVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 21, 7, strInputNameFilterVoice1, $00, $00, sidUpdateFilterSwitchesAndResonance)

filterInputVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 22, 7, strInputNameFilterVoice2, $00, $00, sidUpdateFilterSwitchesAndResonance)

filterInputVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 23, 7, strInputNameFilterVoice3, $00, $00, sidUpdateFilterSwitchesAndResonance)

filterInputLowpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 21, 7, strInputNameFilterLowpass, $00, $00, sidUpdateFilterModesAndVolume)

filterInputHighpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 22, 7, strInputNameFilterHighpass, $00, $00, sidUpdateFilterModesAndVolume)

filterInputBandwidth:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 23, 7, strInputNameFilterBandwidth, $00, $00, sidUpdateFilterModesAndVolume)

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
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 35, 22, 4, strInputNameMainVol, $0F, $00, sidUpdateFilterModesAndVolume)

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
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 1, 4, 6, strInputNameDetuningInputVoice1, $00, $00, pitchUpdateDetuningInputVoice1)

detuningInputDetuneDownVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 8, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice1)

detuningInputVoice2:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 13, 4, 6, strInputNameDetuningInputVoice2, $00, $00, pitchUpdateDetuningInputVoice2)

detuningInputDetuneDownVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 20, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice2)

detuningInputVoice3:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 26, 4, 6, strInputNameDetuningInputVoice3, $00, $00, pitchUpdateDetuningInputVoice3)

detuningInputDetuneDownVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 33, 5, 5, strInputNameDetuningInputDetuneDownVoice, $00, $00, pitchUpdateDetuningInputVoice3)

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
    createStructInput(INPUT_TYPE.BOOLEAN, 1, 10, 8, strInputNameResetOscillatorVoice1, $00, $00, sidUpdateResetOscillatorVoice1)

resetOscillatorVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 10, 10, 8, strInputNameResetOscillatorVoice2, $00, $00, sidUpdateResetOscillatorVoice2)

resetOscillatorVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 19, 10, 8, strInputNameResetOscillatorVoice3, $00, $00, sidUpdateResetOscillatorVoice3)

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
 * for the module "VOICE 3 SPECIAL FEATURES"
 *
 * ---------------------------------------------------------------- */ 

voice3FeaturesInputMuteVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 1, 15, 13, strInputNameVoice3FeaturesInputMuteVoice3, $01, $00, sidUpdateFilterModesAndVolume)

voice3FeaturesModulatePulseWidth:
    createStructInput(INPUT_TYPE.BOOLEAN, 1, 16, 14, strInputNameVoice3FeaturesModulatePulseWidth, $01, $00, pulseWidthUpdateVoice3EnvelopeModulatePulseWidthValue)

voice3FeaturesModulateFilter:
    createStructInput(INPUT_TYPE.BOOLEAN, 1, 17, 15, strInputNameVoice3FeaturesModulateFilter, $00, $00, filterUpdateVoice3EnvelopeModulateFilterValue)

voice3FeaturesPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 15, 16, 6, strInputNameVoice3FeaturesPulseWidth, $FF, $0F, pulseWidthUpdateVoice3PulseWidthValue)

voice3FeaturesPulseWidthNegative:
    createStructInput(INPUT_TYPE.BOOLEAN, 22, 17, 5, strInputNameVoice3FeaturesPulseWidthNegative, $00, $00, pulseWidthUpdateVoice3PulseWidthNegativeValue)

voice3FeaturesFilterCutoff:
    createStructInput(INPUT_TYPE.INTEGER_11_BITS, 28, 16, 6, strInputNameVoice3FeaturesFilterCutoff, $00, $00, filterUpdateVoice3FilterCutoffValue)

voice3FeaturesFilterCutoffNegative:
    createStructInput(INPUT_TYPE.BOOLEAN, 35, 17, 5, strInputNameVoice3FeaturesFilterCutoffNegative, $00, $00, filterUpdateVoice3FilterCutoffNegativeValue)

voice3FeaturesInputArray:
    .byte(<voice3FeaturesInputMuteVoice3)
    .byte(>voice3FeaturesInputMuteVoice3)
    .byte(<voice3FeaturesModulatePulseWidth)
    .byte(>voice3FeaturesModulatePulseWidth)
    .byte(<voice3FeaturesModulateFilter)
    .byte(>voice3FeaturesModulateFilter)
    .byte(<voice3FeaturesPulseWidth)
    .byte(>voice3FeaturesPulseWidth)
    .byte(<voice3FeaturesPulseWidthNegative)
    .byte(>voice3FeaturesPulseWidthNegative)
    .byte(<voice3FeaturesFilterCutoff)
    .byte(>voice3FeaturesFilterCutoff)
    .byte(<voice3FeaturesFilterCutoffNegative)
    .byte(>voice3FeaturesFilterCutoffNegative)


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
    createStructModule(strModuleNameResetOscillators, 0,  9, 38, 1, GRAY, 3, resetOscillatorsInputArray, 1)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE 3 SPECIAL FEATURES"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice3Features:
    createStructModule(strModuleNameVoice3Features, 0,  14, 38, 3, LIGHT_RED, 7, voice3FeaturesInputArray, 1)


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
    .byte(<moduleVoice3Features)
    .byte(>moduleVoice3Features)


/* -------------------------------------------------------------------
 *
 * Number of modules
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

modulesNum:
    .byte($08)


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

currentSidWaveFormControlRegisterVoice1:
    .byte(0)

currentSidWaveFormControlRegisterVoice2:
    .byte(0)

currentSidWaveFormControlRegisterVoice3:
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

currentSidActiveVoice1:
    .byte(0)

currentSidActiveVoice2:
    .byte(0)

currentSidActiveVoice3:
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

currentSidResetOscillatorVoice1:
    .byte(0)

currentSidResetOscillatorVoice2:
    .byte(0)

currentSidResetOscillatorVoice3:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Indiactes if an MIDI interface is present and should be used
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

midiInterfacePresent:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Address of the control register of the MIDI interface
 *
 * Type: 16 bit address
 *
 * ---------------------------------------------------------------- */ 

midiInterfaceControlRegister:
    .byte(0)
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Address of the status register of the MIDI interface
 *
 * Type: 16 bit address
 *
 * ---------------------------------------------------------------- */ 

midiInterfaceStatusRegister:
    .byte(0)
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Address of the recieve register of the MIDI interface
 *
 * Type: 16 bit address
 *
 * ---------------------------------------------------------------- */ 

midiInterfaceRecieveRegister:
    .byte(0)
    .byte(0)


/* -------------------------------------------------------------------
 *
 * Value of the last recieved byte
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

midiLastRecievedByte:
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
 * current value of the "voice 3 special features" input "mod pulse"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentVoice3EnvelopeModulatePulseWidth:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the "voice 3 special features" input "pulse"
 *
 * Type: 16 bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentVoice3PulseWidth:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current value of the "voice 3 special features" input (pulse) "neg"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentVoice3PulseWidthNegative:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the "voice 3 special features" input "mod filter"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentVoice3EnvelopeModulateFilter:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current value of the "voice 3 special features" input "cutoff"
 *
 * Type: 16 bit unsigned integer
 *
 * ---------------------------------------------------------------- */ 

currentVoice3FilterCutoff:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current value of the "voice 3 special features" input (cutoff) "neg"
 *
 * Type: boolean
 *
 * ---------------------------------------------------------------- */ 

currentVoice3FilterCutoffNegative:
    .byte(0)


/* -------------------------------------------------------------------
 *
 * current values of the pulse width for voice 1 trough 3
 *
 * Types: 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

currentSidVoice1PulseWidth:
    .word(0)

currentSidVoice2PulseWidth:
    .word(0)

currentSidVoice3PulseWidth:
    .word(0)


/* -------------------------------------------------------------------
 *
 * current values of the calculated modulated pulse width for voice 1 trough 3
 *
 * Types: 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

currentSidVoice1ModulatedPulseWidth:
    .word(0)

currentSidVoice2ModulatedPulseWidth:
    .word(0)

currentSidVoice3ModulatedPulseWidth:
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