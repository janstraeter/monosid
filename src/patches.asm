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
    lda #PATCHES_NUM
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

    // LFO
    patchesTransferByteFromInputField(lfoModulatePitch, STRUCT_PATCH.LFO_MOD_PITCH)
    patchesTransferByteFromInputField(lfoModulatePulseWidth, STRUCT_PATCH.LFO_MOD_PULSE)
    patchesTransferByteFromInputField(lfoModulateFilter, STRUCT_PATCH.LFO_MOD_FILTER)
    patchesTransferByteFromInputField(lfoSquareWave, STRUCT_PATCH.LFO_SQUARE_WAVE)
    patchesTransferByteFromInputField(lfoResetOscillator, STRUCT_PATCH.LFO_RESET_OSC)
    patchesTransferByteFromInputField(lfoModulateWithVoice3Envelope, STRUCT_PATCH.LFO_MOD_WITH_V3_EG)
    patchesTransferByteFromInputField(lfoInputMuteVoice3, STRUCT_PATCH.LFO_MUTE_VOICE_3)
    patchesTransferWordFromInputField(lfoCycleLength, STRUCT_PATCH.LFO_CYCLE_TIME)
    patchesTransferWordFromInputField(lfoPitch, STRUCT_PATCH.LFO_PITCH)
    patchesTransferWordFromInputField(lfoPulseWidth, STRUCT_PATCH.LFO_PULSE)
    patchesTransferByteFromInputField(lfoPulseWidthNegative, STRUCT_PATCH.LFO_PULSE_NEG)
    patchesTransferWordFromInputField(lfoFilterCutoff, STRUCT_PATCH.LFO_CUTOFF)
    patchesTransferByteFromInputField(lfoFilterCutoffNegative, STRUCT_PATCH.LFO_CUTOFF_NEG)

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

    // LFO
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_MOD_PITCH, lfoModulatePitch)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_MOD_PULSE, lfoModulatePulseWidth)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_MOD_FILTER, lfoModulateFilter)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_SQUARE_WAVE, lfoSquareWave)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_RESET_OSC, lfoResetOscillator)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_MOD_WITH_V3_EG, lfoModulateWithVoice3Envelope)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_MUTE_VOICE_3, lfoInputMuteVoice3)
    patchesTransferWordToInputField(STRUCT_PATCH.LFO_CYCLE_TIME, lfoCycleLength)
    patchesTransferWordToInputField(STRUCT_PATCH.LFO_PITCH, lfoPitch)
    patchesTransferWordToInputField(STRUCT_PATCH.LFO_PULSE, lfoPulseWidth)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_PULSE_NEG, lfoPulseWidthNegative)
    patchesTransferWordToInputField(STRUCT_PATCH.LFO_CUTOFF, lfoFilterCutoff)
    patchesTransferByteToInputField(STRUCT_PATCH.LFO_CUTOFF_NEG, lfoFilterCutoffNegative)

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
 * Prints the loading screen
 *
 * ---------------------------------------------------------------- */ 

patchesDrawLoadScreen:
{
    jsr logoHide
    jsr userinterfaceInitScreen
    screenPutStringColor(7, 11, strPatchesLoading, WHITE)
    screenPutStringColor(17, 13, strPatches01Of64, YELLOW)
    rts
}

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Saves the patches data to a file called "MONOSID.PTC" to disk
 * Prints an error message if any disk drive errors occur.
 *
 * Sets carry bit on error, clears carry bit on success
 *
 * ---------------------------------------------------------------- */ 

patchesLoadFromDisk:
{
    .label LOGICAL_FILE_NUMBER = 2

    // turn off Kernal messages
    lda #0
    jsr KERNAL.SETMSG

    // open error channel, then try to open the file, a set carry indicates Kernal error
    fileOpenErrorChannel()
    bcc *+5
    jmp kernalFileOpenError
    fileOpen(LOGICAL_FILE_NUMBER, LOGICAL_FILE_NUMBER, FILENAME, FILENAME_LENGTH)
    bcc *+5
    jmp kernalFileOpenError

    // read message from error channel (accu contains error number, zero if no error)
    jsr fileReadErrorChannel
    
    // check for error (e.g. file not found)
    cmp #0
    bne printErrorMessageAndExit
    
    // assign the current input channel to the logical file number
    ldx #LOGICAL_FILE_NUMBER
    jsr KERNAL.CHKIN
    bcs readErrorMessageAndExit

    // set ZPR_2 to patches start address
    loadPointerToZPR(patches, ZPR_2)
    
    // initialize counter variables
    lda #0
    sta patchIndex
    sta byteIndex

    // load the scrren address of the position of the patch number into ZPR_1
    .var currentPathScreenAddress = screenCalculateMemoryAddress(17, 13)
    loadPointerToZPR(currentPathScreenAddress, ZPR_1)

patchLoadLoop:
    // print the current patch number on the screen
    lda patchIndex
    jsr patchesOutputPatchNumber

byteLoadLoop:
    // read the status byte into accu
    jsr KERNAL.READST

    // check for error (without destroying the accu)
    bit ST_ERROR
    bne readErrorMessageAndExit

    // check for EOF (without destroying the accu)
    bit ST_EOF
    bne closeFileAndExit

    // read the next byte from the file
    jsr KERNAL.CHRIN
    bcs readErrorMessageAndExit

    // write the loaded byte into the patches buffer
    ldy byteIndex
    sta (ZPR_2), y

    // increase the byte counter for the current patch
    // and check for end of patch
    inc byteIndex
    lda byteIndex
    cmp #PATCH_MEMORY_SIZE
    bne byteLoadLoop

    // increase pointer in ZPR_2 by the patch size
    addByteValueToZPRAddress(ZPR_2, PATCH_MEMORY_SIZE)

    // reset the byte counter
    lda #0
    sta byteIndex

    // increase the patch counter
    // and check for last patch finished
    inc patchIndex
    lda patchIndex
    cmp #PATCHES_NUM
    bne patchLoadLoop

closeFileAndExit:
    // close file, error channel and restore I/O channel
    fileCloseErrorChannel()
    fileClose(LOGICAL_FILE_NUMBER)
    jsr KERNAL.CLRCHN
    
    // clear carry bit to indicate success
    clc
    rts

kernalFileOpenError:
    // print the message that the Kernal could not open a file
    jsr patchesPrintKernalFileOpenError

    // set carry bit to indicate error
    sec
    rts

readErrorMessageAndExit:
    // read message from error channel
    jsr fileReadErrorChannel

printErrorMessageAndExit:
    // print error message
    jsr patchesPrintLastDiskDriveError

    // close file, error channel and restore I/O channel
    fileCloseErrorChannel()
    fileClose(LOGICAL_FILE_NUMBER)
    jsr KERNAL.CLRCHN

    // set carry bit to indicate error
    sec
    rts

FILENAME:
    // SETNAM expects the filename to be encoded in PETSCII
    .encoding "petscii_upper"

    // filename MONOSID.PTC
    // "0:" - 
    // "U" - user file
    // "R" - open for reading
    .text "0:MONOSID.PTC,U,R"

    // calculate string length
    .label FILENAME_LENGTH = * - FILENAME

ST_EOF:
    .byte($40)

ST_ERROR:
    .byte($BF)

byteIndex:
    .byte(0)

patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the saving screen
 *
 * ---------------------------------------------------------------- */ 

patchesDrawSaveScreen:
{
    jsr logoHide
    jsr userinterfaceInitScreen
    screenPutStringColor(8, 11, strPatchesSaving, WHITE)
    screenPutStringColor(17, 13, strPatches01Of64, YELLOW)
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Saves the patches data to a file called "MONOSID.PTC" to disk
 * Prints an error message if any disk drive errors occur.
 *
 * Sets carry bit on error, clears carry bit on success
 *
 * ---------------------------------------------------------------- */ 

patchesSaveToDisk:
{
    .label LOGICAL_FILE_NUMBER = 3
    
    // turn off Kernal messages
    lda #0
    jsr KERNAL.SETMSG

    // open error channel, then try to open the file, a set carry indicates Kernal error
    fileOpenErrorChannel()
    bcc *+5
    jmp kernalFileOpenError
    fileOpen(LOGICAL_FILE_NUMBER, LOGICAL_FILE_NUMBER, FILENAME, FILENAME_LENGTH)
    bcc *+5
    jmp kernalFileOpenError

    // read message from error channel (accu contains error number, zero if no error)
    jsr fileReadErrorChannel
    
    // check for error (e.g. device not ready)
    cmp #0
    bne printErrorMessageAndExit

    // assign the current output channel to the logical file number
    ldx #LOGICAL_FILE_NUMBER
    jsr KERNAL.CHKOUT

    // set ZPR_2 to patches start address
    loadPointerToZPR(patches, ZPR_2)
    
    // initialize counter variables
    lda #0
    sta patchIndex
    sta byteIndex

    // load the scrren address of the position of the patch number into ZPR_1
    .var currentPathScreenAddress = screenCalculateMemoryAddress(17, 13)
    loadPointerToZPR(currentPathScreenAddress, ZPR_1)

patchWriteLoop:
    // print the current patch number on the screen
    lda patchIndex
    jsr patchesOutputPatchNumber

byteWriteLoop:    
    // read next patch data byte
    ldy byteIndex
    lda (ZPR_2), y

    // write the byte to the file
    jsr KERNAL.CHROUT
    
    // read the status byte and check for error
    jsr KERNAL.READST
    cmp #0
    bne readErrorMessageAndExit

    // increase the byte counter for the current patch
    // and check for end of patch
    inc byteIndex
    lda byteIndex
    cmp #PATCH_MEMORY_SIZE
    bne byteWriteLoop

    // increase pointer in ZPR_2 by the patch size
    addByteValueToZPRAddress(ZPR_2, PATCH_MEMORY_SIZE)

    // reset the byte counter
    lda #0
    sta byteIndex

    // increase the patch counter
    // and check for last patch finished
    inc patchIndex
    lda patchIndex
    cmp #PATCHES_NUM
    bne patchWriteLoop


closeFileAndExit:
    // close file, error channel and restore I/O channel
    fileCloseErrorChannel()
    fileClose(LOGICAL_FILE_NUMBER)
    jsr KERNAL.CLRCHN
    
    // clear carry bit to indicate success
    clc
    rts

kernalFileOpenError:
    // print the message that the Kernal could not open a file
    jsr patchesPrintKernalFileOpenError

    // set carry bit to indicate error
    sec
    rts

readErrorMessageAndExit:
    // read message from error channel
    jsr fileReadErrorChannel

printErrorMessageAndExit:
    // print error message
    jsr patchesPrintLastDiskDriveError

    // close file, error channel and restore I/O channel
    fileCloseErrorChannel()
    fileClose(LOGICAL_FILE_NUMBER)
    jsr KERNAL.CLRCHN

    // set carry bit to indicate error
    sec
    rts

FILENAME:
    // SETNAM expects the filename to be encoded in PETSCII
    .encoding "petscii_upper"

    // filename MONOSID.PTC
    // "@0:" - overwrite file, if already exsists
    // "U" - user file
    // "W" - open for writing
    .text "@0:MONOSID.PTC,U,W"

    // calculate string length
    .label FILENAME_LENGTH = * - FILENAME

byteIndex:
    .byte(0)

patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the error message from the disk drive
 * in buffer diskDriveErrorBuffer on the screen
 *
 * Reads global variables: diskDriveErrorBuffer, diskDriveErrorLength
 *
 * ---------------------------------------------------------------- */ 

patchesPrintLastDiskDriveError:
{
    // print error headline
    screenPutStringColor(0, 15, strDiskError, RED)

    // make the error message in red
    screenPutColorLength(0, 16, 40, RED)
    
    // load the screen address of the position of the error message into ZPR_1
    .var errorMessageScreenAddress = screenCalculateMemoryAddress(0, 16)
    loadPointerToZPR(errorMessageScreenAddress, ZPR_1)

    // copy the error message to the screen
    ldx diskDriveErrorLength
    ldy #0

loop:
    lda diskDriveErrorBuffer, y
    sta (ZPR_1), y
    iny
    dex
    bne loop

    // print press any key message
    screenPutStringColor(0, 17, strErrorPressAnyKey, WHITE)

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints an error message to the screen, informing the user
 * that the kernal could not open the file (probably because no disk drive is present)
 *
 * ---------------------------------------------------------------- */ 

patchesPrintKernalFileOpenError:
{
    screenPutStringColor(0, 15, strDiskError, RED)
    screenPutStringColor(0, 16, strKernalFileOpenError, RED)
    screenPutStringColor(0, 17, strErrorPressAnyKey, WHITE)
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


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the rename current patch screen
 *
 * Reads global variables: currentPatchAddress
 *
 * ---------------------------------------------------------------- */ 

patchesDrawRenameScreen:
{
    // clear screen, use uppercase, hide logo
    jsr screenSwitchToUpperCase
    jsr logoHide
    jsr userinterfaceInitScreen
    
    // print headline
    screenPutStringColor(10, 5, strRenamePatchHeadline, WHITE)

    // print current patch name
    screenPutString(9, 8, strRenamePatchCurrentName)
	lda currentPatchAddress
	sta ZPR_8_LO
	lda currentPatchAddress+1
	sta ZPR_8_HI
    .var patchNameMemoryAddress = screenCalculateMemoryAddress(23, 8)
	lda #<patchNameMemoryAddress
	sta ZPR_1
	lda #>patchNameMemoryAddress
	sta ZPR_1+1
	jsr patchesOutputPatchName

    // print box for new name
    screenDrawRectangleColor(14, 11, 9, 1, YELLOW)
    screenPutStringColor(15, 10, strRenamePatchNewName, YELLOW)
    screenPutColorLength(15, 12, 9, WHITE)
    
    // print additional info text
    screenPutString(4, 16, strRenamePatchInfo)

    rts
}