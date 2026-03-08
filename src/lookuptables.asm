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
 * Frequencies of the notes (PAL version)
 * Taken from here: https://gist.github.com/matozoid/18cddcbc9cfade3c455bc6230e1f6da6
 * As I understand it, the values are adapted from the original C64 manual.
 *
 * Type: Array of words
 *
 * ---------------------------------------------------------------- */ 

frequencyTableNTSC:
    .wo(268) // 0 - C
    .wo(284) // 1 - C#
    .wo(301) // 2 - D
    .wo(319) // 3 - D#
    .wo(338) // 4 - E
    .wo(358) // 5 - F
    .wo(379) // 6 - F#
    .wo(402) // 7 - G
    .wo(426) // 8 - G#
    .wo(451) // 9 - A
    .wo(478) // 10 - A#
    .wo(506) // 11 - B
    .wo(536) // 12 - C
    .wo(568) // 13 - C#
    .wo(602) // 14 - D
    .wo(638) // 15 - D#
    .wo(676) // 16 - E
    .wo(716) // 17 - F
    .wo(759) // 18 - F#
    .wo(804) // 19 - G
    .wo(852) // 20 - G#
    .wo(902) // 21 - A
    .wo(956) // 22 - A#
    .wo(1013) // 23 - B
    .wo(1073) // 24 - C
    .wo(1137) // 25 - C#
    .wo(1204) // 26 - D
    .wo(1276) // 27 - D#
    .wo(1352) // 28 - E
    .wo(1432) // 29 - F
    .wo(1517) // 30 - F#
    .wo(1608) // 31 - G
    .wo(1703) // 32 - G#
    .wo(1804) // 33 - A
    .wo(1912) // 34 - A#
    .wo(2025) // 35 - B
    .wo(2146) // 36 - C
    .wo(2274) // 37 - C#
    .wo(2409) // 38 - D
    .wo(2552) // 39 - D#
    .wo(2704) // 40 - E
    .wo(2864) // 41 - F
    .wo(3035) // 42 - F#
    .wo(3215) // 43 - G
    .wo(3406) // 44 - G#
    .wo(3609) // 45 - A
    .wo(3824) // 46 - A#
    .wo(4051) // 47 - B
    .wo(4292) // 48 - C
    .wo(4547) // 49 - C#
    .wo(4817) // 50 - D
    .wo(5104) // 51 - D#
    .wo(5407) // 52 - E
    .wo(5729) // 53 - F
    .wo(6070) // 54 - F#
    .wo(6430) // 55 - G
    .wo(6813) // 56 - G#
    .wo(7218) // 57 - A
    .wo(7647) // 58 - A#
    .wo(8102) // 59 - B
    .wo(8584) // 60 - C
    .wo(9094) // 61 - C#
    .wo(9635) // 62 - D
    .wo(10208) // 63 - D#
    .wo(10815) // 64 - E
    .wo(11458) // 65 - F
    .wo(12139) // 66 - F#
    .wo(12861) // 67 - G
    .wo(13626) // 68 - G#
    .wo(14436) // 69 - A
    .wo(15294) // 70 - A#
    .wo(16204) // 71 - B
    .wo(17167) // 72 - C
    .wo(18188) // 73 - C#
    .wo(19270) // 74 - D
    .wo(20415) // 75 - D#
    .wo(21629) // 76 - E
    .wo(22916) // 77 - F
    .wo(24278) // 78 - F#
    .wo(25722) // 79 - G
    .wo(27251) // 80 - G#
    .wo(28872) // 81 - A
    .wo(30589) // 82 - A#
    .wo(32407) // 83 - B
    .wo(34334) // 84 - C
    .wo(36376) // 85 - C#
    .wo(38539) // 86 - D
    .wo(40831) // 87 - D#
    .wo(43259) // 88 - E
    .wo(45831) // 89 - F
    .wo(48556) // 90 - F#
    .wo(51444) // 91 - G
    .wo(54503) // 92 - G#
    .wo(57743) // 93 - A
    .wo(61177) // 94 - A#
    .wo(64815) // 95 - B


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
