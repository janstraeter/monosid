#importonce

.label REPEAT_FLAG                  = $028A
.label IRQ_VECTOR_LO                = $0314
.label IRQ_VECTOR_HI                = $0315
.label NMI_VECTOR_LO                = $0318
.label NMI_VECTOR_HI                = $0319
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

.namespace CIA2 {
    .label TIMER_A_LO               = $dd04
    .label TIMER_A_HI               = $dd05
    .label CONTROL_A                = $dd0e
    .label INTERRUPT_CONTROL_STATE  = $dd0d
}


.namespace VIC {
    .label SPRITE_0_BLOCK_REGISTER  = SCREENMEM + $03f8;
    .label SPRITE_1_BLOCK_REGISTER  = SCREENMEM + $03f9;
    .label SPRITE_2_BLOCK_REGISTER  = SCREENMEM + $03fa;
    .label SPRITE_3_BLOCK_REGISTER  = SCREENMEM + $03fb;
    .label SPRITE_4_BLOCK_REGISTER  = SCREENMEM + $03fc;
    .label SPRITE_5_BLOCK_REGISTER  = SCREENMEM + $03fd;
    .label SPRITE_6_BLOCK_REGISTER  = SCREENMEM + $03fe;
    .label SPRITE_7_BLOCK_REGISTER  = SCREENMEM + $03ff;

    .label SPRITE_0_X               = $d000
    .label SPRITE_0_Y               = $d001
    .label SPRITE_1_X               = $d002
    .label SPRITE_1_Y               = $d003
    .label SPRITE_2_X               = $d004
    .label SPRITE_2_Y               = $d005
    .label SPRITE_3_X               = $d006
    .label SPRITE_3_Y               = $d007
    .label SPRITE_4_X               = $d008
    .label SPRITE_4_Y               = $d009
    .label SPRITE_5_X               = $d00a
    .label SPRITE_5_Y               = $d00b
    .label SPRITE_6_X               = $d00c
    .label SPRITE_6_Y               = $d00d
    .label SPRITE_7_X               = $d00e
    .label SPRITE_7_Y               = $d00f
    .label SPRITES_X_MSB            = $d010

    .label CONTROL_REGISTER_1       = $d011
    .label RASTER_COUNTER           = $d012

    .label SPRITE_ACTIVE            = $d015
    .label SPRITE_DOUBLE_HEIGHT     = $d017

    .label CHARACTER_MEMORY_POINTER = $d018

    .label INTERRUPT_REGISTER       = $d019
    .label INTERRUPT_ENABLED        = $d01a

    .label SPRITE_DEEP              = $d01b
    .label SPRITE_MULTICOLOR        = $d01c
    .label SPRITE_DOUBLE_WIDTH      = $d01d
    .label SPRITE_SPRITE_COLLISION  = $d01e
    .label SPRITE_BG_COLLISION      = $d01f

    .label BORDERCOLOR              = $d020
    .label BACKGROUND_COLOR_0       = $d021

    .label SPRITE_MULTICOLOR_0      = $d025
    .label SPRITE_MULTICOLOR_1      = $d026

    .label SPRITE_0_COLOR           = $d027
    .label SPRITE_1_COLOR           = $d028
    .label SPRITE_2_COLOR           = $d029
    .label SPRITE_3_COLOR           = $d02a
    .label SPRITE_4_COLOR           = $d02b
    .label SPRITE_5_COLOR           = $d02c
    .label SPRITE_6_COLOR           = $d02d
    .label SPRITE_7_COLOR           = $d02e

}

.namespace KERNAL {
    .label TEXTCOLOR                = $0286
    .label CURSORCOLOR              = $0287
    .label CLS                      = $e544
    .label INTERRUPT_ROUTINE        = $ea31
    .label GETIN                    = $ffe4
    .label PLOT                     = $FFF0

    .label SETLFS                   = $FFBA
    .label SETNAM                   = $FFBD
    .label OPEN                     = $FFC0
    .label CLOSE                    = $FFC3
    .label LOAD                     = $FFD5
    .label SAVE                     = $FFD8

    .label IOINIT                   = $FF84
    .label SETMSG                   = $FF90
    .label READST                   = $FFB7
    .label CHKIN                    = $FFC6
    .label CHKOUT                   = $FFC9
    .label CLRCHN                   = $FFCC
    .label CHRIN                    = $FFCF
    .label CHROUT                   = $FFD2
    .label CLALL                    = $FFE7

    .label LFN_ERR                  = 15
    .label SA_ERR                   = 15
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
    .label PATCH_SELECTOR           = $03
}

.namespace MODE_MAIN_SUBMODE {
    .label SELECT_INPUT             = $01
    .label INPUT_EDITOR             = $02
}

.namespace MODE_MENU_SUBMODE {
    .label SELECT_ITEM              = $01
    .label SHOW_ERROR_MESSAGE       = $02
    .label RENAME_PATCH             = $03
    .label SET_MIDI_CHANNEL         = $04
}

.namespace MODE_PATCH_SELECTOR_SUBMODE {
    .label SELECT_PATCH             = $01
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
    .label CURSOR_DOWN              = $11
    .label CURSOR_RIGHT             = $1D
    .label CURSOR_UP                = $91
    .label CURSOR_LEFT              = $9D

    .label W                        = $57
    .label A                        = $41
    .label S                        = $53
    .label D                        = $44

    .label RETURN                   = $0D
    .label SPACE                    = $20
    .label PLUS                     = $2B
    .label MINUS                    = $2D

    .label DELETE                   = $14

    .label F1                       = $85
    .label F3                       = $86
}

.namespace MIDI_CARTRIDGE {
    .label NONE                     = 0
    .label SEQUENTIAL               = 1
    .label NAMESOFT                 = 2
    .label DATEL_SIEL_JMS           = 3
    .label PASSPORT                 = 4
    .label MAPLIN                   = 5
}

.namespace MIDI_CARTRIDGE_SEQUENTIAL {
    .label CONTROL                  = $de00
    .label STATUS                   = $de02
    .label TRANSMIT                 = $de01
    .label RECIEVE                  = $de03
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $95
}

.namespace MIDI_CARTRIDGE_NAMESOFT {
    .label CONTROL                  = $de00
    .label STATUS                   = $de02
    .label TRANSMIT                 = $de01
    .label RECIEVE                  = $de03
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $95
}

.namespace MIDI_CARTRIDGE_DATEL {
    .label CONTROL                  = $de04
    .label STATUS                   = $de06
    .label TRANSMIT                 = $de05
    .label RECIEVE                  = $de07
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $92
}

.namespace MIDI_CARTRIDGE_PASSPORT {
    .label CONTROL                  = $de08
    .label STATUS                   = $de08
    .label TRANSMIT                 = $de09
    .label RECIEVE                  = $de09
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $95
}

.namespace MIDI_CARTRIDGE_MAPLIN {
    .label CONTROL                  = $df00
    .label STATUS                   = $df00
    .label TRANSMIT                 = $df01
    .label RECIEVE                  = $df01
    .label MASTER_RESET_VALUE       = $03
    .label SETUP_VALUE              = $96
}

.namespace MIDI_MESSAGE {
    .label NONE                     = $00
    .label NOTE_ON                  = $01
    .label NOTE_OFF                 = $02
    .label PITCH_BEND_CHANGE        = $03
}

.label MIDI_POLL_TIMER              = 300 // ~3.284x per second
.label MIDI_MAX_ACTIVE_NOTES        = 10
.label MAX_NOTE_INDEX               = 95 // 8 octaves, highest index number is 95

.namespace IID {
    .label V1_WAVE                  = 1
    .label V1_PULSE                 = 2
    .label V1_ATC                   = 3
    .label V1_DCY                   = 4 
    .label V1_SUS                   = 5 
    .label V1_RLS                   = 6
    .label V1_USE                   = 7 
    .label V1_SYNC                  = 8
    .label V1_RING                  = 9

    .label V2_WAVE                  = 10
    .label V2_PULSE                 = 11
    .label V2_ATC                   = 12 
    .label V2_DCY                   = 13
    .label V2_SUS                   = 14
    .label V2_RLS                   = 15
    .label V2_USE                   = 16
    .label V2_SYNC                  = 17
    .label V2_RING                  = 18

    .label V3_WAVE                  = 19
    .label V3_PULSE                 = 20
    .label V3_ATC                   = 21
    .label V3_DCY                   = 22
    .label V3_SUS                   = 23
    .label V3_RLS                   = 24
    .label V3_USE                   = 25
    .label V3_SYNC                  = 26
    .label V3_RING                  = 27

    .label FILTER_CUTOFF            = 28
    .label FILTER_RES               = 29
    .label FILTER_V1                = 30
    .label FILTER_V2                = 31
    .label FILTER_V3                = 32
    .label FILTER_LOWPASS           = 33
    .label FILTER_HIGHPASS          = 34
    .label FILTER_BANDWIDTH         = 35

    .label MAIN_VOL                 = 36

    .label DETUNING_V1              = 37
    .label DETUNING_V1_NEG          = 38
    .label DETUNING_V2              = 39
    .label DETUNING_V2_NEG          = 40
    .label DETUNING_V3              = 41
    .label DETUNING_V3_NEG          = 42

    .label RESOSC_V1                = 43
    .label RESOSC_V2                = 44
    .label RESOSC_V3                = 45

    .label VELOCITY_USE             = 46
    .label VELOCITY_SUS             = 47

    .label V3SPECIAL_MUTE           = 48
    .label V3SPECIAL_MOD_PULSE      = 49
    .label V3SPECIAL_MOD_FILTER     = 50
    .label V3SPECIAL_PULSE          = 51
    .label V3SPECIAL_PULSE_NEG      = 52
    .label V3SPECIAL_CUTOFF         = 53
    .label V3SPECIAL_CUTOFF_NEG     = 54
}

.label PATCHES_NUM                  = 64
.label PATCH_MEMORY_SIZE            = 80
.label PATCH_ARRAY_MEMORY_SIZE      = PATCHES_NUM * PATCH_MEMORY_SIZE

.label MENU_ITEMS_NUM               = 6

.namespace MENU_ITEM {
    .label SAVE_PATCHES             = 0
    .label LOAD_PATCHES             = 1
    .label RENAME_CURRENT_PATCH     = 2
    .label CLEAR_CURRENT_PATCH      = 3
    .label SET_MIDI_CHANNEL         = 4
    .label RETURN                   = 5
}
