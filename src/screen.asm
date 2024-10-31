#importonce

/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y) and returns it
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Offset
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateOffset(left, top) {
    .return top * 40 + left
}


/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y),
 * and adds this to the address of the screen memory
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Absolute address of the character byte at position (x, y)
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateMemoryAddress(left, top) {
    .return screenCalculateOffset(left, top) + SCREENMEM
}


/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y),
 * and adds this to the address of the color memory
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Absolute address of the color-byte at position (x, y)
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateColorMemoryAddress(left, top) {
    .return screenCalculateOffset(left, top) + COLORMEM
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the screen memory (fills the sceen memory with the space character)
 *
 * Parameters:   None
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
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
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
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
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * starting at the specified 16-bit address
 *
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of 16 bit address of string
 *               ZEROPAGE.TEMP_1_HI: High byte of 16 bit address of string
 *               ZEROPAGE.TEMP_2_LO: Low byte of screen memory start address
 *               ZEROPAGE.TEMP_2_HI: High byte of screen memory start address
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenPutStringAddress:
{
    ldy #$00
    
loop:
    lda (ZEROPAGE.TEMP_1), y
    beq exit
    sta (ZEROPAGE.TEMP_2), y
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
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

.macro screenPutString(left, top, string) {
    lda #<string
    sta ZEROPAGE.TEMP_1_LO
    lda #>string
    sta ZEROPAGE.TEMP_1_HI
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    lda #<memoryAddress
    sta ZEROPAGE.TEMP_2_LO
    lda #>memoryAddress
    sta ZEROPAGE.TEMP_2_HI
    jsr screenPutStringAddress
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Puts a null terminated string into screen memory
 * at a specified position (X, Y). It calculates the start address itself
 *
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of 16 bit address of string
 *               ZEROPAGE.TEMP_1_HI: High byte of 16 bit address of string
 *               ZEROPAGE.TEMP_2_LO: X position on screen
 *               ZEROPAGE.TEMP_2_HI: Y position on screen
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenPutStringXY:
{
    // calculate offset (Y * 40 + X)
    lda ZEROPAGE.TEMP_2_HI
    ldx #$28
    jsr mathMultiply
    stx screenOffsetLo
    sta screenOffsetHi
    clc
    lda screenOffsetLo
    adc ZEROPAGE.TEMP_2_LO
    sta screenOffsetLo
    lda screenOffsetHi
    adc #$00
    sta screenOffsetHi

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc screenOffsetLo
    sta ZEROPAGE.TEMP_2_LO
    lda #>SCREENMEM
    adc screenOffsetHi
    sta ZEROPAGE.TEMP_2_HI

    // Copy the string until the null byte is loaded
    ldy #$00
    
loop:
    lda (ZEROPAGE.TEMP_1), y
    beq exit
    sta (ZEROPAGE.TEMP_2), y
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
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of 16 bit address of string
 *               ZEROPAGE.TEMP_1_HI: High byte of 16 bit address of string
 *               ZEROPAGE.TEMP_2_LO: Low byte of screen memory start address
 *               ZEROPAGE.TEMP_2_HI: high byte of screen memory start address
 *               ZEROPAGE.TEMP_3_LO: Low byte of color memory start address
 *               ZEROPAGE.TEMP_3_HI: high byte of color memory start address
 *               ZEROPAGE.TEMP_0:    Text color
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenPutStringAddressColor:
{
    ldy #$00
    
loop:
    lda (ZEROPAGE.TEMP_1), y
    beq exit
    sta (ZEROPAGE.TEMP_2), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y
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
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

.macro screenPutStringColor(left, top, string, color) {
    lda #<string
    sta ZEROPAGE.TEMP_1_LO
    lda #>string
    sta ZEROPAGE.TEMP_1_HI
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    lda #<memoryAddress
    sta ZEROPAGE.TEMP_2_LO
    lda #>memoryAddress
    sta ZEROPAGE.TEMP_2_HI
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    lda #<colorMemoryAddress
    sta ZEROPAGE.TEMP_3_LO
    lda #>colorMemoryAddress
    sta ZEROPAGE.TEMP_3_HI
    lda #color
    sta ZEROPAGE.TEMP_0
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
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of 16 bit address of string
 *               ZEROPAGE.TEMP_1_HI: High byte of 16 bit address of string
 *               ZEROPAGE.TEMP_2_LO: X position on screen
 *               ZEROPAGE.TEMP_2_HI: Y position on screen
 *               ZEROPAGE.TEMP_0:    Text color
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenPutStringXYColor:
{
    // calculate offset (Y * 40 + X)
    lda ZEROPAGE.TEMP_2_HI
    ldx #$28
    jsr mathMultiply
    stx ZEROPAGE.TEMP_3_LO
    sta ZEROPAGE.TEMP_4_HI
    clc
    lda ZEROPAGE.TEMP_3_LO
    adc ZEROPAGE.TEMP_2_LO
    sta ZEROPAGE.TEMP_3_LO
    lda ZEROPAGE.TEMP_4_HI
    adc #$00
    sta ZEROPAGE.TEMP_4_HI

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc ZEROPAGE.TEMP_3_LO
    sta ZEROPAGE.TEMP_2_LO
    lda #>SCREENMEM
    adc ZEROPAGE.TEMP_4_HI
    sta ZEROPAGE.TEMP_2_HI

    // Add start of color memory to offset
    clc
    lda #<COLORMEM
    adc ZEROPAGE.TEMP_3_LO
    sta ZEROPAGE.TEMP_4_LO
    lda #>COLORMEM
    adc ZEROPAGE.TEMP_4_HI
    sta ZEROPAGE.TEMP_4_HI

    // Copy the string and set the color until the null byte is loaded
    ldy #$00
    
loop:
    lda (ZEROPAGE.TEMP_1), y
    beq exit
    sta (ZEROPAGE.TEMP_2), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_4), y
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
 * Parameters:   ZEROPAGE.TEMP_1_LO: Low byte of screen-memory address of upper left corner
 *               ZEROPAGE.TEMP_1_HI: High byte of screen-memory address of upper left corner
 *               ZEROPAGE.TEMP_2_LO: inner width
 *               ZEROPAGE.TEMP_2_HI: inner height
 *               ZEROPAGE.TEMP_3_LO: Low byte of color-memory address of upper left corner
 *               ZEROPAGE.TEMP_3_HI: High byte of color-memory address of upper left corner
 *               ZEROPAGE.TEMP_0:    color
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenDrawRectangleAddressColor:
{
    // local variables
    .label offsetY         = ZEROPAGE.TEMP_5
    .label innerWidthPlus1 = ZEROPAGE.TEMP_6

    // Calculate inner width + 1
    lda ZEROPAGE.TEMP_2_LO
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
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y
    iny

    // Draw upper verticval line (inner width)
    ldx ZEROPAGE.TEMP_2_LO

xLoop1:
    lda #$77
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y
    iny
    dex
    bne xLoop1

    // Draw upper right corner
    lda #$50
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y

    // Go to beginning of next line (screen memory)
    clc
    lda ZEROPAGE.TEMP_1_LO
    adc #$28
    sta ZEROPAGE.TEMP_1_LO
    lda ZEROPAGE.TEMP_1_HI
    adc #$00
    sta ZEROPAGE.TEMP_1_HI

    // Go to beginning of next line (color memory)
    clc
    lda ZEROPAGE.TEMP_3_LO
    adc #$28
    sta ZEROPAGE.TEMP_3_LO
    lda ZEROPAGE.TEMP_3_HI
    adc #$00
    sta ZEROPAGE.TEMP_3_HI

    // Draw vertical lines (left and right)
    ldx ZEROPAGE.TEMP_2_HI
    ldy #$00

yLoop:
    // Draw left line part
    lda #$74
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y

    // Go to last character in the current line of the rectangle
    clc
    lda ZEROPAGE.TEMP_1_LO
    adc innerWidthPlus1
    sta ZEROPAGE.TEMP_1_LO
    lda ZEROPAGE.TEMP_1_HI
    adc #$00
    sta ZEROPAGE.TEMP_1_HI

    // Go to last color-byte in the current line of the rectangle
    clc
    lda ZEROPAGE.TEMP_3_LO
    adc innerWidthPlus1
    sta ZEROPAGE.TEMP_3_LO
    lda ZEROPAGE.TEMP_3_HI
    adc #$00
    sta ZEROPAGE.TEMP_3_HI

    // Draw right line part
    lda #$6a
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y


    // Go to beginning of next line (screen memory)
    clc
    lda ZEROPAGE.TEMP_1_LO
    adc offsetY
    sta ZEROPAGE.TEMP_1_LO
    lda ZEROPAGE.TEMP_1_HI
    adc #$00
    sta ZEROPAGE.TEMP_1_HI

    // Go to beginning of next line (color memory)
    clc
    lda ZEROPAGE.TEMP_3_LO
    adc offsetY
    sta ZEROPAGE.TEMP_3_LO
    lda ZEROPAGE.TEMP_3_HI
    adc #$00
    sta ZEROPAGE.TEMP_3_HI

    // Loop until all vertical lines are drawn
    dex
    bne yLoop

    // Draw lower left corner
    lda #$4c
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y
    iny

    // Draw lower vertical line (inner width)
    ldx ZEROPAGE.TEMP_2_LO

xLoop2:
    lda #$6f
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y
    iny
    dex
    bne xLoop2

    // Draw lower right corner
    lda #$7a
    sta (ZEROPAGE.TEMP_1), y
    lda ZEROPAGE.TEMP_0
    sta (ZEROPAGE.TEMP_3), y

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
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

.macro screenDrawRectangleColor(left, top, innerWidth, innerHeight, color) {
    .var memoryAddress = screenCalculateMemoryAddress(left, top)
    lda #<memoryAddress
    sta ZEROPAGE.TEMP_1_LO
    lda #>memoryAddress
    sta ZEROPAGE.TEMP_1_HI
    lda #innerWidth
    sta ZEROPAGE.TEMP_2_LO
    lda #innerHeight
    sta ZEROPAGE.TEMP_2_HI
    .var colorMemoryAddress = screenCalculateColorMemoryAddress(left, top)
    lda #<colorMemoryAddress
    sta ZEROPAGE.TEMP_3_LO
    lda #>colorMemoryAddress
    sta ZEROPAGE.TEMP_3_HI
    lda #color
    sta ZEROPAGE.TEMP_0
    jsr screenDrawRectangleAddressColor    
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws a rectangle with PETSCII characters from (X, Y)
 * with the specified (inner) width and height in the specified color
 *
 * Parameters:   ZEROPAGE.TEMP_1_LO: X position of upper left corner
 *               ZEROPAGE.TEMP_1_HI: Y position of upper left corner
 *               ZEROPAGE.TEMP_2_LO: inner width
 *               ZEROPAGE.TEMP_2_HI: inner height
 *               ZEROPAGE.TEMP_0:    Color
 * 
 * Return value: None
 *
 * Reads global variables:  None
 * Writes global variables: None
 *
 * ---------------------------------------------------------------- */ 

screenDrawRectangleXYColor:
{
    // local variables
    .label screenOffsetLo  = ZEROPAGE.TEMP_4_LO
    .label screenOffsetHi  = ZEROPAGE.TEMP_4_HI

    // calculate offset (Y * 40 + X)
    lda ZEROPAGE.TEMP_1_HI
    ldx #$28
    jsr mathMultiply
    stx screenOffsetLo
    sta screenOffsetHi
    clc
    lda screenOffsetLo
    adc ZEROPAGE.TEMP_1_LO
    sta screenOffsetLo
    lda screenOffsetHi
    adc #$00
    sta screenOffsetHi

    // Add start of screen memory to offset
    clc
    lda #<SCREENMEM
    adc screenOffsetLo
    sta ZEROPAGE.TEMP_1_LO
    lda #>SCREENMEM
    adc screenOffsetHi
    sta ZEROPAGE.TEMP_1_HI

    // Add start of color memory to offset
    clc
    lda #<COLORMEM
    adc screenOffsetLo
    sta ZEROPAGE.TEMP_3_LO
    lda #>COLORMEM
    adc screenOffsetHi
    sta ZEROPAGE.TEMP_3_HI

    // Call the subroutine
    jsr screenDrawRectangleAddressColor

    rts
}
