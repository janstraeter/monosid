#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Initializes all patches with standard values
 *
 * ---------------------------------------------------------------- */ 

patchesInit:
{
    lda #0
    sta patchIndex

patchLoop:
    lda patchIndex
    jsr patchesInitPatch

    inc patchIndex
    lda #PATCH_NUM
    cmp patchIndex
    bne patchLoop

    rts

patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Initializes a single patch with sane standard values
 *
 * Parameters: Accu - zero-based index of the patch
 *
 * ---------------------------------------------------------------- */ 

patchesInitPatch:
{
    // save patch index from accu
    sta patchIndex
    
    // pointer to the patch data into ZPR_8
    jsr patchesLoadPatchMemoryAddressIntoZPR8
        
    // fill the patch with zeros
    ldy #0
    lda #0

memoryLoop:
    sta (ZPR_8), y
    iny
    cpy #PATCH_MEMORY_SIZE
    bne memoryLoop

    // ----------------------------------------------------------
    // init the fields which should not be zero with standard values
    // ----------------------------------------------------------

    // voice 1
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_1_INPUT_USE, 1)
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_1_INPUT_WAVEFORM, 1)
    structWriteWordValue(ZPR_8, STRUCT_PATCH.VOICE_1_INPUT_PULSEWIDTH, 2047)
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_1_INPUT_SUSTAIN, 15)

    // voice 2
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_2_INPUT_WAVEFORM, 1)
    structWriteWordValue(ZPR_8, STRUCT_PATCH.VOICE_2_INPUT_PULSEWIDTH, 2047)
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_2_INPUT_SUSTAIN, 15)

    // voice 3
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_3_INPUT_WAVEFORM, 1)
    structWriteWordValue(ZPR_8, STRUCT_PATCH.VOICE_3_INPUT_PULSEWIDTH, 2047)
    structWriteByteValue(ZPR_8, STRUCT_PATCH.VOICE_3_INPUT_SUSTAIN, 15)

    // filter
    structWriteWordValue(ZPR_8, STRUCT_PATCH.FILTER_INPUT_CUTOFF, 2047)

    // main volume
    structWriteByteValue(ZPR_8, STRUCT_PATCH.MAIN_INPUT_VOL, 15)

    // ----------------------------------------------------------
    // initialize the name with "EMPTY-XX", where xx = patchIndex
    // ----------------------------------------------------------

    // load address of "EMPTY-" string into ZPR_1
    // load ZPR_2 with the address of the first byte of the patch struct
    // then copy the string into the name field of the patch struct
    loadPointerToZPR(strPatchEmptyName, ZPR_1)
    lda ZPR_8
    sta ZPR_2
    lda ZPR_8+1
    sta ZPR_2+1    
    jsr stringCopy

    // now add the length of the "EMPTY-" string to the address in ZPR_2
    // then copy it over to ZPR_1, load the patch into the accu
    // and call the subroutine to output the zero-padded patch number
    // at the end of the name field of the patch struct
    addByteValueToZPRAddress(ZPR_2, 6)
    lda ZPR_2
    sta ZPR_1
    lda ZPR_2+1
    sta ZPR_1+1
    lda patchIndex
    jsr patchesOutputPatchNumber

    // write null byte after the 8 characters
    ldy #2
    lda #0
    sta (ZPR_1), y

    rts

patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the address of a single patch struct in the patches array
 * and saves it into ZPR_8
 *
 * Parameters: Accu - zero-based index of the patch
 *
 * Returns:    ZPR_8 - address of patch struct
 *
 * ---------------------------------------------------------------- */ 

patchesLoadPatchMemoryAddressIntoZPR8:
{
    // patch index comes in the accu,
    // load the patch memory size into X-register
    ldx #PATCH_MEMORY_SIZE
    
    // multiply accu and X-register
    jsr mathMultiply
    
    // save result in local variable
    stx patchMemoryAddress
    sta patchMemoryAddress+1

    // load patches pointer address into ZPR_8
    // and add the result of the multiplication to it
    loadPointerToZPR(patches, ZPR_8)
    addWordToZPRAddress(ZPR_8, patchMemoryAddress)

    rts

patchMemoryAddress:
    .byte(0)
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Switches the current patch to the patch with the given index
 *
 * Parameters:              Accu - index (0-63) of the desired patch
 *
 * Writes global variables: currentPatchIndex, currentPatchAddress
 *
 * ---------------------------------------------------------------- */ 

patchesSwitchToPatch:
{
    // set gobal variable to the value from the accu
    sta currentPatchIndex
    
    // load the data from the patch
    jsr patchesTransferFromPatchToModules
    
    // update the global variable for the address of the current patch
    lda ZPR_8_LO
    sta currentPatchAddress
    lda ZPR_8_HI
    sta currentPatchAddress+1
    
    // update the SID chip with new values
    jsr sidUpdateAllRegisters
    
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the input field values from the modules
 * to the fields of the patch with the given index
 *
 * Parameters: Accu - zero based index of the patch to copy to
 *
 * ---------------------------------------------------------------- */ 

patchesTransferFromModulesToPatch:
{
    jsr patchesLoadPatchMemoryAddressIntoZPR8
    
    // voice 1
    patchesTransferByteFromInputField(voice1InputWaveform, STRUCT_PATCH.VOICE_1_INPUT_WAVEFORM)
    patchesTransferWordFromInputField(voice1InputPulseWidth, STRUCT_PATCH.VOICE_1_INPUT_PULSEWIDTH)
    patchesTransferByteFromInputField(voice1InputAttack, STRUCT_PATCH.VOICE_1_INPUT_ATTACK)
    patchesTransferByteFromInputField(voice1InputDecay, STRUCT_PATCH.VOICE_1_INPUT_DECAY)
    patchesTransferByteFromInputField(voice1InputSustain, STRUCT_PATCH.VOICE_1_INPUT_SUSTAIN)
    patchesTransferByteFromInputField(voice1InputRelease, STRUCT_PATCH.VOICE_1_INPUT_RELEASE)
    patchesTransferByteFromInputField(voice1InputUse, STRUCT_PATCH.VOICE_1_INPUT_USE)
    patchesTransferByteFromInputField(voice1InputSync, STRUCT_PATCH.VOICE_1_INPUT_SYNC)
    patchesTransferByteFromInputField(voice1InputRingMod, STRUCT_PATCH.VOICE_1_INPUT_RINGMOD)

    // voice 2
    patchesTransferByteFromInputField(voice2InputWaveform, STRUCT_PATCH.VOICE_2_INPUT_WAVEFORM)
    patchesTransferWordFromInputField(voice2InputPulseWidth, STRUCT_PATCH.VOICE_2_INPUT_PULSEWIDTH)
    patchesTransferByteFromInputField(voice2InputAttack, STRUCT_PATCH.VOICE_2_INPUT_ATTACK)
    patchesTransferByteFromInputField(voice2InputDecay, STRUCT_PATCH.VOICE_2_INPUT_DECAY)
    patchesTransferByteFromInputField(voice2InputSustain, STRUCT_PATCH.VOICE_2_INPUT_SUSTAIN)
    patchesTransferByteFromInputField(voice2InputRelease, STRUCT_PATCH.VOICE_2_INPUT_RELEASE)
    patchesTransferByteFromInputField(voice2InputUse, STRUCT_PATCH.VOICE_2_INPUT_USE)
    patchesTransferByteFromInputField(voice2InputSync, STRUCT_PATCH.VOICE_2_INPUT_SYNC)
    patchesTransferByteFromInputField(voice2InputRingMod, STRUCT_PATCH.VOICE_2_INPUT_RINGMOD)

    // voice 3
    patchesTransferByteFromInputField(voice3InputWaveform, STRUCT_PATCH.VOICE_3_INPUT_WAVEFORM)                  
    patchesTransferWordFromInputField(voice3InputPulseWidth, STRUCT_PATCH.VOICE_3_INPUT_PULSEWIDTH)                
    patchesTransferByteFromInputField(voice3InputAttack, STRUCT_PATCH.VOICE_3_INPUT_ATTACK)                    
    patchesTransferByteFromInputField(voice3InputDecay, STRUCT_PATCH.VOICE_3_INPUT_DECAY)                     
    patchesTransferByteFromInputField(voice3InputSustain, STRUCT_PATCH.VOICE_3_INPUT_SUSTAIN)                   
    patchesTransferByteFromInputField(voice3InputRelease, STRUCT_PATCH.VOICE_3_INPUT_RELEASE)                   
    patchesTransferByteFromInputField(voice3InputUse, STRUCT_PATCH.VOICE_3_INPUT_USE)                       
    patchesTransferByteFromInputField(voice3InputSync, STRUCT_PATCH.VOICE_3_INPUT_SYNC)                      
    patchesTransferByteFromInputField(voice3InputRingMod, STRUCT_PATCH.VOICE_3_INPUT_RINGMOD)                   

    // filter
    patchesTransferWordFromInputField(filterInputCutoff, STRUCT_PATCH.FILTER_INPUT_CUTOFF)                     
    patchesTransferByteFromInputField(filterInputResonance, STRUCT_PATCH.FILTER_INPUT_RESONANCE)                  
    patchesTransferByteFromInputField(filterInputVoice1, STRUCT_PATCH.FILTER_INPUT_VOICE_1)                    
    patchesTransferByteFromInputField(filterInputVoice2, STRUCT_PATCH.FILTER_INPUT_VOICE_2)                    
    patchesTransferByteFromInputField(filterInputVoice3, STRUCT_PATCH.FILTER_INPUT_VOICE_3)                    
    patchesTransferByteFromInputField(filterInputLowpass, STRUCT_PATCH.FILTER_INPUT_LOWPASS)                    
    patchesTransferByteFromInputField(filterInputHighpass, STRUCT_PATCH.FILTER_INPUT_HIGHPASS)                   
    patchesTransferByteFromInputField(filterInputBandwidth, STRUCT_PATCH.FILTER_INPUT_BANDWIDTH)                  

    // main volume
    patchesTransferByteFromInputField(mainInputVol, STRUCT_PATCH.MAIN_INPUT_VOL)                          

    // detuning
    patchesTransferWordFromInputField(detuningInputVoice1, STRUCT_PATCH.DETUNING_INPUT_VOICE_1)                  
    patchesTransferByteFromInputField(detuningInputDetuneDownVoice1, STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_1)      
    patchesTransferWordFromInputField(detuningInputVoice2, STRUCT_PATCH.DETUNING_INPUT_VOICE_2)                  
    patchesTransferByteFromInputField(detuningInputDetuneDownVoice2, STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_2)      
    patchesTransferWordFromInputField(detuningInputVoice3, STRUCT_PATCH.DETUNING_INPUT_VOICE_3)                  
    patchesTransferByteFromInputField(detuningInputDetuneDownVoice3, STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_3)      

    // reset oscillators
    patchesTransferByteFromInputField(resetOscillatorVoice1, STRUCT_PATCH.RESET_OSCILLATOR_VOICE_1)                
    patchesTransferByteFromInputField(resetOscillatorVoice2, STRUCT_PATCH.RESET_OSCILLATOR_VOICE_2)                
    patchesTransferByteFromInputField(resetOscillatorVoice3, STRUCT_PATCH.RESET_OSCILLATOR_VOICE_3)                

    // velocity
    patchesTransferByteFromInputField(velocityUse, STRUCT_PATCH.VELOCITY_USE)                            
    patchesTransferByteFromInputField(velocitySustain, STRUCT_PATCH.VELOCITY_SUSTAIN)                        

    // voice 3 special features
    patchesTransferByteFromInputField(voice3FeaturesInputMuteVoice3, STRUCT_PATCH.VOICE_3_FEATURES_INPUT_MUTE_VOICE_3)     
    patchesTransferByteFromInputField(voice3FeaturesModulatePulseWidth, STRUCT_PATCH.VOICE_3_FEATURES_MODULATE_PULSE_WIDTH)   
    patchesTransferByteFromInputField(voice3FeaturesModulateFilter, STRUCT_PATCH.VOICE_3_FEATURES_MODULATE_FILTER)        
    patchesTransferWordFromInputField(voice3FeaturesPulseWidth, STRUCT_PATCH.VOICE_3_FEATURES_PULSE_WIDTH)            
    patchesTransferByteFromInputField(voice3FeaturesPulseWidthNegative, STRUCT_PATCH.VOICE_3_FEATURES_PULSE_WIDTH_NEGATIVE)   
    patchesTransferWordFromInputField(voice3FeaturesFilterCutoff, STRUCT_PATCH.VOICE_3_FEATURES_FILTER_CUTOFF)          
    patchesTransferByteFromInputField(voice3FeaturesFilterCutoffNegative, STRUCT_PATCH.VOICE_3_FEATURES_FILTER_CUTOFF_NEGATIVE)

    rts
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Copies a byte value from the given input field to the given patch field
 * with the address stored in ZPR_8
 *
 * Parameters:   ZPR_8: address of patch struct
 *               inputField: input field struct
 *               patchField: patch struct field
 * 
 * ---------------------------------------------------------------- */ 

.macro patchesTransferByteFromInputField(inputField, patchField) {
    ldx #STRUCT_INPUT.VALUE
    lda inputField, x
    ldy #patchField
    sta (ZPR_8), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Copies a word value from the given input field to the given patch field
 * with the address stored in ZPR_8
 *
 * Parameters:   ZPR_8: address of patch struct
 *               inputField: input field struct
 *               patchField: patch struct field
 * 
 * ---------------------------------------------------------------- */ 

.macro patchesTransferWordFromInputField(inputField, patchField) {
    ldx #STRUCT_INPUT.VALUE
    lda inputField, x
    ldy #patchField
    sta (ZPR_8), y
    inx
    lda inputField, x
    iny
    sta (ZPR_8), y
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the field values from the patch with the given index
 * to the input fields of the modules
 *
 * Parameters: Accu - zero based index of the patch to copy from
 *
 * ---------------------------------------------------------------- */ 

patchesTransferFromPatchToModules:
{
    jsr patchesLoadPatchMemoryAddressIntoZPR8
    
    // voice 1
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_WAVEFORM, voice1InputWaveform)
    patchesTransferWordToInputField(STRUCT_PATCH.VOICE_1_INPUT_PULSEWIDTH, voice1InputPulseWidth)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_ATTACK, voice1InputAttack)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_DECAY, voice1InputDecay)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_SUSTAIN, voice1InputSustain)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_RELEASE, voice1InputRelease)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_USE, voice1InputUse)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_SYNC, voice1InputSync)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_1_INPUT_RINGMOD, voice1InputRingMod)

    // voice 2
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_WAVEFORM, voice2InputWaveform)
    patchesTransferWordToInputField(STRUCT_PATCH.VOICE_2_INPUT_PULSEWIDTH, voice2InputPulseWidth)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_ATTACK, voice2InputAttack)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_DECAY, voice2InputDecay)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_SUSTAIN, voice2InputSustain)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_RELEASE, voice2InputRelease)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_USE, voice2InputUse)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_SYNC, voice2InputSync)
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_2_INPUT_RINGMOD, voice2InputRingMod)

    // voice 3
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_WAVEFORM, voice3InputWaveform)                  
    patchesTransferWordToInputField(STRUCT_PATCH.VOICE_3_INPUT_PULSEWIDTH, voice3InputPulseWidth)                
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_ATTACK, voice3InputAttack)                    
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_DECAY, voice3InputDecay)                     
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_SUSTAIN, voice3InputSustain)                   
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_RELEASE, voice3InputRelease)                   
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_USE, voice3InputUse)                       
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_SYNC, voice3InputSync)                      
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_INPUT_RINGMOD, voice3InputRingMod)                   

    // filter
    patchesTransferWordToInputField(STRUCT_PATCH.FILTER_INPUT_CUTOFF, filterInputCutoff)                     
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_RESONANCE, filterInputResonance)                  
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_VOICE_1, filterInputVoice1)                    
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_VOICE_2, filterInputVoice2)                    
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_VOICE_3, filterInputVoice3)                    
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_LOWPASS, filterInputLowpass)                    
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_HIGHPASS, filterInputHighpass)                   
    patchesTransferByteToInputField(STRUCT_PATCH.FILTER_INPUT_BANDWIDTH, filterInputBandwidth)                  

    // main volume
    patchesTransferByteToInputField(STRUCT_PATCH.MAIN_INPUT_VOL, mainInputVol)                          

    // detuning
    patchesTransferWordToInputField(STRUCT_PATCH.DETUNING_INPUT_VOICE_1, detuningInputVoice1)                  
    patchesTransferByteToInputField(STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_1, detuningInputDetuneDownVoice1)      
    patchesTransferWordToInputField(STRUCT_PATCH.DETUNING_INPUT_VOICE_2, detuningInputVoice2)                  
    patchesTransferByteToInputField(STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_2, detuningInputDetuneDownVoice2)      
    patchesTransferWordToInputField(STRUCT_PATCH.DETUNING_INPUT_VOICE_3, detuningInputVoice3)                  
    patchesTransferByteToInputField(STRUCT_PATCH.DETUNING_INPUT_DETUNE_DOWN_VOICE_3, detuningInputDetuneDownVoice3)      

    // reset oscillators
    patchesTransferByteToInputField(STRUCT_PATCH.RESET_OSCILLATOR_VOICE_1, resetOscillatorVoice1)                
    patchesTransferByteToInputField(STRUCT_PATCH.RESET_OSCILLATOR_VOICE_2, resetOscillatorVoice2)                
    patchesTransferByteToInputField(STRUCT_PATCH.RESET_OSCILLATOR_VOICE_3, resetOscillatorVoice3)                

    // velocity
    patchesTransferByteToInputField(STRUCT_PATCH.VELOCITY_USE, velocityUse)                            
    patchesTransferByteToInputField(STRUCT_PATCH.VELOCITY_SUSTAIN, velocitySustain)                        

    // voice 3 special features
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_FEATURES_INPUT_MUTE_VOICE_3, voice3FeaturesInputMuteVoice3)     
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_FEATURES_MODULATE_PULSE_WIDTH, voice3FeaturesModulatePulseWidth)   
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_FEATURES_MODULATE_FILTER, voice3FeaturesModulateFilter)        
    patchesTransferWordToInputField(STRUCT_PATCH.VOICE_3_FEATURES_PULSE_WIDTH, voice3FeaturesPulseWidth)            
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_FEATURES_PULSE_WIDTH_NEGATIVE, voice3FeaturesPulseWidthNegative)   
    patchesTransferWordToInputField(STRUCT_PATCH.VOICE_3_FEATURES_FILTER_CUTOFF, voice3FeaturesFilterCutoff)          
    patchesTransferByteToInputField(STRUCT_PATCH.VOICE_3_FEATURES_FILTER_CUTOFF_NEGATIVE, voice3FeaturesFilterCutoffNegative)

    rts
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Copies a byte value from the patch with the address stored in ZPR_8
 * to the given input field
 *
 * Parameters:   ZPR_8: address of patch struct
 *               patchField: patch struct field
 *               inputField: input field struct
 * 
 * ---------------------------------------------------------------- */ 

.macro patchesTransferByteToInputField(patchField, inputField) {
    ldy #patchField
    lda (ZPR_8), y
    ldx #STRUCT_INPUT.VALUE
    sta inputField, x
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Copies a word value from the patch with the address stored in ZPR_8
 * to the given input field
 *
 * Parameters:   ZPR_8: address of patch struct
 *               patchField: patch struct field
 *               inputField: input field struct
 * 
 * ---------------------------------------------------------------- */ 

.macro patchesTransferWordToInputField(patchField, inputField) {
    ldy #patchField
    lda (ZPR_8), y
    ldx #STRUCT_INPUT.VALUE
    sta inputField, x
    iny
    lda (ZPR_8), y
    inx
    sta inputField, x
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 *
 *
 * ---------------------------------------------------------------- */ 

patchesLoadFromDisk:
{
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 *
 *
 * ---------------------------------------------------------------- */ 

patchesSaveToDisk:
{
    rts
}

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the 1-indexed, zero-padded index of a patch into the
 * destination address (max values for input: 0-63, outputted as "01"-"64")
 *
 * Parameters: Accu:  zero based index of patch,
 *             ZPR_1: Start-address of destination buffer
 *
 * ---------------------------------------------------------------- */ 

patchesOutputPatchNumber:
{
    asl
    tax
    lda strPatchNumbers, x
    ldy #0
    sta (ZPR_1), y
    inx
    lda strPatchNumbers, x
    iny
    sta (ZPR_1), y
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the name of a patch into to a given address, pads it with
 * a placeholder character, if shorter than 8 characters
 *
 * Parameters: ZPR_1: Address of buffer to write the name into
 *             ZPR_8: Address of name field in patch struct
 *                
 * ---------------------------------------------------------------- */ 

patchesOutputPatchName:
{
    // ZPR_1 and ZPR_2 should be set correctly, print the string
    ldy #0
    
characterLoop:
    lda (ZPR_8), y
    beq characterFinished
    sta (ZPR_1), y
    iny
    jmp characterLoop
    
characterFinished:
    // check if already 8 characters reached, if yes exit
    cpy #8
    bcs exit

    // no, less then 8 characters, so output "." after the name
    // until 8 characters are written
    lda #$2E

paddingLoop:
    sta (ZPR_1), y
    iny
    cpy #8
    bne paddingLoop

exit:
    rts
}