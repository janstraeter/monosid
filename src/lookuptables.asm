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
 * Taken from here: https://gist.github.com/matozoid/18cddcbc9cfade3c455bc6230e1f6da6
 * As I understand it, the values are adapted from the original C64 manual.
 *
 * Type: Array of words
 *
 * ---------------------------------------------------------------- */ 

frequencyTablePAL:
    .wo(278) // 0 - C0
    .wo(295) // 1 - C#0
    .wo(313) // 2 - D0
    .wo(331) // 3 - D#0
    .wo(351) // 4 - E0
    .wo(372) // 5 - F0
    .wo(394) // 6 - F#0
    .wo(417) // 7 - G0
    .wo(442) // 8 - G#0
    .wo(468) // 9 - A0
    .wo(496) // 10 - A#0
    .wo(526) // 11 - B0
    .wo(557) // 12 - C1
    .wo(590) // 13 - C#1
    .wo(625) // 14 - D1
    .wo(662) // 15 - D#1
    .wo(702) // 16 - E1
    .wo(743) // 17 - F1
    .wo(788) // 18 - F#1
    .wo(834) // 19 - G1
    .wo(884) // 20 - G#1
    .wo(937) // 21 - A1
    .wo(992) // 22 - A#1
    .wo(1051) // 23 - B1
    .wo(1114) // 24 - C2
    .wo(1180) // 25 - C#2
    .wo(1250) // 26 - D2
    .wo(1325) // 27 - D#2
    .wo(1403) // 28 - E2
    .wo(1487) // 29 - F2
    .wo(1575) // 30 - F#2
    .wo(1669) // 31 - G2
    .wo(1768) // 32 - G#2
    .wo(1873) // 33 - A2
    .wo(1985) // 34 - A#2
    .wo(2103) // 35 - B2
    .wo(2228) // 36 - C3
    .wo(2360) // 37 - C#3
    .wo(2500) // 38 - D3
    .wo(2649) // 39 - D#3
    .wo(2807) // 40 - E3
    .wo(2973) // 41 - F3
    .wo(3150) // 42 - F#3
    .wo(3338) // 43 - G3
    .wo(3536) // 44 - G#3
    .wo(3746) // 45 - A3
    .wo(3969) // 46 - A#3
    .wo(4205) // 47 - B3
    .wo(4455) // 48 - C4
    .wo(4720) // 49 - C#4
    .wo(5001) // 50 - D4
    .wo(5298) // 51 - D#4
    .wo(5613) // 52 - E4
    .wo(5947) // 53 - F4
    .wo(6300) // 54 - F#4
    .wo(6675) // 55 - G4
    .wo(7072) // 56 - G#4
    .wo(7493) // 57 - A4
    .wo(7938) // 58 - A#4
    .wo(8410) // 59 - B4
    .wo(8910) // 60 - C5
    .wo(9440) // 61 - C#5
    .wo(10001) // 62 - D5
    .wo(10596) // 63 - D#5
    .wo(11226) // 64 - E5
    .wo(11894) // 65 - F5
    .wo(12601) // 66 - F#5
    .wo(13350) // 67 - G5
    .wo(14144) // 68 - G#5
    .wo(14985) // 69 - A5
    .wo(15876) // 70 - A#5
    .wo(16820) // 71 - B5
    .wo(17820) // 72 - C6
    .wo(18880) // 73 - C#6
    .wo(20003) // 74 - D6
    .wo(21192) // 75 - D#6
    .wo(22452) // 76 - E6
    .wo(23787) // 77 - F6
    .wo(25202) // 78 - F#6
    .wo(26700) // 79 - G6
    .wo(28288) // 80 - G#6
    .wo(29970) // 81 - A6
    .wo(31752) // 82 - A#6
    .wo(33640) // 83 - B6
    .wo(35641) // 84 - C7
    .wo(37760) // 85 - C#7
    .wo(40005) // 86 - D7
    .wo(42384) // 87 - D#7
    .wo(44904) // 88 - E7
    .wo(47574) // 89 - F7
    .wo(50403) // 90 - F#7
    .wo(53401) // 91 - G7
    .wo(56576) // 92 - G#7
    .wo(59940) // 93 - A7
    .wo(63504) // 94 - A#7
    // .wo(67280) // 95 - B7 -> this would be the correct value, but it does not fit into 16 bit...
    .wo(65535) // 95 - B7 -> ...so we cap it at 65535 instead


/* -------------------------------------------------------------------
 *
 * Frequencies of the notes (NTSC version)
 * Taken from here: https://gist.github.com/matozoid/18cddcbc9cfade3c455bc6230e1f6da6
 * As I understand it, the values are adapted from the original C64 manual.
 *
 * Type: Array of words
 *
 * ---------------------------------------------------------------- */ 

frequencyTableNTSC:
    .wo(268) // 0 - C0
    .wo(284) // 1 - C#0
    .wo(301) // 2 - D0
    .wo(319) // 3 - D#0
    .wo(338) // 4 - E0
    .wo(358) // 5 - F0
    .wo(379) // 6 - F#0
    .wo(402) // 7 - G0
    .wo(426) // 8 - G#0
    .wo(451) // 9 - A0
    .wo(478) // 10 - A#0
    .wo(506) // 11 - B0
    .wo(536) // 12 - C1
    .wo(568) // 13 - C#1
    .wo(602) // 14 - D1
    .wo(638) // 15 - D#1
    .wo(676) // 16 - E1
    .wo(716) // 17 - F1
    .wo(759) // 18 - F#1
    .wo(804) // 19 - G1
    .wo(852) // 20 - G#1
    .wo(902) // 21 - A1
    .wo(956) // 22 - A#1
    .wo(1013) // 23 - B1
    .wo(1073) // 24 - C2
    .wo(1137) // 25 - C#2
    .wo(1204) // 26 - D2
    .wo(1276) // 27 - D#2
    .wo(1352) // 28 - E2
    .wo(1432) // 29 - F2
    .wo(1517) // 30 - F#2
    .wo(1608) // 31 - G2
    .wo(1703) // 32 - G#2
    .wo(1804) // 33 - A2
    .wo(1912) // 34 - A#2
    .wo(2025) // 35 - B2
    .wo(2146) // 36 - C3
    .wo(2274) // 37 - C#3
    .wo(2409) // 38 - D3
    .wo(2552) // 39 - D#3
    .wo(2704) // 40 - E3
    .wo(2864) // 41 - F3
    .wo(3035) // 42 - F#3
    .wo(3215) // 43 - G3
    .wo(3406) // 44 - G#3
    .wo(3609) // 45 - A3
    .wo(3824) // 46 - A#3
    .wo(4051) // 47 - B3
    .wo(4292) // 48 - C4
    .wo(4547) // 49 - C#4
    .wo(4817) // 50 - D4
    .wo(5104) // 51 - D#4
    .wo(5407) // 52 - E4
    .wo(5729) // 53 - F4
    .wo(6070) // 54 - F#4
    .wo(6430) // 55 - G4
    .wo(6813) // 56 - G#4
    .wo(7218) // 57 - A4
    .wo(7647) // 58 - A#4
    .wo(8102) // 59 - B4
    .wo(8584) // 60 - C5
    .wo(9094) // 61 - C#5
    .wo(9635) // 62 - D5
    .wo(10208) // 63 - D#5
    .wo(10815) // 64 - E5
    .wo(11458) // 65 - F5
    .wo(12139) // 66 - F#5
    .wo(12861) // 67 - G5
    .wo(13626) // 68 - G#5
    .wo(14436) // 69 - A5
    .wo(15294) // 70 - A#5
    .wo(16204) // 71 - B5
    .wo(17167) // 72 - C6
    .wo(18188) // 73 - C#6
    .wo(19270) // 74 - D6
    .wo(20415) // 75 - D#6
    .wo(21629) // 76 - E6
    .wo(22916) // 77 - F6
    .wo(24278) // 78 - F#6
    .wo(25722) // 79 - G6
    .wo(27251) // 80 - G#6
    .wo(28872) // 81 - A6
    .wo(30589) // 82 - A#6
    .wo(32407) // 83 - B6
    .wo(34334) // 84 - C7
    .wo(36376) // 85 - C#7
    .wo(38539) // 86 - D7
    .wo(40831) // 87 - D#7
    .wo(43259) // 88 - E7
    .wo(45831) // 89 - F7
    .wo(48556) // 90 - F#7
    .wo(51444) // 91 - G7
    .wo(54503) // 92 - G#7
    .wo(57743) // 93 - A7
    .wo(61177) // 94 - A#7
    .wo(64815) // 95 - B7


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


/* -------------------------------------------------------------------
 *
 * Lookup table to convert the MIDI note velocity values 
 * to the loudest possible volume of the SID chip (15) using a
 * power curve.
 * 
 * Formula: round(((x / 127) ^ 2) * 15)
 *
 * Type: Array of 8-bit unsigned integers
 *
 * ---------------------------------------------------------------- */ 

midiVelocityToVolumeTable:
    .byte(1) // 0 velocity
    .byte(1) // 1
    .byte(1) // 2
    .byte(1) // 3
    .byte(1) // 4
    .byte(1) // 5
    .byte(1) // 6
    .byte(1) // 7
    .byte(1) // 8
    .byte(1) // 9
    .byte(1) // 10
    .byte(1) // 11
    .byte(1) // 12
    .byte(1) // 13
    .byte(1) // 14
    .byte(1) // 15
    .byte(1) // 16
    .byte(1) // 17
    .byte(1) // 18
    .byte(1) // 19
    .byte(1) // 20
    .byte(1) // 21
    .byte(1) // 22
    .byte(1) // 23

    .byte(1) // 24
    .byte(1) // 25
    .byte(1) // 26
    .byte(1) // 27
    .byte(1) // 28
    .byte(1) // 29
    .byte(1) // 30
    .byte(1) // 31
    .byte(1) // 32
    .byte(1) // 33
    .byte(1) // 34
    .byte(1) // 35
    .byte(1) // 36
    .byte(1) // 37
    .byte(1) // 38
    .byte(1) // 39
    .byte(1) // 40
    .byte(2) // 41
    .byte(2) // 42
    .byte(2) // 43
    .byte(2) // 44
    .byte(2) // 45
    .byte(2) // 46
    .byte(2) // 47
    .byte(2) // 48
    .byte(2) // 49
    .byte(2) // 50
    .byte(2) // 51
    .byte(3) // 52
    .byte(3) // 53
    .byte(3) // 54
    .byte(3) // 55
    .byte(3) // 56
    .byte(3) // 57
    .byte(3) // 58
    .byte(3) // 59
    .byte(3) // 60
    .byte(3) // 61
    .byte(4) // 62
    .byte(4) // 63
    .byte(4) // 64
    .byte(4) // 65
    .byte(4) // 66
    .byte(4) // 67
    .byte(4) // 68
    .byte(4) // 69
    .byte(5) // 70
    .byte(5) // 71
    .byte(5) // 72
    .byte(5) // 73
    .byte(5) // 74
    .byte(5) // 75
    .byte(5) // 76
    .byte(6) // 77
    .byte(6) // 78
    .byte(6) // 79
    .byte(6) // 80
    .byte(6) // 81
    .byte(6) // 82
    .byte(6) // 83
    .byte(7) // 84
    .byte(7) // 85
    .byte(7) // 86
    .byte(7) // 87
    .byte(7) // 88
    .byte(7) // 89
    .byte(8) // 90
    .byte(8) // 91
    .byte(8) // 92
    .byte(8) // 93
    .byte(8) // 94
    .byte(8) // 95
    .byte(9) // 96
    .byte(9) // 97
    .byte(9) // 98
    .byte(9) // 99
    .byte(9) // 100
    .byte(9) // 101
    .byte(10) // 102
    .byte(10) // 103
    .byte(10) // 104
    .byte(10) // 105
    .byte(10) // 106
    .byte(11) // 107
    .byte(11) // 108
    .byte(11) // 109
    .byte(11) // 110
    .byte(11) // 111
    .byte(12) // 112
    .byte(12) // 113
    .byte(12) // 114
    .byte(12) // 115
    .byte(13) // 116
    .byte(13) // 117
    .byte(13) // 118
    .byte(13) // 119
    .byte(13) // 120
    .byte(14) // 121
    .byte(14) // 122
    .byte(14) // 123
    .byte(14) // 124
    .byte(15) // 125
    .byte(15) // 126
    .byte(15) // 127


/* -------------------------------------------------------------------
 *
 * Lookup table to calculate the product of two given volume values,
 * divided by 15
 *
 * Formula round(a * b / 15)
 * (basically a 4x4 bit multiplication matrix, but divided by 15)
 *
 * Type: Array of 8-bit unsigned integers
 *
 * ---------------------------------------------------------------- */ 

multiplyVolumeByVolumeTable:
    .byte(0) // 0 x 0 / 15
    .byte(0) // 0 x 1 / 15
    .byte(0) // 0 x 2 / 15
    .byte(0) // 0 x 3 / 15
    .byte(0) // 0 x 4 / 15
    .byte(0) // 0 x 5 / 15
    .byte(0) // 0 x 6 / 15
    .byte(0) // 0 x 7 / 15
    .byte(0) // 0 x 8 / 15
    .byte(0) // 0 x 9 / 15
    .byte(0) // 0 x 10 / 15
    .byte(0) // 0 x 11 / 15
    .byte(0) // 0 x 12 / 15
    .byte(0) // 0 x 13 / 15
    .byte(0) // 0 x 14 / 15
    .byte(0) // 0 x 15 / 15
    .byte(0) // 1 x 0 / 15
    .byte(0) // 1 x 1 / 15
    .byte(0) // 1 x 2 / 15
    .byte(0) // 1 x 3 / 15
    .byte(0) // 1 x 4 / 15
    .byte(0) // 1 x 5 / 15
    .byte(0) // 1 x 6 / 15
    .byte(0) // 1 x 7 / 15
    .byte(1) // 1 x 8 / 15
    .byte(1) // 1 x 9 / 15
    .byte(1) // 1 x 10 / 15
    .byte(1) // 1 x 11 / 15
    .byte(1) // 1 x 12 / 15
    .byte(1) // 1 x 13 / 15
    .byte(1) // 1 x 14 / 15
    .byte(1) // 1 x 15 / 15
    .byte(0) // 2 x 0 / 15
    .byte(0) // 2 x 1 / 15
    .byte(0) // 2 x 2 / 15
    .byte(0) // 2 x 3 / 15
    .byte(1) // 2 x 4 / 15
    .byte(1) // 2 x 5 / 15
    .byte(1) // 2 x 6 / 15
    .byte(1) // 2 x 7 / 15
    .byte(1) // 2 x 8 / 15
    .byte(1) // 2 x 9 / 15
    .byte(1) // 2 x 10 / 15
    .byte(1) // 2 x 11 / 15
    .byte(2) // 2 x 12 / 15
    .byte(2) // 2 x 13 / 15
    .byte(2) // 2 x 14 / 15
    .byte(2) // 2 x 15 / 15
    .byte(0) // 3 x 0 / 15
    .byte(0) // 3 x 1 / 15
    .byte(0) // 3 x 2 / 15
    .byte(1) // 3 x 3 / 15
    .byte(1) // 3 x 4 / 15
    .byte(1) // 3 x 5 / 15
    .byte(1) // 3 x 6 / 15
    .byte(1) // 3 x 7 / 15
    .byte(2) // 3 x 8 / 15
    .byte(2) // 3 x 9 / 15
    .byte(2) // 3 x 10 / 15
    .byte(2) // 3 x 11 / 15
    .byte(2) // 3 x 12 / 15
    .byte(3) // 3 x 13 / 15
    .byte(3) // 3 x 14 / 15
    .byte(3) // 3 x 15 / 15
    .byte(0) // 4 x 0 / 15
    .byte(0) // 4 x 1 / 15
    .byte(1) // 4 x 2 / 15
    .byte(1) // 4 x 3 / 15
    .byte(1) // 4 x 4 / 15
    .byte(1) // 4 x 5 / 15
    .byte(2) // 4 x 6 / 15
    .byte(2) // 4 x 7 / 15
    .byte(2) // 4 x 8 / 15
    .byte(2) // 4 x 9 / 15
    .byte(3) // 4 x 10 / 15
    .byte(3) // 4 x 11 / 15
    .byte(3) // 4 x 12 / 15
    .byte(3) // 4 x 13 / 15
    .byte(4) // 4 x 14 / 15
    .byte(4) // 4 x 15 / 15
    .byte(0) // 5 x 0 / 15
    .byte(0) // 5 x 1 / 15
    .byte(1) // 5 x 2 / 15
    .byte(1) // 5 x 3 / 15
    .byte(1) // 5 x 4 / 15
    .byte(2) // 5 x 5 / 15
    .byte(2) // 5 x 6 / 15
    .byte(2) // 5 x 7 / 15
    .byte(3) // 5 x 8 / 15
    .byte(3) // 5 x 9 / 15
    .byte(3) // 5 x 10 / 15
    .byte(4) // 5 x 11 / 15
    .byte(4) // 5 x 12 / 15
    .byte(4) // 5 x 13 / 15
    .byte(5) // 5 x 14 / 15
    .byte(5) // 5 x 15 / 15
    .byte(0) // 6 x 0 / 15
    .byte(0) // 6 x 1 / 15
    .byte(1) // 6 x 2 / 15
    .byte(1) // 6 x 3 / 15
    .byte(2) // 6 x 4 / 15
    .byte(2) // 6 x 5 / 15
    .byte(2) // 6 x 6 / 15
    .byte(3) // 6 x 7 / 15
    .byte(3) // 6 x 8 / 15
    .byte(4) // 6 x 9 / 15
    .byte(4) // 6 x 10 / 15
    .byte(4) // 6 x 11 / 15
    .byte(5) // 6 x 12 / 15
    .byte(5) // 6 x 13 / 15
    .byte(6) // 6 x 14 / 15
    .byte(6) // 6 x 15 / 15
    .byte(0) // 7 x 0 / 15
    .byte(0) // 7 x 1 / 15
    .byte(1) // 7 x 2 / 15
    .byte(1) // 7 x 3 / 15
    .byte(2) // 7 x 4 / 15
    .byte(2) // 7 x 5 / 15
    .byte(3) // 7 x 6 / 15
    .byte(3) // 7 x 7 / 15
    .byte(4) // 7 x 8 / 15
    .byte(4) // 7 x 9 / 15
    .byte(5) // 7 x 10 / 15
    .byte(5) // 7 x 11 / 15
    .byte(6) // 7 x 12 / 15
    .byte(6) // 7 x 13 / 15
    .byte(7) // 7 x 14 / 15
    .byte(7) // 7 x 15 / 15
    .byte(0) // 8 x 0 / 15
    .byte(1) // 8 x 1 / 15
    .byte(1) // 8 x 2 / 15
    .byte(2) // 8 x 3 / 15
    .byte(2) // 8 x 4 / 15
    .byte(3) // 8 x 5 / 15
    .byte(3) // 8 x 6 / 15
    .byte(4) // 8 x 7 / 15
    .byte(4) // 8 x 8 / 15
    .byte(5) // 8 x 9 / 15
    .byte(5) // 8 x 10 / 15
    .byte(6) // 8 x 11 / 15
    .byte(6) // 8 x 12 / 15
    .byte(7) // 8 x 13 / 15
    .byte(7) // 8 x 14 / 15
    .byte(8) // 8 x 15 / 15
    .byte(0) // 9 x 0 / 15
    .byte(1) // 9 x 1 / 15
    .byte(1) // 9 x 2 / 15
    .byte(2) // 9 x 3 / 15
    .byte(2) // 9 x 4 / 15
    .byte(3) // 9 x 5 / 15
    .byte(4) // 9 x 6 / 15
    .byte(4) // 9 x 7 / 15
    .byte(5) // 9 x 8 / 15
    .byte(5) // 9 x 9 / 15
    .byte(6) // 9 x 10 / 15
    .byte(7) // 9 x 11 / 15
    .byte(7) // 9 x 12 / 15
    .byte(8) // 9 x 13 / 15
    .byte(8) // 9 x 14 / 15
    .byte(9) // 9 x 15 / 15
    .byte(0) // 10 x 0 / 15
    .byte(1) // 10 x 1 / 15
    .byte(1) // 10 x 2 / 15
    .byte(2) // 10 x 3 / 15
    .byte(3) // 10 x 4 / 15
    .byte(3) // 10 x 5 / 15
    .byte(4) // 10 x 6 / 15
    .byte(5) // 10 x 7 / 15
    .byte(5) // 10 x 8 / 15
    .byte(6) // 10 x 9 / 15
    .byte(7) // 10 x 10 / 15
    .byte(7) // 10 x 11 / 15
    .byte(8) // 10 x 12 / 15
    .byte(9) // 10 x 13 / 15
    .byte(9) // 10 x 14 / 15
    .byte(10) // 10 x 15 / 15
    .byte(0) // 11 x 0 / 15
    .byte(1) // 11 x 1 / 15
    .byte(1) // 11 x 2 / 15
    .byte(2) // 11 x 3 / 15
    .byte(3) // 11 x 4 / 15
    .byte(4) // 11 x 5 / 15
    .byte(4) // 11 x 6 / 15
    .byte(5) // 11 x 7 / 15
    .byte(6) // 11 x 8 / 15
    .byte(7) // 11 x 9 / 15
    .byte(7) // 11 x 10 / 15
    .byte(8) // 11 x 11 / 15
    .byte(9) // 11 x 12 / 15
    .byte(10) // 11 x 13 / 15
    .byte(10) // 11 x 14 / 15
    .byte(11) // 11 x 15 / 15
    .byte(0) // 12 x 0 / 15
    .byte(1) // 12 x 1 / 15
    .byte(2) // 12 x 2 / 15
    .byte(2) // 12 x 3 / 15
    .byte(3) // 12 x 4 / 15
    .byte(4) // 12 x 5 / 15
    .byte(5) // 12 x 6 / 15
    .byte(6) // 12 x 7 / 15
    .byte(6) // 12 x 8 / 15
    .byte(7) // 12 x 9 / 15
    .byte(8) // 12 x 10 / 15
    .byte(9) // 12 x 11 / 15
    .byte(10) // 12 x 12 / 15
    .byte(10) // 12 x 13 / 15
    .byte(11) // 12 x 14 / 15
    .byte(12) // 12 x 15 / 15
    .byte(0) // 13 x 0 / 15
    .byte(1) // 13 x 1 / 15
    .byte(2) // 13 x 2 / 15
    .byte(3) // 13 x 3 / 15
    .byte(3) // 13 x 4 / 15
    .byte(4) // 13 x 5 / 15
    .byte(5) // 13 x 6 / 15
    .byte(6) // 13 x 7 / 15
    .byte(7) // 13 x 8 / 15
    .byte(8) // 13 x 9 / 15
    .byte(9) // 13 x 10 / 15
    .byte(10) // 13 x 11 / 15
    .byte(10) // 13 x 12 / 15
    .byte(11) // 13 x 13 / 15
    .byte(12) // 13 x 14 / 15
    .byte(13) // 13 x 15 / 15
    .byte(0) // 14 x 0 / 15
    .byte(1) // 14 x 1 / 15
    .byte(2) // 14 x 2 / 15
    .byte(3) // 14 x 3 / 15
    .byte(4) // 14 x 4 / 15
    .byte(5) // 14 x 5 / 15
    .byte(6) // 14 x 6 / 15
    .byte(7) // 14 x 7 / 15
    .byte(7) // 14 x 8 / 15
    .byte(8) // 14 x 9 / 15
    .byte(9) // 14 x 10 / 15
    .byte(10) // 14 x 11 / 15
    .byte(11) // 14 x 12 / 15
    .byte(12) // 14 x 13 / 15
    .byte(13) // 14 x 14 / 15
    .byte(14) // 14 x 15 / 15
    .byte(0) // 15 x 0 / 15
    .byte(1) // 15 x 1 / 15
    .byte(2) // 15 x 2 / 15
    .byte(3) // 15 x 3 / 15
    .byte(4) // 15 x 4 / 15
    .byte(5) // 15 x 5 / 15
    .byte(6) // 15 x 6 / 15
    .byte(7) // 15 x 7 / 15
    .byte(8) // 15 x 8 / 15
    .byte(9) // 15 x 9 / 15
    .byte(10) // 15 x 10 / 15
    .byte(11) // 15 x 11 / 15
    .byte(12) // 15 x 12 / 15
    .byte(13) // 15 x 13 / 15
    .byte(14) // 15 x 14 / 15
    .byte(15) // 15 x 15 / 15
