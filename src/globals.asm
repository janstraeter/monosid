#importonce

#import "constants.asm"
#import "strings.asm"
#import "structs.asm"


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
 * Key codes used by the keyboard piano (1 octcave C to C)
 *  w e   t y u
 * a s d f g h j k
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

keyboardPianoKeyCodes:
    .byte(10) // A
    .byte(9)  // W
    .byte(13) // S
    .byte(14) // E
    .byte(18) // D
    .byte(21) // F
    .byte(22) // T
    .byte(26) // G
    .byte(25) // Y
    .byte(29) // H
    .byte(30) // U
    .byte(34) // J
    .byte(37) // K


/* -------------------------------------------------------------------
 *
 * Key codes used by the keyboard piano to switch the octave 0-7
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

keyboardPianoOctaveKeyCodes:
    .byte(56) // key 1 -> octave 0
    .byte(59) // key 2 -> octave 1
    .byte(8)  // key 3 -> octave 2
    .byte(11) // key 4 -> octave 3
    .byte(16) // key 5 -> octave 4
    .byte(19) // key 6 -> octave 5
    .byte(24) // key 7 -> octave 6
    .byte(27) // key 8 -> octave 7


/* -------------------------------------------------------------------
 *
 * Offset for the index into the frequency tables
 * (to avoid the costly multiplications for current octave * 12)
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

keyboardPianoOctaveOffsets:
    .byte(0)  // octave 0
    .byte(12) // octave 1
    .byte(24) // octave 2 
    .byte(36) // octave 3 
    .byte(48) // octave 4
    .byte(60) // octave 5
    .byte(72) // octave 6
    .byte(84) // octave 7


/* -------------------------------------------------------------------
 *
 * Names of the 7 notes and 5 half-notes
 *
 * Type: Array of text (2 chars each)
 *
 * ---------------------------------------------------------------- */ 

noteNames:
    .text "C "
    .text "C#"
    .text "D "
    .text "D#"
    .text "E "
    .text "F "
    .text "F#"
    .text "G "
    .text "G#"
    .text "A "
    .text "A#"
    .text "B "
    .text "C "


/* -------------------------------------------------------------------
 *
 * Number of entries in the frequency table (number of available notes)
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

maxFreqTableNum:
    .byte($60)


/* -------------------------------------------------------------------
 *
 * Frequencies of the notes (PAL version)
 * Lo bytes
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

freqTablePalLo:
//         C    C#   D    D#   E    F    F#   G    G#   A    A#   B
    .byte $16, $27, $39, $4b, $5f, $74, $8a, $a1, $ba, $d4, $f0, $0e  // 0
    .byte $2d, $4e, $71, $96, $be, $e7, $14, $42, $74, $a9, $e0, $1b  // 1
    .byte $5a, $9c, $e2, $2d, $7b, $cf, $27, $85, $e8, $51, $c1, $37  // 2
    .byte $b4, $38, $c4, $59, $f7, $9d, $4e, $0a, $d0, $a2, $81, $6d  // 3
    .byte $67, $70, $89, $b2, $ed, $3b, $9c, $13, $a0, $45, $02, $da  // 4
    .byte $ce, $e0, $11, $64, $da, $76, $39, $26, $40, $89, $04, $b4  // 5
    .byte $9c, $c0, $23, $c8, $b4, $eb, $72, $4c, $80, $12, $08, $68  // 6
    .byte $39, $80, $45, $90, $68, $d6, $e3, $99, $00, $24, $10, $ff  // 7


/* -------------------------------------------------------------------
 *
 * Frequencies of the notes (PAL version)
 * Hi bytes
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

freqTablePalHi:
//         C    C#   D    D#   E    F    F#   G    G#   A    A#   B
    .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02  // 0
    .byte $02, $02, $02, $02, $02, $02, $03, $03, $03, $03, $03, $04  // 1
    .byte $04, $04, $04, $05, $05, $05, $06, $06, $06, $07, $07, $08  // 2
    .byte $08, $09, $09, $0a, $0a, $0b, $0c, $0d, $0d, $0e, $0f, $10  // 3
    .byte $11, $12, $13, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20  // 4
    .byte $22, $24, $27, $29, $2b, $2e, $31, $34, $37, $3a, $3e, $41  // 5
    .byte $45, $49, $4e, $52, $57, $5c, $62, $68, $6e, $75, $7c, $83  // 6
    .byte $8b, $93, $9c, $a5, $af, $b9, $c4, $d0, $dd, $ea, $f8, $ff  // 7


/* -------------------------------------------------------------------
 *
 * Definition of the structs for the input elements
 * for the module "VOICE 1"
 *
 * ---------------------------------------------------------------- */ 

voice1InputWaveform:
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 4, 5, strInputNameVoiceWaveform, WAVEFORM.TRIANGULAR, $00)

voice1InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 4, 6, strInputNameVoicePulseWidth, $00, $00)

voice1InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 4, 4, strInputNameVoiceAttack, $00, $00)

voice1InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 4, 4, strInputNameVoiceDecay, $00, $00)

voice1InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 4, 4, strInputNameVoiceSustain, $0F, $00)

voice1InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 4, 4, strInputNameVoiceRelease, $00, $00)

voice1InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 3, 4, strInputNameVoiceUse, $01, $00)

voice1InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 4, 4, strInputNameVoiceSync, $00, $00)

voice1InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 5, 4, strInputNameVoiceRingMod, $00, $00)

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
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 10, 5, strInputNameVoiceWaveform, WAVEFORM.SAWTOOTH, $00)

voice2InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 10, 6, strInputNameVoicePulseWidth, $FF, $00)

voice2InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 10, 4, strInputNameVoiceAttack, $00, $00)

voice2InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 10, 4, strInputNameVoiceDecay, $00, $00)

voice2InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 10, 4, strInputNameVoiceSustain, $0F, $00)

voice2InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 10, 4, strInputNameVoiceRelease, $00, $00)

voice2InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 9, 4, strInputNameVoiceUse, $00, $00)

voice2InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 10, 4, strInputNameVoiceSync, $00, $00)

voice2InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 11, 4, strInputNameVoiceRingMod, $00, $00)

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
    createStructInput(INPUT_TYPE.WAVEFORM, 1, 16, 5, strInputNameVoiceWaveform, WAVEFORM.SQUARE, $00)

voice3InputPulseWidth:
    createStructInput(INPUT_TYPE.INTEGER_12_BITS, 7, 16, 6, strInputNameVoicePulseWidth, $F0, $0F)

voice3InputAttack:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 14, 16, 4, strInputNameVoiceAttack, $00, $00)

voice3InputDecay:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 19, 16, 4, strInputNameVoiceDecay, $00, $00)

voice3InputSustain:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 24, 16, 4, strInputNameVoiceSustain, $0F, $00)

voice3InputRelease:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 29, 16, 4, strInputNameVoiceRelease, $00, $00)

voice3InputUse:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 15, 4, strInputNameVoiceUse, $00, $00)

voice3InputSync:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 16, 4, strInputNameVoiceSync, $00, $00)

voice3InputRingMod:
    createStructInput(INPUT_TYPE.BOOLEAN, 34, 17, 4, strInputNameVoiceRingMod, $00, $00)

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
    createStructInput(INPUT_TYPE.INTEGER_11_BITS, 1, 22, 6, strInputNameFilterCutoff, $F0, $07)

filterInputResonance:
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 8, 22, 4, strInputNameFilterResonance, $00, $00)

filterInputVoice1:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 21, 7, strInputNameFilterVoice1, $00, $00)

filterInputVoice2:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 22, 7, strInputNameFilterVoice2, $00, $00)

filterInputVoice3:
    createStructInput(INPUT_TYPE.BOOLEAN, 13, 23, 7, strInputNameFilterVoice3, $00, $00)

filterInputLowpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 21, 7, strInputNameFilterLowpass, $00, $00)

filterInputHighpass:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 22, 7, strInputNameFilterHighpass, $00, $00)

filterInputBandwidth:
    createStructInput(INPUT_TYPE.BOOLEAN, 21, 23, 7, strInputNameFilterBandwidth, $00, $00)

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
    createStructInput(INPUT_TYPE.INTEGER_4_BITS, 35, 22, 4, strInputNameMainVol, $0F, $00)

mainInputArray:
    .byte(<mainInputVol)
    .byte(>mainInputVol)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE1"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice1:
    createStructModule(strModuleNameVoice1, 0,  2, 38, 3, GRAY, 9, voice1InputArray)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE2"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice2:
    createStructModule(strModuleNameVoice2, 0,  8, 38, 3, GRAY, 9, voice2InputArray)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE3"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice3:
    createStructModule(strModuleNameVoice3, 0, 14, 38, 3, GRAY, 9, voice3InputArray)


/* -------------------------------------------------------------------
 *
 * Definition of module "FILTER"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleFilter:
    createStructModule(strModuleNameFilter, 0, 20, 31, 3, LIGHT_RED, 8, filterInputArray)


/* -------------------------------------------------------------------
 *
 * Definition of module "MAIN"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleMain:
    createStructModule(strModuleNameMain,  34, 20,  4, 3, PURPLE, 1, mainInputArray)


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


/* -------------------------------------------------------------------
 *
 * Number of modules
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

modulesNum:
    .byte($05)


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

