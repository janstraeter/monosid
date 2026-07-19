#importonce

/* -------------------------------------------------------------------
 *
 * All the uppercase null-terminated strings used in the program
 *
 * ---------------------------------------------------------------- */ 

.encoding "screencode_upper"

strInfoBarF1:
	.byte $76, $86, $B1, $61, $00

strInfoBarMenu:
    .text "MENU"
    .byte $00

strInfoBarF3:
	.byte $76, $86, $B3, $61, $00

strInfoBarPatch:
    .text "PATCH"
    .byte $00

strInfoBarOct:
	.text "OCT:"
	.byte $00

strMonosid:
    .text "MONOSID"
    .byte $00

strModuleNameVoice1:
    .text "VOICE 1"
    .byte $00

strModuleNameVoice2:
    .text "VOICE 2"
    .byte $00

strModuleNameVoice3:
    .text "VOICE 3"
    .byte $00

strModuleNameFilter:
    .text "FILTER"
    .byte $00

strModuleNameMain:  
    .text "MAIN"
    .byte $00

strModuleNameDetuning:  
    .text "DETUNING"
    .byte $00

strModuleNameResetOscillators:  
    .text "RESET OSCILLATORS"
    .byte $00

strModuleNameVelocity:  
    .text "VELOCITY"
    .byte $00

strModuleNameLfo:
    .text "LFO"
    .byte $00

strInputNameVoiceWaveform:   
    .text "WAVE"
    .byte $00

strInputNameVoicePulseWidth: 
    .text "PULSE"
    .byte $00

strInputNameVoiceAttack:     
    .text "ATC"
    .byte $00

strInputNameVoiceDecay:      
    .text "DCY"
    .byte $00

strInputNameVoiceSustain:    
    .text "SUS"
    .byte $00

strInputNameVoiceRelease:    
    .text "RLS"
    .byte $00

strInputNameVoiceUse:        
    .text "USE"
    .byte $00

strInputNameVoiceSync:       
    .text "SYNC"
    .byte $00

strInputNameVoiceRingMod:    
    .text "RING"
    .byte $00

strInputNameFilterCutoff:    
    .text "CUTOFF"
    .byte $00

strInputNameFilterResonance: 
    .text "RES"
    .byte $00

strInputNameFilterVoice1:    
    .text "VOICE1"
    .byte $00

strInputNameFilterVoice2:    
    .text "VOICE2"
    .byte $00

strInputNameFilterVoice3:    
    .text "VOICE3"
    .byte $00

strInputNameFilterLowpass:   
    .text "LOWPASS"
    .byte $00

strInputNameFilterHighpass:  
    .text "HIGHPASS"
    .byte $00

strInputNameFilterBandwidth: 
    .text "BANDWIDTH"
    .byte $00

strInputNameMainVol:         
    .text "VOL"
    .byte $00

strInputNameDetuningInputVoice1:         
    .text "VOICE 1"
    .byte $00

strInputNameDetuningInputVoice2:         
    .text "VOICE 2"
    .byte $00

strInputNameDetuningInputVoice3:         
    .text "VOICE 3"
    .byte $00

strInputNameDetuningInputDetuneDownVoice:
    .text "NEG"
    .byte $00

strInputNameResetOscillatorVoice1:         
    .text "VOC 1"
    .byte $00

strInputNameResetOscillatorVoice2:         
    .text "VOC 2"
    .byte $00

strInputNameResetOscillatorVoice3:         
    .text "VOC 3"
    .byte $00

strInputNameVelocityUse:
    .text "USE"
    .byte $00

strInputNameVelocitySustain:
    .text "SUSTAIN"
    .byte $00

strInputNameLfoModulatePitch:
    .text "MOD PITCH"
    .byte $00

strInputNameLfoModulatePulseWidth:
    .text "MOD PULSE"
    .byte $00

strInputNameLfoModulateFilter:
    .text "MOD FILTER"
    .byte $00

strInputNameLfoSquareWave:
    .text "SQUARE WAVE"
    .byte $00

strInputNameLfoResetOscillator:
    .text "RESET OSCILLATOR"
    .byte $00

strInputNameLfoModulateWithVoice3Envelope:
    .text "MOD WITH V3 EG"
    .byte $00

strInputNameLfoInputMuteVoice3:
    .text "MUTE VOICE 3"
    .byte $00

strInputNameLfoCycleLength:
    .text "LENGTH"
    .byte $00

strInputNameLfoPitch:
    .text "PITCH"
    .byte $00

strInputNameLfoPitchNegative:
    .text "NEG"
    .byte $00

strInputNameLfoPulseWidth:
    .text "PULSE"
    .byte $00

strInputNameLfoPulseWidthNegative:
    .text "NEG"
    .byte $00

strInputNameLfoFilterCutoff:
    .text "CUTOFF"
    .byte $00

strInputNameLfoFilterCutoffNegative:
    .text "NEG"
    .byte $00

strWaveformTriangular:
    .byte 148, 146, 137, 0

strWaveformSawtooth:
    .byte 147, 129, 151, 0

strWaveformSquare:
    .byte 147, 145, 146, 0

strWaveformNoise:
    .byte 142, 147, 133, 0

strPatchEmptyName:
    .text "EMPTY-"
    .byte $00

strPatchNumbers:
    .text "01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364"
    .byte $00

strPatchSelectorHeadline:
    .text "SELECT PATCH"
    .byte(0)

strRenamePatchHeadline:
    .text "RENAME CURRENT PATCH"
    .byte(0)

strRenamePatchCurrentName:
    .text "CURRENT NAME:"
    .byte(0)
    
strRenamePatchNewName:
    .text "NEW NAME"
    .byte(0)

strRenamePatchInfo:
    .text "LEAVE BLANK TO KEEP CURRENT NAME"
    .byte(0)

strSetMidiChannelHeadline:
    .text "SET MIDI CHANNEL"
    .byte(0)

strSetMidiChannelInfo1:
    .text "POSSIBLE VALUES 1-16"
    .byte(0)

strSetMidiChannelInfo2:
    .text "LEAVE BLANK TO LISTEN TO ALL CHANNELS"
    .byte(0)


/* -------------------------------------------------------------------
 *
 * All the mixed case null-terminated strings used in the program
 *
 * ---------------------------------------------------------------- */ 

.encoding "screencode_mixed"

strVersion:
    .text "V1.0"
    .byte(0)

strMainMenuSavePatchesToDisk:
    .text "Save patches to disk"
    .byte(0)

strMainMenuLoadPatchesFromDisk:
    .text "Load patches from disk"
    .byte(0)

strMainMenuRenameCurrentPatch:
    .text "Rename current patch"
    .byte(0)

strMainMenuClearCurrentPatch:
    .text "Clear current patch"
    .byte(0)

strMainMenuSetMidiChannel:
    .text "Set MIDI channel"
    .byte(0)

strMainMenuReturn:
    .text "Return"
    .byte(0)

strMainMenuDevelopedBy:
    .text "developed 2026 by Jan Straeter"
    .byte(0)

strMainMenuWebsite:
    .text "monosid.janstraeter.de"
    .byte(0)

strMainMenuFocusedItem:
    .text ">"
    .byte(0)

strPatchesLoading:
    .text "Loading patches from disk"
    .byte(0)

strPatchesSaving:
    .text "Saving patches to disk"
    .byte(0)

strPatches01Of64:
    .text "01/64"
    .byte(0)

strDiskError:
    .text "DISK ERROR"
    .byte(0)

strKernalFileOpenError:
    .text "No disk drive found"
    .byte(0)

strErrorPressAnyKey:
    .text "Press any key to return to menu"
    .byte(0)

strMidiInfoHeadline:
    .text "MIDI"
    .byte(0)

strMidiDetectedCartridge:
    .text "Cartridge:"
    .byte(0)

strMidiCartridgeNone:
    .text "None"
    .byte(0)

strMidiCartridgeSequential:
    .text "Sequential"
    .byte(0)

strMidiCartridgeNamesoft:
    .text "Namesoft"
    .byte(0)

strMidiCartridgeDatel:
    .text "DATEL/Siel/JMS"
    .byte(0)

strMidiCartridgePassport:
    .text "Passport/Syntech"
    .byte(0)

strMidiCartridgeMaplin:
    .text "Maplin"
    .byte(0)

strMidiChannel:
    .text "Channel:"
    .byte(0)

strMidiChannelAny:
    .text "Any"
    .byte(0)
