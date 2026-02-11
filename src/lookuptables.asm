/* -------------------------------------------------------------------
 *
 * Key codes used by the keyboard piano (1 octcave C to C)
 *  t y   i o p
 * f g h j k l [ ]
 *
 * Type: Array of integers
 *
 * ---------------------------------------------------------------- */ 

keyboardPianoKeyCodes:
    .byte(21) // F
    .byte(22) // T
    .byte(26) // G
    .byte(25) // Y
    .byte(29) // H
    .byte(34) // J
    .byte(33) // I
    .byte(37) // K
    .byte(38) // O
    .byte(42) // L
    .byte(41) // P
    .byte(45) // [
    .byte(50) // ]


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
 * Table with detuning-factors (detuning up the current note from 0 to 100 cent)
 * Because we have to use 16 bit fixed point arithmetic and the values all are near 1
 * multiply with 32768 to spread the values as much as possible. So we get
 * a 16 bit value with 1 bit decimal and 15 bit fraction in the end.
 *
 * Formula: round(2 ^ (x / 1200) * 32768)
 *
 * Type: Array of 16-bit integers
 *
 * ---------------------------------------------------------------- */ 

detuningTable:
    .wo(32768)
    .wo(32787)
    .wo(32806)
    .wo(32825)
    .wo(32844)
    .wo(32863)
    .wo(32882)
    .wo(32901)
    .wo(32920)
    .wo(32939)
    .wo(32958)
    .wo(32977)
    .wo(32996)
    .wo(33015)
    .wo(33034)
    .wo(33053)
    .wo(33072)
    .wo(33091)
    .wo(33110)
    .wo(33130)
    .wo(33149)
    .wo(33168)
    .wo(33187)
    .wo(33206)
    .wo(33225)
    .wo(33245)
    .wo(33264)
    .wo(33283)
    .wo(33302)
    .wo(33322)
    .wo(33341)
    .wo(33360)
    .wo(33379)
    .wo(33399)
    .wo(33418)
    .wo(33437)
    .wo(33457)
    .wo(33476)
    .wo(33495)
    .wo(33515)
    .wo(33534)
    .wo(33553)
    .wo(33573)
    .wo(33592)
    .wo(33611)
    .wo(33631)
    .wo(33650)
    .wo(33670)
    .wo(33689)
    .wo(33709)
    .wo(33728)
    .wo(33748)
    .wo(33767)
    .wo(33787)
    .wo(33806)
    .wo(33826)
    .wo(33845)
    .wo(33865)
    .wo(33884)
    .wo(33904)
    .wo(33924)
    .wo(33943)
    .wo(33963)
    .wo(33982)
    .wo(34002)
    .wo(34022)
    .wo(34041)
    .wo(34061)
    .wo(34081)
    .wo(34100)
    .wo(34120)
    .wo(34140)
    .wo(34160)
    .wo(34179)
    .wo(34199)
    .wo(34219)
    .wo(34239)
    .wo(34258)
    .wo(34278)
    .wo(34298)
    .wo(34318)
    .wo(34338)
    .wo(34357)
    .wo(34377)
    .wo(34397)
    .wo(34417)
    .wo(34437)
    .wo(34457)
    .wo(34477)
    .wo(34497)
    .wo(34517)
    .wo(34536)
    .wo(34556)
    .wo(34576)
    .wo(34596)
    .wo(34616)
    .wo(34636)
    .wo(34656)
    .wo(34676)
    .wo(34696)
    .wo(34716)


/* -------------------------------------------------------------------
 *
 * Lookup table to convert the MIDI values from the pitch bend wheel
 * (0-127, 64 means middle position) into cent values
 * pitch bend value 0: -200 cent, 64: 0 cent, 127: 197 cent
 * 
 * Formula: round((x-64) / 64 * 200)
 *
 * Type: Array of 16-bit signed integers
 *
 * ---------------------------------------------------------------- */ 

pitchBendValuesToCentTable:
    .wo(-200)
    .wo(-197)
    .wo(-194)
    .wo(-191)
    .wo(-188)
    .wo(-184)
    .wo(-181)
    .wo(-178)
    .wo(-175)
    .wo(-172)
    .wo(-169)
    .wo(-166)
    .wo(-163)
    .wo(-159)
    .wo(-156)
    .wo(-153)
    .wo(-150)
    .wo(-147)
    .wo(-144)
    .wo(-141)
    .wo(-138)
    .wo(-134)
    .wo(-131)
    .wo(-128)
    .wo(-125)
    .wo(-122)
    .wo(-119)
    .wo(-116)
    .wo(-113)
    .wo(-109)
    .wo(-106)
    .wo(-103)
    .wo(-100)
    .wo(-97)
    .wo(-94)
    .wo(-91)
    .wo(-88)
    .wo(-84)
    .wo(-81)
    .wo(-78)
    .wo(-75)
    .wo(-72)
    .wo(-69)
    .wo(-66)
    .wo(-63)
    .wo(-59)
    .wo(-56)
    .wo(-53)
    .wo(-50)
    .wo(-47)
    .wo(-44)
    .wo(-41)
    .wo(-38)
    .wo(-34)
    .wo(-31)
    .wo(-28)
    .wo(-25)
    .wo(-22)
    .wo(-19)
    .wo(-16)
    .wo(-13)
    .wo(-9)
    .wo(-6)
    .wo(-3)
    .wo(0)
    .wo(3)
    .wo(6)
    .wo(9)
    .wo(13)
    .wo(16)
    .wo(19)
    .wo(22)
    .wo(25)
    .wo(28)
    .wo(31)
    .wo(34)
    .wo(38)
    .wo(41)
    .wo(44)
    .wo(47)
    .wo(50)
    .wo(53)
    .wo(56)
    .wo(59)
    .wo(63)
    .wo(66)
    .wo(69)
    .wo(72)
    .wo(75)
    .wo(78)
    .wo(81)
    .wo(84)
    .wo(88)
    .wo(91)
    .wo(94)
    .wo(97)
    .wo(100)
    .wo(103)
    .wo(106)
    .wo(109)
    .wo(113)
    .wo(116)
    .wo(119)
    .wo(122)
    .wo(125)
    .wo(128)
    .wo(131)
    .wo(134)
    .wo(138)
    .wo(141)
    .wo(144)
    .wo(147)
    .wo(150)
    .wo(153)
    .wo(156)
    .wo(159)
    .wo(163)
    .wo(166)
    .wo(169)
    .wo(172)
    .wo(175)
    .wo(178)
    .wo(181)
    .wo(184)
    .wo(188)
    .wo(191)
    .wo(194)
    .wo(197)
