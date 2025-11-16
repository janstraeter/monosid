#importonce

.label INTERRUPT_VECTOR_LO          = $0314
.label INTERRUPT_VECTOR_HI          = $0315
.label SCREENMEM                    = $0400
.label COLORMEM                     = $D800

.namespace ZP {
    .label LAST_PRESSED_KEY         = $C5
    .label CURRENT_PRESSED_KEY      = $CB
    .label CURSOR_FLASH             = $CC
    .label CURSOR_CURRENT_COLUMN    = $D3
    .label CURSOR_CURRENT_LINE      = $D6
}

.namespace CIA {
    .label INTERRUPT_CONTROL_STATE  = $dc0d
}

.namespace VIC {
    .label CONTROL_REGISTER_1       = $d011
    .label RASTER_COUNTER           = $d012
    .label INTERRUPT_REGISTER       = $d019
    .label INTERRUPT_ENABLED        = $d01a
    .label BORDERCOLOR              = $d020
    .label BACKGROUND_COLOR_0       = $d021
}

.namespace KERNAL {
    .label TEXTCOLOR                = $0286
    .label CLS                      = $e544
    .label INTERRUPT_ROUTINE        = $ea31
    .label GETIN                    = $ffe4
    .label PLOT                     = $FFF0
}

.namespace SID {
    .label VOICE_1_FREQUENCY_LO     = $d400
    .label VOICE_1_FREQUENCY_HI     = $d401
    .label VOICE_1_PULSE_WAVE_LO    = $d402
    .label VOICE_1_PULSE_WAVE_HI    = $d403
    .label VOICE_1_CONTROL_REGISTER = $d404
    .label VOICE_1_ATTACK_DECAY     = $d405
    .label VOICE_1_SUSTAIN_RELEASE  = $d406

    .label VOICE_2_FREQUENCY_LO     = $d407
    .label VOICE_2_FREQUENCY_HI     = $d408
    .label VOICE_2_PULSE_WAVE_LO    = $d409
    .label VOICE_2_PULSE_WAVE_HI    = $d40a
    .label VOICE_2_CONTROL_REGISTER = $d40b
    .label VOICE_2_ATTACK_DECAY     = $d40c
    .label VOICE_2_SUSTAIN_RELEASE  = $d40d

    .label VOICE_3_FREQUENCY_LO     = $d40e
    .label VOICE_3_FREQUENCY_HI     = $d40f
    .label VOICE_3_PULSE_WAVE_LO    = $d410
    .label VOICE_3_PULSE_WAVE_HI    = $d411
    .label VOICE_3_CONTROL_REGISTER = $d412
    .label VOICE_3_ATTACK_DECAY     = $d413
    .label VOICE_3_SUSTAIN_RELEASE  = $d414

    .label FILTER_CUTOFF_LO         = $d415
    .label FILTER_CUTOFF_HI         = $d416
    .label FILTER_RESONANCE_ROUTING = $d417
    .label FILTER_MODE_MAIN_VOLUME  = $d418

    .label PADDLE_X_VALUE           = $d419
    .label PADDLE_Y_VALUE           = $d41a

    .label OSCILLATOR_VOICE_3       = $d41b
    .label ENVELOPE_VOICE_3         = $d41c
}

.namespace MODE {
    .label MAIN                     = $01
    .label MENU                     = $02
}

.namespace MODE_MAIN_SUBMODE {
    .label SELECT_INPUT             = $01
    .label INPUT_EDITOR             = $02
}

.namespace MODE_MENU_SUBMODE {
    .label SELECT_ITEM              = $01
}

.namespace INPUT_TYPE {
    .label WAVEFORM                 = $01
    .label INTEGER_4_BITS           = $02
    .label INTEGER_11_BITS          = $03
    .label INTEGER_12_BITS          = $04
    .label BOOLEAN                  = $05
}

.namespace WAVEFORM {
    .label TRIANGULAR               = $01
    .label SAWTOOTH                 = $02
    .label SQUARE                   = $03
    .label NOISE                    = $04
}

.namespace PETSCII {
    .label CURSOR_DOWN              = $11;
    .label CURSOR_RIGHT             = $1D;
    .label CURSOR_UP                = $91;
    .label CURSOR_LEFT              = $9D;

    .label RETURN                   = $0D;
    .label SPACE                    = $20;
    .label PLUS                     = $2B;
    .label MINUS                    = $2D;

    .label DELETE                   = $14;
}

.namespace MIDI_INTERFACE_DATEL {
    .label CONTROL                  = $de04
    .label STATUS                   = $de06
    .label TRANSMIT                 = $de05
    .label RECIEVE                  = $de07
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $92
}

.namespace MIDI_MESSAGE {
    .label NONE                     = $00
    .label NOTE_ON                  = $01
    .label NOTE_OFF                 = $02
    .label PITCH_BEND_CHANGE        = $03
}

.label MIDI_MAX_ACTIVE_NOTES        = 5

.label MAX_NOTE_INDEX               = 95; // 8 octaves, highest index number is 95
