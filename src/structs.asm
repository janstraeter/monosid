#importonce

/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to load a byte from a struct
 * into the accu
 *
 * Parameters:   ZPR:         address of zeropage register
 *               structIndex: index to load into the Y register
 * 
 * ---------------------------------------------------------------- */ 

.macro structLoadByteToAccu(ZPR, structIndex) {
    ldy #structIndex
    lda (ZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to write a byte from the accu
 * into a struct
 *
 * Parameters:   Accu:        value to write into the struct
 *               ZPR:         address of zeropage register
 *               structIndex: index to load into the Y register
 * 
 * ---------------------------------------------------------------- */ 

.macro structWriteByteFromAccu(ZPR, structIndex) {
    ldy #structIndex
    sta (ZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to write a byte value
 * into a struct
 *
 * Parameters:   ZPR:         address of zeropage register
 *               structIndex: index to load into the Y register
 *               byteValue:   value to write into the struct
 * 
 * ---------------------------------------------------------------- */ 

.macro structWriteByteValue(ZPR, structIndex, byteValue) {
    lda #byteValue
    ldy #structIndex
    sta (ZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to load 2 bytes from a struct
 * and save them into the specified zeropage register
 *
 * Parameters:   srcZPR:      address of zeropage register (the struct)
 *               structIndex: index to load into the Y register
 *               destZPR:     address of zeropage register to write into
 * 
 * ---------------------------------------------------------------- */ 

.macro structLoadWordToZPR(srcZPR, structIndex, destZPR) {
    ldy #structIndex
    lda (srcZPR), y
    sta destZPR
    iny
    lda (srcZPR), y
    sta destZPR+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to load 2 bytes from a struct
 * and saves the hi-byte into the accu and the lo-byte into the X-register
 *
 * Parameters:   srcZPR:      address of zeropage register (the struct)
 *               structIndex: index to load into the X register
 * 
 * ---------------------------------------------------------------- */ 

.macro structLoadWordToXAccu(srcZPR, structIndex) {
    ldy #structIndex
    lda (srcZPR), y
    tax
    iny
    lda (srcZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to write 2 bytes from the accu
 * (hi-byte) and the X-register (lo-byte) into a struct
 *
 * Parameters:   Accu:        hi-byte to write into the struct
 *               X-register:  lo-byte
 *               srcZPR:      address of zeropage register (the struct)
 *               structIndex: index to load into the X register
 * 
 * ---------------------------------------------------------------- */ 

.macro structWriteWordFromXAccu(srcZPR, structIndex) {
    ldy #structIndex+1
    sta (srcZPR), y
    txa
    dey
    sta (srcZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to write a word value into a struct
 *
 * Parameters:   srcZPR:      address of zeropage register (the struct)
 *               structIndex: index to load into the X register
 *               wordValue:   value to write into the struct
 * 
 * ---------------------------------------------------------------- */ 

.macro structWriteWordValue(srcZPR, structIndex, wordValue) {
    lda #<wordValue
    ldy #structIndex
    sta (srcZPR), y
    lda #>wordValue
    iny
    sta (srcZPR), y
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to load 2 bytes from a struct
 * and saves it at the provied address
 *
 * Parameters:   srcZPR:      address of zeropage register (the struct)
 *               structIndex: index to load into the X register
 *               address      address of the destination
 * 
 * ---------------------------------------------------------------- */ 

.macro structLoadWordToAddress(srcZPR, structIndex, address) {
    ldy #structIndex
    lda (srcZPR), y
    sta address
    iny
    lda (srcZPR), y
    sta address+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Uses indirect-indexed addressing to load 2 bytes from an array of
 * pointers and saves the hi-byte into the accu and the lo-byte into the X-register
 * 
 * Parameters:   arrayAddressZPR:   address of zeropage register (pointer to array)
 *               arrayIndex:        index of array item
 *               destZPR:           address of zeropage register to write into
 * 
 * ---------------------------------------------------------------- */ 

.macro stuctLoadPointerArrayItemToZPR(arrayAddressZPR, arrayIndex, destZPR) {
	lda arrayIndex
	asl
	tay
	lda (arrayAddressZPR), y
	sta destZPR
	iny 
	lda (arrayAddressZPR), y
	sta destZPR+1
}


/* -------------------------------------------------------------------
 * Struct definition
 * -----------------
 *
 * Holds all information of a module (name, color, position on screen,
 * list of structs with input elements)
 *
 * ---------------------------------------------------------------- */ 

.namespace STRUCT_MODULE {
    // label of module
    .label NAME = $00
    
    // position and size of module
    .label LEFT = $02
    .label RIGHT = $03
    .label INNER_WIDTH = $04
    .label INNER_HEIGHT = $05
    
    // color of module border
    .label COLOR = $06
    
    // precalculated offsets into screen- and color-memory
    .label NAME_SCREEN_MEMORY = $07
    .label NAME_COLOR_MEMORY = $09
    .label RECT_SCREEN_MEMORY = $0B
    .label RECT_COLOR_MEMORY = $0D
    
    // array with input elements
    .label INPUT_ARRAY_NUM = $0F
    .label INPUT_ARRAY = $10

    // page
    .label PAGE = $12;
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Creates a new instance of the module struct
 *
 * ---------------------------------------------------------------- */ 

.macro createStructModule(name, left, top, innerWidth, innerHeight, color, inputArrayNum, inputArray, page) {
    
    // We can pre-calculate the screen- and color-memory adresses
    // to avoid the costly multiplications during run-time because
    // the position on the screen will never change

	// The name should appear one line above and one pos to the right of
	// the upper left corner of the rectangle
    .var nameMemoryAddress = screenCalculateMemoryAddress(left + 1, top - 1)
    .var nameColorMemoryAddress = screenCalculateColorMemoryAddress(left + 1, top - 1)

    // The rectangle is given by left, top, innerWidth and innerHeight
    .var rectMemoryAddress = screenCalculateMemoryAddress(left, top)
    .var rectColorMemoryAddress = screenCalculateColorMemoryAddress(left, top)

    .byte(<name)                   // $00 NAME
    .byte(>name)                   // $01
    .byte(left)                    // $02 LEFT
    .byte(top)                     // $03 RIGHT
    .byte(innerWidth)              // $04 INNER_WIDTH
    .byte(innerHeight)             // $05 INNER_HEIGHT
    .byte(color)                   // $06 COLOR
    .byte(<nameMemoryAddress)      // $07 NAME_SCREEN_MEMORY
    .byte(>nameMemoryAddress)      // $08
    .byte(<nameColorMemoryAddress) // $09 NAME_COLOR_MEMORY
    .byte(>nameColorMemoryAddress) // $0A
    .byte(<rectMemoryAddress)      // $0B RECT_SCREEN_MEMORY
    .byte(>rectMemoryAddress)      // $0C
    .byte(<rectColorMemoryAddress) // $0D RECT_COLOR_MEMORY
    .byte(>rectColorMemoryAddress) // $0E
    .byte(inputArrayNum)           // $0F INPUT_ARRAY_NUM
    .byte(<inputArray)             // $10 INPUT_ARRAY
    .byte(>inputArray)             // $11
    .byte(page)                    // $12
}


/* -------------------------------------------------------------------
 * Struct definition
 * -----------------
 *
 * Holds all information of an input element
 *
 * ---------------------------------------------------------------- */ 

.namespace STRUCT_INPUT {
    // type of input
    .label TYPE = $00

    // position of input and precalculated offsets into screen- and color-memory
    .label LEFT = $01
    .label TOP = $02
    .label WIDTH = $03
    .label SCREEN_MEMORY = $04
    .label COLOR_MEMORY = $06

    // label, position of label and precalculated offsets into screen- and color-memory
    .label LABEL = $08
    .label LABEL_LEFT = $0a
    .label LABEL_TOP = $0b
    .label LABEL_WIDTH = $0c
    .label LABEL_SCREEN_MEMORY = $0d
    .label LABEL_COLOR_MEMORY = $0f

    // current value of input
    .label VALUE = $11

    // pointer to SID update subroutine
    .label UPDATE_SUBROUTINE = $13

    // unique input ID (IID)
    .label IID = $15

    // IIDs of input elements to focus when cursor keys are pressed
    .label LEFT_NEIGHBOR_IID = $16
    .label RIGHT_NEIGHBOR_IID = $17
    .label TOP_NEIGHBOR_IID = $18
    .label BOTTOM_NEIGHBOR_IID = $19
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Creates a new instance of the input struct
 *
 * ---------------------------------------------------------------- */ 

.macro createStructInput(type, left, top, width, labelAddress, valueLo, valueHi, updateSubroutineAddress,
                         IID, leftNeighborIID, rightNeighborIID, topNeighborIID, bottomNeighborIID) {    
    
    // For the boolean inputs the label starts 1 character right to the input
    // for all other inputs the label starts 1 line above
    .var labelLeft = left
    .var labelTop = top - 1
    .var labelWidth = width

    .if (type == INPUT_TYPE.BOOLEAN) {
        .eval labelLeft = left + 1
        .eval labelTop = top
        .eval labelWidth = width - 1
    }

    // We can pre-calculate the screen- and color-memory adresses
    // to avoid the costly multiplications during run-time because
    // the position on the screen will never change

    .var inputScreenMemoryAddress = screenCalculateMemoryAddress(left, top)
    .var inputColorMemoryAddress = screenCalculateColorMemoryAddress(left, top)

    .var labelScreenMemoryAddress = screenCalculateMemoryAddress(labelLeft, labelTop)
    .var labelColorMemoryAddress = screenCalculateColorMemoryAddress(labelLeft, labelTop)

    .byte(type)                         // $00 TYPE
    .byte(left)                         // $01 LEFT
    .byte(top)                          // $02 TOP
    .byte(width)                        // $03 WIDTH
    .byte(<inputScreenMemoryAddress)    // $04 SCREEN_MEMORY
    .byte(>inputScreenMemoryAddress)    // $05
    .byte(<inputColorMemoryAddress)     // $06 COLOR_MEMORY
    .byte(>inputColorMemoryAddress)     // $07
    .byte(<labelAddress)                // $08 LABEL
    .byte(>labelAddress)                // $09
    .byte(labelLeft)                    // $0a LABEL_LEFT
    .byte(labelTop)                     // $0b LABEL_TOP
    .byte(labelWidth)                   // $0c LABEL_WIDTH
    .byte(<labelScreenMemoryAddress)    // $0d LABEL_SCREEN_MEMORY
    .byte(>labelScreenMemoryAddress)    // $0e
    .byte(<labelColorMemoryAddress)     // $0f LABEL_COLOR_MEMORY
    .byte(>labelColorMemoryAddress)     // $10
    .byte(valueLo)                      // $11 VALUE
    .byte(valueHi)                      // $12
    .byte(<updateSubroutineAddress)     // $13 UPDATE_SUBROUTINE
    .byte(>updateSubroutineAddress)     // $14
    .byte(IID)                          // $15
    .byte(leftNeighborIID)              // $16
    .byte(rightNeighborIID)             // $17
    .byte(topNeighborIID)               // $18
    .byte(bottomNeighborIID)            // $19
}


/* -------------------------------------------------------------------
 * Struct definition
 * -----------------
 *
 * Holds all information of a patch
 *
 * ---------------------------------------------------------------- */ 

.namespace STRUCT_PATCH {
    // name, 8 charachters long null terminated string (9 byte)
    .label NAME                                    = 0

    // voice 1
    .label VOICE_1_INPUT_WAVEFORM                  = 9
    .label VOICE_1_INPUT_PULSEWIDTH                = 10
    .label VOICE_1_INPUT_ATTACK                    = 12
    .label VOICE_1_INPUT_DECAY                     = 13
    .label VOICE_1_INPUT_SUSTAIN                   = 14
    .label VOICE_1_INPUT_RELEASE                   = 15
    .label VOICE_1_INPUT_USE                       = 16
    .label VOICE_1_INPUT_SYNC                      = 17
    .label VOICE_1_INPUT_RINGMOD                   = 18

    // voice 2
    .label VOICE_2_INPUT_WAVEFORM                  = 19
    .label VOICE_2_INPUT_PULSEWIDTH                = 20
    .label VOICE_2_INPUT_ATTACK                    = 22
    .label VOICE_2_INPUT_DECAY                     = 23
    .label VOICE_2_INPUT_SUSTAIN                   = 24
    .label VOICE_2_INPUT_RELEASE                   = 25
    .label VOICE_2_INPUT_USE                       = 26
    .label VOICE_2_INPUT_SYNC                      = 27
    .label VOICE_2_INPUT_RINGMOD                   = 28

    // voice 3
    .label VOICE_3_INPUT_WAVEFORM                  = 29
    .label VOICE_3_INPUT_PULSEWIDTH                = 30
    .label VOICE_3_INPUT_ATTACK                    = 32
    .label VOICE_3_INPUT_DECAY                     = 33
    .label VOICE_3_INPUT_SUSTAIN                   = 34
    .label VOICE_3_INPUT_RELEASE                   = 35
    .label VOICE_3_INPUT_USE                       = 36
    .label VOICE_3_INPUT_SYNC                      = 37
    .label VOICE_3_INPUT_RINGMOD                   = 38

    // filter
    .label FILTER_INPUT_CUTOFF                     = 39
    .label FILTER_INPUT_RESONANCE                  = 41
    .label FILTER_INPUT_VOICE_1                    = 42
    .label FILTER_INPUT_VOICE_2                    = 43
    .label FILTER_INPUT_VOICE_3                    = 44
    .label FILTER_INPUT_LOWPASS                    = 45
    .label FILTER_INPUT_HIGHPASS                   = 46
    .label FILTER_INPUT_BANDWIDTH                  = 47

    // main volume
    .label MAIN_INPUT_VOL                          = 48

    // detuning
    .label DETUNING_INPUT_VOICE_1                  = 49
    .label DETUNING_INPUT_DETUNE_DOWN_VOICE_1      = 51
    .label DETUNING_INPUT_VOICE_2                  = 52
    .label DETUNING_INPUT_DETUNE_DOWN_VOICE_2      = 54
    .label DETUNING_INPUT_VOICE_3                  = 55
    .label DETUNING_INPUT_DETUNE_DOWN_VOICE_3      = 57

    // reset oscillators
    .label RESET_OSCILLATOR_VOICE_1                = 58
    .label RESET_OSCILLATOR_VOICE_2                = 59
    .label RESET_OSCILLATOR_VOICE_3                = 60

    // velocity
    .label VELOCITY_USE                            = 61
    .label VELOCITY_SUSTAIN                        = 62

    // LFO
    .label LFO_CYCLE_LENGTH                        = 63
    .label LFO_MOD_PITCH                           = 65
    .label LFO_MOD_PULSE                           = 66
    .label LFO_MOD_FILTER                          = 67
    .label LFO_SQUARE_WAVE                         = 68
    .label LFO_RESET_OSC                           = 69
    .label LFO_MOD_WITH_V3_EG                      = 70
    .label LFO_MUTE_VOICE_3                        = 71
    .label LFO_PITCH                               = 72
    .label LFO_PITCH_NEG                           = 74
    .label LFO_PULSE                               = 75
    .label LFO_PULSE_NEG                           = 77
    .label LFO_CUTOFF                              = 78
    .label LFO_CUTOFF_NEG                          = 80

    // 9 bytes reserved for future use
    .label RESERVED_FOR_FUTURE_USE                 = 81
}
