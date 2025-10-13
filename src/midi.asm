#importonce 

#import "constants.asm"
#import "globals.asm"
#import "zpregisters.asm"


midiInit: {
    // jsr midiInitDatel
    rts
}


midiInitDatel:
{
    lda MIDI_INTERFACE_DATEL.MASTER_RESET_VALUE
    sta MIDI_INTERFACE_DATEL.CONTROL
    lda MIDI_INTERFACE_DATEL.SETUP_VALUE
    sta MIDI_INTERFACE_DATEL.CONTROL
    rts
}

