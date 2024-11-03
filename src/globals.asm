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
 *
 * Type: Boolean
 *
 * ---------------------------------------------------------------- */ 

noteChange:
    .byte($00)


/* -------------------------------------------------------------------
 *
 * Current note to be played
 * 255 = no note
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentNote:
    .byte($FF)


/* -------------------------------------------------------------------
 *
 * Previusly played note
 * 255 = no note
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

previousNote:
    .byte($FF)


/* -------------------------------------------------------------------
 *
 * Currently selected octave for the keyboard piano
 *
 * Type: Integer
 *
 * ---------------------------------------------------------------- */ 

currentKeyboardPianoOctave:
    .byte($04)


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
 * Frequencies of the notes (PAL version)
 * Lo bytes
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

FreqTablePalLo:
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

FreqTablePalHi:
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
 * Definition of module "VOICE1"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice1:
    createStructModule(strModuleNameVoice1, 0,  2, 38, 3, GRAY)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE2"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice2:
    createStructModule(strModuleNameVoice2, 0,  8, 38, 3, GRAY)


/* -------------------------------------------------------------------
 *
 * Definition of module "VOICE3"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleVoice3:
    createStructModule(strModuleNameVoice3, 0, 14, 38, 3, GRAY)


/* -------------------------------------------------------------------
 *
 * Definition of module "FILTER"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleFilter:
    createStructModule(strModuleNameFilter, 0, 20, 31, 3, RED)


/* -------------------------------------------------------------------
 *
 * Definition of module "MAIN"
 *
 * Type: STRUCT_MODULE
 *
 * ---------------------------------------------------------------- */ 

moduleMain:
    createStructModule(strModuleNameMain,  34, 20,  4, 3, PURPLE)


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

