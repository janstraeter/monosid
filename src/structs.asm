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
 * Struct definition
 * -----------------
 *
 * Holds all information of a module (name, color, position on screen,
 * list of structs with input elements)
 *
 * ---------------------------------------------------------------- */ 

.namespace STRUCT_MODULE {
    .label NAME = $00
    .label LEFT = $02
    .label RIGHT = $03
    .label INNER_WIDTH = $04
    .label INNER_HEIGHT = $05
    .label COLOR = $06
    .label NAME_SCREEN_MEMORY = $07
    .label NAME_COLOR_MEMORY = $09
    .label RECT_SCREEN_MEMORY = $0B
    .label RECT_COLOR_MEMORY = $0D
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

.macro createStructModule(name, left, top, innerWidth, innerHeight, color) {    
    
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
    .byte($00)                     // $0F INPUT_ARRAY_NUM
    .byte($00)                     // $10 INPUT_ARRAY
}

