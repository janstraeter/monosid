#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the screen memory (fills the sceen memory with the space character)
 *
 * ---------------------------------------------------------------- */ 

screenClear:
{
    lda #$20
    ldx #$00
loop:
    sta SCREENMEM, x
    sta SCREENMEM + $00fa, x
    sta SCREENMEM + $01f4, x
    sta SCREENMEM + $02ee, x
    inx
    cpx #$fa
    bne loop
    rts 
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the color memory (fills it with the specified color)
 *
 * Parameters:   Accu: Color
 *
 * ---------------------------------------------------------------- */ 

screenClearColor:
{
    ldx #$00
loop:
    sta COLORMEM, x
    sta COLORMEM + $00fa, x
    sta COLORMEM + $01f4, x
    sta COLORMEM + $02ee, x
    inx
    cpx #$fa
    bne loop
    rts 
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the screen-memory address of the specified position
 * and writes the specified PETSCII character to this address
 *
 * Parameters:   left:  X-position of first character
 *               right: Y-position of the first character
 *               char : PETSCII character
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutChar(left, top, char) {
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    lda #char
    sta memoryAddress
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the color-memory address of the specified position
 * and writes the specified color to this address
 *
 * Parameters:   left:   X-position of first character
 *               right:  Y-position of the first character
 *               color:  color value 
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutColor(left, top, color) {
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    lda #color
    sta colorMemoryAddress
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the screen-memory and color-memory addresses of the
 * specified position and writes the specified PETSCII character and color
 * to this addresses
 *
 * Parameters:  left:  X-position of first character
 *              right: Y-position of the first character
 *              char:  PETSCII character
 *              color: color of character 
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutCharColor(left, top, char, color) {
    screenPutChar(left, top, char)
    screenPutColor(left, top, color)
}



/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the color-memory address of the specified position
 * and writes the specified color for the specified length
 *
 * Parameters:   left:   X-position of first character
 *               right:  Y-position of the first character
 *               length: Number of bytes to color
 *               color:  color value 
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutColorLength(left, top, length, color) {
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    loadPointerToZPR(colorMemoryAddress, ZPR_1)
    lda #color
    ldy #$00
loop:
    sta (ZPR_1), y
    iny
    cpy #length
    bne loop
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Writes the specified color for the specified length into the 
 * color memory starting at the specified address
 *
 * Parameters:   ZPR_3: Color memory start address
 *               X-register: length
 *               Accu: color value
 * 
 * ---------------------------------------------------------------- */ 

screenPutColorLengthAddress:
{
    ldy #$00
loop:
    sta (ZPR_3), y
    iny
    dex
    bne loop

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * starting at the specified 16-bit address
 *
 * Parameters:   ZPR_1_LO: Low byte of 16 bit address of string
 *               ZPR_1_HI: High byte of 16 bit address of string
 *               ZPR_2_LO: Low byte of screen memory start address
 *               ZPR_2_HI: High byte of screen memory start address
 * 
 * ---------------------------------------------------------------- */ 

screenPutStringAddress:
{
    ldy #$00
    
loop:
    lda (ZPR_1), y
    beq exit
    sta (ZPR_2), y
    iny
    jmp loop

exit:
    rts
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the screen-memory address of the specified position
 * and calls the subroutine "screenPutStringAddress"
 *
 * Parameters:   left: X-position of first character
 *               right: Y-position of the first character
 *               string: Adress of the null-terminated string
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutString(left, top, string) {
    loadPointerToZPR(string, ZPR_1)
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    loadPointerToZPR(memoryAddress, ZPR_2)
    jsr screenPutStringAddress
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * at a specified position (X, Y). It calculates the start address itself
 *
 * Parameters:   ZPR_1_LO: Low byte of 16 bit address of string
 *               ZPR_1_HI: High byte of 16 bit address of string
 *               ZPR_2_LO: X position on screen
 *               ZPR_2_HI: Y position on screen
 * 
 * ---------------------------------------------------------------- */ 

screenPutStringXY:
{
    // calculate offset (Y * 40 + X)
    lda ZPR_2_HI
    ldx #$28
    jsr mathMultiply
    stx screenOffsetLo
    sta screenOffsetHi
    clc
    lda screenOffsetLo
    adc ZPR_2_LO
    sta screenOffsetLo
    lda screenOffsetHi
    adc #$00
    sta screenOffsetHi

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc screenOffsetLo
    sta ZPR_2_LO
    lda #>SCREENMEM
    adc screenOffsetHi
    sta ZPR_2_HI

    // Copy the string until the null byte is loaded
    ldy #$00
    
loop:
    lda (ZPR_1), y
    beq exit
    sta (ZPR_2), y
    iny
    jmp loop

exit:
    rts

    // local variables
    screenOffsetLo: .byte($00)
    screenOffsetHi: .byte($00)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * starting at the specified 16-bit address with a specified foreground color
 *
 * Parameters:   ZPR_1_LO: Low byte of 16 bit address of string
 *               ZPR_1_HI: High byte of 16 bit address of string
 *               ZPR_2_LO: Low byte of screen memory start address
 *               ZPR_2_HI: high byte of screen memory start address
 *               ZPR_3_LO: Low byte of color memory start address
 *               ZPR_3_HI: high byte of color memory start address
 *               ZPR_0:    Text color
 * 
 * ---------------------------------------------------------------- */ 

screenPutStringAddressColor:
{
    ldy #$00
    
loop:
    lda (ZPR_1), y
    beq exit
    sta (ZPR_2), y
    lda ZPR_0
    sta (ZPR_3), y
    iny
    jmp loop

exit:
    rts
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the screen-memory address and the color-memory address
 * of the specified position and calls the subroutine
 * "screenPutStringAddressColor"
 *
 * Parameters:   left:   X-position of first character
 *               right:  Y-position of the first character
 *               string: Adress of the null-terminated string
 *               color:  color of string
 * 
 * ---------------------------------------------------------------- */ 

.macro screenPutStringColor(left, top, string, color) {
    loadPointerToZPR(string, ZPR_1)
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    loadPointerToZPR(memoryAddress, ZPR_2)    
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    loadPointerToZPR(colorMemoryAddress, ZPR_3)
    lda #color
    sta ZPR_0
    jsr screenPutStringAddressColor
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * at a specified position (X, Y) with a specified foreground color.
 * It calculates the start addresses of screen- and color memory itself.
 *
 * Parameters:   ZPR_1_LO: Low byte of 16 bit address of string
 *               ZPR_1_HI: High byte of 16 bit address of string
 *               ZPR_2_LO: X position on screen
 *               ZPR_2_HI: Y position on screen
 *               ZPR_0:    Text color
 * 
 * ---------------------------------------------------------------- */ 

screenPutStringXYColor:
{
    // calculate offset (Y * 40 + X)
    lda ZPR_2_HI
    ldx #$28
    jsr mathMultiply
    stx ZPR_3_LO
    sta ZPR_4_HI
    clc
    lda ZPR_3_LO
    adc ZPR_2_LO
    sta ZPR_3_LO
    lda ZPR_4_HI
    adc #$00
    sta ZPR_4_HI

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc ZPR_3_LO
    sta ZPR_2_LO
    lda #>SCREENMEM
    adc ZPR_4_HI
    sta ZPR_2_HI

    // Add start of color memory to offset
    clc
    lda #<COLORMEM
    adc ZPR_3_LO
    sta ZPR_4_LO
    lda #>COLORMEM
    adc ZPR_4_HI
    sta ZPR_4_HI

    // Copy the string and set the color until the null byte is loaded
    ldy #$00
    
loop:
    lda (ZPR_1), y
    beq exit
    sta (ZPR_2), y
    lda ZPR_0
    sta (ZPR_4), y
    iny
    jmp loop

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws a rectangle with PETSCII characters from (X, Y)
 * with the specified (inner) width and height in the specified color
 *
 * Parameters:   ZPR_1_LO: Low byte of screen-memory address of upper left corner
 *               ZPR_1_HI: High byte of screen-memory address of upper left corner
 *               ZPR_2_LO: inner width
 *               ZPR_2_HI: inner height
 *               ZPR_3_LO: Low byte of color-memory address of upper left corner
 *               ZPR_3_HI: High byte of color-memory address of upper left corner
 *               ZPR_0:    color
 * 
 * ---------------------------------------------------------------- */ 

screenDrawRectangleAddressColor:
{
    // local variables
    .label offsetY         = ZPR_4
    .label innerWidthPlus1 = ZPR_5

    // Calculate inner width + 1
    lda ZPR_2_LO
    sta innerWidthPlus1
    inc innerWidthPlus1

    // Calculate the offset to add each line to get to
    // the beginning of the next starting position
    lda #$28
    sec
    sbc innerWidthPlus1
    sta offsetY

    // Draw upper left corner
    lda #$4f
    ldy #$00
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y
    iny

    // Draw upper verticval line (inner width)
    ldx ZPR_2_LO

xLoop1:
    lda #$77
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y
    iny
    dex
    bne xLoop1

    // Draw upper right corner
    lda #$50
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y

    // Go to beginning of next line (screen memory)
    clc
    lda ZPR_1_LO
    adc #$28
    sta ZPR_1_LO
    lda ZPR_1_HI
    adc #$00
    sta ZPR_1_HI

    // Go to beginning of next line (color memory)
    clc
    lda ZPR_3_LO
    adc #$28
    sta ZPR_3_LO
    lda ZPR_3_HI
    adc #$00
    sta ZPR_3_HI

    // Draw vertical lines (left and right)
    ldx ZPR_2_HI
    ldy #$00

yLoop:
    // Draw left line part
    lda #$74
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y

    // Go to last character in the current line of the rectangle
    clc
    lda ZPR_1_LO
    adc innerWidthPlus1
    sta ZPR_1_LO
    lda ZPR_1_HI
    adc #$00
    sta ZPR_1_HI

    // Go to last color-byte in the current line of the rectangle
    clc
    lda ZPR_3_LO
    adc innerWidthPlus1
    sta ZPR_3_LO
    lda ZPR_3_HI
    adc #$00
    sta ZPR_3_HI

    // Draw right line part
    lda #$6a
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y


    // Go to beginning of next line (screen memory)
    clc
    lda ZPR_1_LO
    adc offsetY
    sta ZPR_1_LO
    lda ZPR_1_HI
    adc #$00
    sta ZPR_1_HI

    // Go to beginning of next line (color memory)
    clc
    lda ZPR_3_LO
    adc offsetY
    sta ZPR_3_LO
    lda ZPR_3_HI
    adc #$00
    sta ZPR_3_HI

    // Loop until all vertical lines are drawn
    dex
    bne yLoop

    // Draw lower left corner
    lda #$4c
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y
    iny

    // Draw lower vertical line (inner width)
    ldx ZPR_2_LO

xLoop2:
    lda #$6f
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y
    iny
    dex
    bne xLoop2

    // Draw lower right corner
    lda #$7a
    sta (ZPR_1), y
    lda ZPR_0
    sta (ZPR_3), y

    // Finally...
    rts
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pre-calculates the screen-memory address and the color-memory address
 * of the specified uppert left corner and calls the subroutine
 * "screenDrawRectangleAddress"
 *
 * Parameters:   left:   X-position of first character
 *               right:  Y-position of the first character
 *               string: Adress of the null-terminated string
 *               color:  color of string
 * 
 * ---------------------------------------------------------------- */ 

.macro screenDrawRectangleColor(left, top, innerWidth, innerHeight, color) {
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    loadPointerToZPR(memoryAddress, ZPR_1)
    lda #innerWidth
    sta ZPR_2_LO
    lda #innerHeight
    sta ZPR_2_HI
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    loadPointerToZPR(colorMemoryAddress, ZPR_3)
    lda #color
    sta ZPR_0
    jsr screenDrawRectangleAddressColor    
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws a rectangle with PETSCII characters from (X, Y)
 * with the specified (inner) width and height in the specified color
 *
 * Parameters:   ZPR_1_LO: X position of upper left corner
 *               ZPR_1_HI: Y position of upper left corner
 *               ZPR_2_LO: inner width
 *               ZPR_2_HI: inner height
 *               ZPR_0:    Color
 * 
 * ---------------------------------------------------------------- */ 

screenDrawRectangleXYColor:
{
    // local variables
    .label screenOffsetLo  = ZPR_4_LO
    .label screenOffsetHi  = ZPR_4_HI

    // calculate offset (Y * 40 + X)
    lda ZPR_1_HI
    ldx #$28
    jsr mathMultiply
    stx screenOffsetLo
    sta screenOffsetHi
    clc
    lda screenOffsetLo
    adc ZPR_1_LO
    sta screenOffsetLo
    lda screenOffsetHi
    adc #$00
    sta screenOffsetHi

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc screenOffsetLo
    sta ZPR_1_LO
    lda #>SCREENMEM
    adc screenOffsetHi
    sta ZPR_1_HI

    // Add start of color memory to offset
    clc
    lda #<COLORMEM
    adc screenOffsetLo
    sta ZPR_3_LO
    lda #>COLORMEM
    adc screenOffsetHi
    sta ZPR_3_HI

    // Call the subroutine
    jsr screenDrawRectangleAddressColor

    rts
}
