#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input "mod filter"
 *
 * Reads global variable:  voice3FeaturesModulateFilter
 *
 * Writes global variable: currentVoice3EnvelopeModulateFilter
 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateVoice3EnvelopeModulateFilterValue:
{
    // load the current value of the "Voice 3 special features" input "mod filter"
    loadPointerToZPR(voice3FeaturesModulateFilter, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVoice3EnvelopeModulateFilter

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input "cutoff"
 *
 * Reads global variable:  voice3FeaturesFilterCutoff
 *
 * Writes global variable: currentVoice3FilterCutoff:

 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateVoice3FilterCutoffValue:
{
    // load the current value of the "Voice 3 special features" input "cutoff"
    loadPointerToZPR(voice3FeaturesFilterCutoff, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    stx currentVoice3FilterCutoff
    sta currentVoice3FilterCutoff+1

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the global variable "currentVoice3EnvelopeModulatePulseWidth" which the
 * current value of the "Voice 3 special features" input (cutoff) "neg"
 *
 * Reads global variable:  voice3FeaturesFilterCutoffNegative
 *
 * Writes global variable: currentVoice3FilterCutoffNegative
 *
 * ---------------------------------------------------------------- */ 
 
filterUpdateVoice3FilterCutoffNegativeValue:
{
    // load the current value of the "Voice 3 special features" input (cutoff) "neg"
    loadPointerToZPR(voice3FeaturesFilterCutoffNegative, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)

    // save it into the global variable for easier access
    sta currentVoice3FilterCutoffNegative
    
    rts
}
