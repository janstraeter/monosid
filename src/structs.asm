#importonce

#import "constants.asm"
#import "screenmemoryfunctions.asm"


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
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Creates a new instance of the module struct
 *
 * ---------------------------------------------------------------- */ 

.macro createStructModule(name, left, top, innerWidth, innerHeight, color, inputArrayNum, inputArray) {
    
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
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Creates a new instance of the input struct
 *
 * ---------------------------------------------------------------- */ 

.macro createStructInput(type, left, top, width, label, valueLo, valueHi) {    
    
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

    .var inputMemoryAddress = screenCalculateMemoryAddress(left, top)
    .var inputColorMemoryAddress = screenCalculateColorMemoryAddress(left, top)

    .var labelMemoryAddress = screenCalculateMemoryAddress(labelLeft, labelTop)
    .var labelColorMemoryAddress = screenCalculateColorMemoryAddress(labelLeft, labelTop)

    .byte(type)                         // $00 TYPE
    .byte(left)                         // $01 LEFT
    .byte(top)                          // $02 TOP
    .byte(width)                        // $03 WIDTH
    .byte(<inputMemoryAddress)          // $04 SCREEN_MEMORY
    .byte(>inputMemoryAddress)          // $05
    .byte(<inputColorMemoryAddress)     // $06 COLOR_MEMORY
    .byte(>inputColorMemoryAddress)     // $07
    .byte(<label)                       // $08 LABEL
    .byte(>label)                       // $09
    .byte(labelLeft)                    // $0a LABEL_LEFT
    .byte(labelTop)                     // $0b LABEL_TOP
    .byte(labelWidth)                   // $0c LABEL_WIDTH
    .byte(<labelMemoryAddress)          // $0d LABEL_SCREEN_MEMORY
    .byte(>labelMemoryAddress)          // $0e
    .byte(<labelColorMemoryAddress)     // $0f LABEL_COLOR_MEMORY
    .byte(>labelColorMemoryAddress)     // $10
    .byte(valueLo)                      // $11 VALUE
    .byte(valueHi)                      // $12
}
