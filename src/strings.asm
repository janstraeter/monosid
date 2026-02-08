#importonce

/* -------------------------------------------------------------------
 *
 * All the null-terminated strings used in the program
 *
 * ---------------------------------------------------------------- */ 

.encoding "screencode_upper"

strMenu:
	.byte $5f, $a0, $8d, $85, $8e, $95, $a0, $69, $00

strOctave:
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

strModuleNameVoice3Features:
    .text "VOICE 3 SPECIAL FEATURES"
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
    .text "VOICE 1"
    .byte $00

strInputNameResetOscillatorVoice2:         
    .text "VOICE 2"
    .byte $00

strInputNameResetOscillatorVoice3:         
    .text "VOICE 3"
    .byte $00

strInputNameVoice3FeaturesInputMuteVoice3:
    .text "MUTE VOC 3"
    .byte $00

strInputNameVoice3FeaturesModulatePulseWidth:
    .text "MOD PULSE"
    .byte $00

strInputNameVoice3FeaturesModulateFilter:
    .text "MOD FILTER"
    .byte $00

strInputNameVoice3FeaturesPulseWidth:
    .text "PULSE"
    .byte $00

strInputNameVoice3FeaturesPulseWidthNegative:
    .text "NEG"
    .byte $00

strInputNameVoice3FeaturesFilterCutoff:
    .text "CUTOFF"
    .byte $00

strInputNameVoice3FeaturesFilterCutoffNegative:
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
