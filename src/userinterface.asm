#importonce

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the screen with the right colors
 * and sets the VIC background color
 *
 * Parameters: None
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceInitScreen:
{
    lda #CYAN
    sta VIC.BORDERCOLOR
    lda #DARK_GRAY
    sta VIC.BACKGROUND_COLOR_0
	jsr screenClear
    lda #GRAY
    jsr screenClearColor
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the complete user interface
 *
 * Parameters: None
 *
 * Reads global variables:  modulesNum, modules, currentKeyboardPianoOctave,
 *                          currentNoteOfOctave, noteNames
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceDrawMain:
{
	screenPutString(9, 0, strMenu)
	screenPutString(18, 0, strOctave)
	screenPutString(33, 0, strMonosid)
    jsr userInterfaceOutputCurrentKeyboardPianoOctave

	lda modulesNum
	sta moduleLoopCounter
	loadPointerToZPR(modules, ZPR_6)

	lda #0
	sta moduleIndex

modulesLoop:

	// Load address of module struct in to ZPR_7
	ldy moduleIndex
	lda (ZPR_6), y
	sta ZPR_7_LO
	iny 
	lda (ZPR_6), y
	sta ZPR_7_HI

    // Save ZPR_6 on stack, because the subroutine may change it
    lda ZPR_6_LO
    pha
    lda ZPR_6_HI
    pha

	// Draw the module and inputs in it
	jsr userInterfaceDrawModule

    // Restore ZPR_6 from stack
    pla
    sta ZPR_6_HI
    pla
    sta ZPR_6_LO

	// Goto next module
	inc moduleIndex
	inc moduleIndex

	// Loop counter
	dec moduleLoopCounter
	bne modulesLoop

	rts

	// "Local" variables (not really local, they of course keep the last value between calls to the subroutine)
	moduleIndex:       .byte($00)
	moduleLoopCounter: .byte($00)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the current piano octave in the first line of the screen
 *
 * Parameters: None
 *
 * Reads global variables: currentKeyboardPianoOctave
 *               
 * ---------------------------------------------------------------- */ 

userInterfaceOutputCurrentKeyboardPianoOctave:
{
    lda currentKeyboardPianoOctave
    clc
    adc #$30
    sta SCREENMEM+22
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws an module (complete with border, name and all input fields)
 *
 * Parameters: ZPR_7: Address of the module struct
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawModule:
{
	// check if module should be displayed on current page
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.PAGE)
	cmp currentPage
	beq drawModule
	rts

drawModule:
	// Load color of module	and store it in ZPR_0
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.COLOR)
	sta ZPR_0

	// Print name of module in the module's color at the pre-calculated position
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME, ZPR_1)
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME_SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME_COLOR_MEMORY, ZPR_3)
	jsr screenPutStringAddressColor

	// Output the rectangle border of the module in the module's color at the pre-calculated position
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.RECT_SCREEN_MEMORY, ZPR_1)
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INNER_WIDTH)
	sta ZPR_2_LO
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INNER_HEIGHT)
	sta ZPR_2_HI
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.RECT_COLOR_MEMORY, ZPR_3)
	jsr screenDrawRectangleAddressColor

	// Load the number of inputs and iterate over the input array,
	// calling the subroutine "userInterfaceDrawInput" for each input
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INPUT_ARRAY_NUM)
	sta inputLoopCounter
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.INPUT_ARRAY, ZPR_6)

	lda #0
	sta inputIndex

inputsLoop:

	// Load address of input struct in to ZPR_7
	ldy inputIndex
	lda (ZPR_6), y
	sta ZPR_7_LO
	iny 
	lda (ZPR_6), y
	sta ZPR_7_HI

    // Save ZPR_6 on stack, because the subroutine may change it
    lda ZPR_6_LO
    pha
    lda ZPR_6_HI
    pha

	// Draw the input field
	jsr userInterfaceDrawInput

    // Restore ZPR_6 from stack
    pla
    sta ZPR_6_HI
    pla
    sta ZPR_6_LO

	// Goto next input
	inc inputIndex
	inc inputIndex

	// Loop counter
	dec inputLoopCounter
	bne inputsLoop

exit:
	rts

	// "Local" variables (not really local, they of course keep the last value between calls to the subroutine)
	inputIndex:       .byte($00)
	inputLoopCounter: .byte($00)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws an input element (complete with name and current value)
 *
 * Parameters: ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawInput:
{
	// Print label of the input at the pre-calculated position
	lda #LIGHT_GRAY
	sta ZPR_0
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL, ZPR_1)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_COLOR_MEMORY, ZPR_3)
	jsr screenPutStringAddressColor

	// Load screen memory addresses for the input element itself (one line further down)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.COLOR_MEMORY, ZPR_3)

	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.WAVEFORM
	beq typeWaveform
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	cmp #INPUT_TYPE.BOOLEAN
	beq typeBoolean
	rts

typeWaveform:
	lda #WHITE
	jsr userInterfaceColorizeInputField
	jsr userInterfaceDrawInputTopLine
	jsr userInterfaceDrawInputLeftRight
	jsr userInterfacePrintWaveform
	rts

typeInteger4Bits:
	lda #WHITE
	jsr userInterfaceColorizeInputField
	jsr userInterfaceDrawInputTopLine
	jsr userInterfaceDrawInputPlusMinus
	jsr userInterfacePrint4BitInteger
	rts

typeInteger11Bits:
	lda #WHITE
	jsr userInterfaceColorizeInputField
	jsr userInterfaceDrawInputTopLine
	jsr userInterfaceDrawInputPlusMinus
	jsr userInterfacePrint12BitInteger
	rts

typeInteger12Bits:
	lda #WHITE
	jsr userInterfaceColorizeInputField
	jsr userInterfaceDrawInputTopLine
	jsr userInterfaceDrawInputPlusMinus
	jsr userInterfacePrint12BitInteger
	rts

typeBoolean:
	jsr userinterfaceDrawBoolean
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Changes the color of the input field
 *
 * Parameters: ZPR_3: Offset of left top corner into color memory
 *             ZPR_7: Address of the input struct
 *			   Accu: color value
 *
 * ---------------------------------------------------------------- */ 

userInterfaceColorizeInputField:
{
	// save color from accu
	sta color

	// colorize first line
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	sta loopCounter
	ldy #$00
	lda color
loop1:
	sta (ZPR_3), y
	iny
	dec loopCounter
	bne loop1

	// colorize second line
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	sta loopCounter
	ldy #$28
	lda color
loop2:
	sta (ZPR_3), y
	iny
	dec loopCounter
	bne loop2

	rts

	// "Local" variables (not really local, they of course keep the last value between calls to the subroutine)
	color: .byte($00)
	loopCounter: .byte($00)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the top line of an input field
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawInputTopLine:
{
	// Load width of the input element
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	sta loopCounter

	// Draw line
	ldy #$00
charLoop:
	lda #$6F
	sta (ZPR_2), y
	iny
	dec loopCounter
	bne charLoop

	rts
	
	// "Local" variables (not really local, they of course keep the last value between calls to the subroutine)
	loopCounter: .byte($00)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the "<" and ">" of the waveform input field
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawInputLeftRight:
{
	// Draw "<" at the left (load Y with 40 to go to the next line)
	ldy #$028
	lda #$BC
	sta (ZPR_2), y

	// Draw ">" at the right (load Y with width, add 38 to land at the correct position)
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	adc #$026
	tay
	lda #$BE
	sta (ZPR_2), y

	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the "-" and "+" of the integer input fields
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawInputPlusMinus:
{
	// Draw "-" at the left (load Y with 40 to go to the next line)
	ldy #$028
	lda #$AD
	sta (ZPR_2), y

	// Draw "+" at the right (load Y with width, add 38 to land at the correct position)
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	adc #$026
	tay
	lda #$AB
	sta (ZPR_2), y

	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Outputs the name of the current waveform of the specified intput field
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfacePrintWaveform:
{
	addByteValueToZPRAddress(ZPR_2, $29)

	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
	cmp #WAVEFORM.TRIANGULAR
	beq waveformTriangular
	cmp #WAVEFORM.SAWTOOTH
	beq waveformSawtooth
	cmp #WAVEFORM.SQUARE
	beq waveformSquare
	cmp #WAVEFORM.NOISE
	beq waveformNoise
	rts

waveformTriangular:
	loadPointerToZPR(strWaveformTriangular, ZPR_1)
	jmp output
	
waveformSawtooth:
	loadPointerToZPR(strWaveformSawtooth, ZPR_1)
	jmp output
	
waveformSquare:
	loadPointerToZPR(strWaveformSquare, ZPR_1)
	jmp output
	
waveformNoise:
	loadPointerToZPR(strWaveformNoise, ZPR_1)
	
output:
	jsr screenPutStringAddress
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Outputs the 4 bit integer value of the input field
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfacePrint4BitInteger:
{
	loadPointerToZPR(charLookUpTable, ZPR_1)

	// Print first char
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
	asl
	tay
	lda (ZPR_1), y
	ldy #$29
	sta (ZPR_2), y

	// Print second char
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
	asl
	tay
	iny
	lda (ZPR_1), y
	ldy #$2A
	sta (ZPR_2), y

	rts

charLookUpTable:
	.byte(160)
	.byte(176)
	.byte(160)
	.byte(177)
	.byte(160)
	.byte(178)
	.byte(160)
	.byte(179)
	.byte(160)
	.byte(180)
	.byte(160)
	.byte(181)
	.byte(160)
	.byte(182)
	.byte(160)
	.byte(183)
	.byte(160)
	.byte(184)
	.byte(160)
	.byte(185)
	.byte(177)
	.byte(176)
	.byte(177)
	.byte(177)
	.byte(177)
	.byte(178)
	.byte(177)
	.byte(179)
	.byte(177)
	.byte(180)
	.byte(177)
	.byte(181)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Outputs the 11/12 bit integer value of the input field
 *
 * Parameters: ZPR_2: Offset of left top corner into screen memory,
 *             ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfacePrint12BitInteger:
{
	// copy ZPR_2 to ZPR_6, because we need ZPR_2 as parameter to the conversion subroutine
	// and this routine uses ZPR_3 through 5 as internal variables
	copyZPR(ZPR_2, ZPR_6)

	// move the address pointer into the screen memory from the top left corner of the input
	// field to the beginning of the actual text (one line down, 1 character to right)
	addByteValueToZPRAddress(ZPR_6, $29)

	// convert the current value of the input to string (inverted characters)
	// and save it in the string buffer
	lda #$B0
	sta ZPR_0	
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.VALUE, ZPR_1)
	loadPointerToZPR(stringBuffer, ZPR_2)
	jsr convertIntegerToString

	// because the text should be printed aligned to the right of input field,
	// calculate the padding with blank characters
	// (the conversion subroutine returned the length of the string in ZPR_0)
	lda #$04
	sec
	sbc ZPR_0
	sta ZPR_1_LO
	beq outputString

	// if the length of the string is shorter than 4 characters, pad it
	tax
	lda #$A0
	ldy #$00

emptyCharloop:
	sta (ZPR_6), y
	iny
	dex
	bne emptyCharloop

	// output the string
outputString:

    // add the width of the padding to the screen offset address,
	// so we can use inderect index addressing for both, the screen memory and the string
	clc
    lda ZPR_6_LO
    adc ZPR_1_LO
    sta ZPR_6_LO
    lda ZPR_6_HI
    adc #$00
    sta ZPR_6_HI

	// load the X-register with the string length and the Y-register with 0
	ldx ZPR_0
	ldy #$00

	// copy the string
stringLoop:
	lda (ZPR_2), y
	sta (ZPR_6), y
	iny
	dex
	bne stringLoop

	rts

stringBuffer:
	.byte(0)
	.byte(0)
	.byte(0)
	.byte(0)
	.byte(0)
	.byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Outputs an boolean input as a colored disk (green if true, gray if false)
 *
 * Parameters:	ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userinterfaceDrawBoolean:
{
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.SCREEN_MEMORY, ZPR_1)
	ldy #0
	lda #$51
	sta (ZPR_1), y
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.COLOR_MEMORY, ZPR_1)
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
	bne booleanInputActive
	lda #GRAY
	jmp booleanOutputColor

booleanInputActive:
	lda #GREEN
	
booleanOutputColor:
	ldy #0
	sta (ZPR_1), y
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Adds the optical focus to the currently selected module
 *
 * Parameters:              none
 *
 * Reads global variables:  modules, currentModuleIndex
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceAddModuleFocus:
{
    lda #1
    sta ZPR_0
    lda currentModuleIndex
    jsr userinterfaceChangeModuleFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Removes the optical focus of the currently selected module
 *
 * Parameters:              none
 *
 * Reads global variables:  modules, currentModuleIndex
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceRemoveModuleFocus:
{
    lda #0
    sta ZPR_0
    lda currentModuleIndex
    jsr userinterfaceChangeModuleFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Changes the optical focus of an module
 *
 * Parameters:              Accu:	  Index of module
 *							ZPR_0:    If > 0 then draw focused,
 *                                    if = 0 then draw not focused
 *
 * Reads global variables:  modules
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceChangeModuleFocus:
{
	// save the parameters in "local" variables
	sta moduleIndex
	lda ZPR_0
	sta drawFocused

	// load the address of the module array into ZPR_6
	loadPointerToZPR(modules, ZPR_6)

	// load the address of the specified module into ZPR_7
	stuctLoadPointerArrayItemToZPR(ZPR_6, moduleIndex, ZPR_7)

	// determine color (either color of module or the focus-color)
	lda drawFocused
	cmp #$00
	bne drawFocusedColor

	// Load color of module	and store it in ZPR_0
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.COLOR)
	sta ZPR_0
	jmp drawModule

drawFocusedColor:
	// store the color code for the focus-color (yellow) in ZPR_0
	lda #YELLOW
	sta ZPR_0

drawModule:
	// Print name of module in the module's color at the pre-calculated position
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME, ZPR_1)
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME_SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.NAME_COLOR_MEMORY, ZPR_3)
	jsr screenPutStringAddressColor

	// Output the rectangle border of the module in the module's color at the pre-calculated position
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.RECT_SCREEN_MEMORY, ZPR_1)
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INNER_WIDTH)
	sta ZPR_2_LO
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.INNER_HEIGHT)
	sta ZPR_2_HI
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.RECT_COLOR_MEMORY, ZPR_3)
	jsr screenDrawRectangleAddressColor

	rts

drawFocused:
	.byte(0)
moduleIndex:
	.byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Adds the optical focus to the currently selected input,
 * in the currently selected module
 *
 * Parameters:              none
 *
 * Reads global variables:  modules, currentModuleIndex, currentInputIndex
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceAddInputFocus:
{
    lda #1
    sta ZPR_0
	lda currentModuleIndex
	sta ZPR_1_LO
    lda currentInputIndex
    jsr userinterfaceChangeInputFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Removes the optical focus of the currently selected input,
 * in the currently selected module
 *
 * Parameters:              none
 *
 * Reads global variables:  modules, currentModuleIndex, currentInputIndex
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceRemoveInputFocus:
{
    lda #0
    sta ZPR_0
	lda currentModuleIndex
	sta ZPR_1_LO
    lda currentInputIndex
    jsr userinterfaceChangeInputFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Changes the optical focus of an module
 *
 * Parameters:              Accu:	  Index of input
 *							ZPR_0:    If > 0 then draw focused,
 *                                    if = 0 then draw not focused
 *							ZPR_1_LO: Index of module
 *
 * Reads global variables:  modules
 *               
 * ---------------------------------------------------------------- */ 

userinterfaceChangeInputFocus:
{
	// save the parameters in "local" variables
	sta inputIndex
	lda ZPR_0
	sta drawFocused
	lda ZPR_1_LO
	sta moduleIndex

	// load the address of the module array into ZPR_6
	loadPointerToZPR(modules, ZPR_6)

	// load the address of the specified module into ZPR_7
	stuctLoadPointerArrayItemToZPR(ZPR_6, moduleIndex, ZPR_7)

	// load the address of the module`s input array into ZPR_6
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.INPUT_ARRAY, ZPR_6)

	// load the address of the specified input into ZPR_7
	stuctLoadPointerArrayItemToZPR(ZPR_6, inputIndex, ZPR_7)

	// load the color memory address of the top left corner of the input element into ZPR_3
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.COLOR_MEMORY, ZPR_3)

	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.WAVEFORM
	beq typeWaveform
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	cmp #INPUT_TYPE.BOOLEAN
	beq typeBoolean
	rts

typeWaveform:
typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
	// determine color (either white or the focus-color)
	lda drawFocused
	cmp #$00
	bne useFocusedColorForTextInput
	lda #WHITE
	sta ZPR_0
	jmp colorizeTextInput

useFocusedColorForTextInput:
	// store the color code for the focus-color (yellow) in ZPR_0
	lda #YELLOW
	sta ZPR_0

colorizeTextInput:
	jsr userInterfaceColorizeInputField
	rts

typeBoolean:
	// determine color (either color of module or the focus-color)
	lda drawFocused
	cmp #$00
	bne useFocusedColorForBooleanInput
	lda #LIGHT_GRAY
	sta ZPR_0
	jmp colorizeBooleanInput

useFocusedColorForBooleanInput:
	// store the color code for the focus-color (yellow) in ZPR_0
	lda #YELLOW
	sta ZPR_0

colorizeBooleanInput:

	// Print label of the input at the pre-calculated position
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL, ZPR_1)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_COLOR_MEMORY, ZPR_3)
	jsr screenPutStringAddressColor
	rts

drawFocused:
	.byte(0)
inputIndex:
	.byte(0)
moduleIndex:
	.byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates an input element (only current value,
 * the label ist not redrawn, no colorization)
 *
 * Parameters: ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceUpdateInput:
{
	// Load screen memory addresses for the input element itself (one line further down)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.COLOR_MEMORY, ZPR_3)

	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.WAVEFORM
	beq typeWaveform
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	cmp #INPUT_TYPE.BOOLEAN
	beq typeBoolean
	rts

typeWaveform:
	jsr userInterfacePrintWaveform
	rts

typeInteger4Bits:
	jsr userInterfacePrint4BitInteger
	rts

typeInteger11Bits:
	jsr userInterfacePrint12BitInteger
	rts

typeInteger12Bits:
	jsr userInterfacePrint12BitInteger
	rts

typeBoolean:
	jsr userinterfaceDrawBoolean
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the input editor for the currently selected integer input field.
 *
 * Parameters: ZPR_7: Address of the input struct 
 *
 * ---------------------------------------------------------------- */ 

userInterfaceDrawInputEditor:
{
	// load width of current input and save it in "inputCharsLeft"
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.WIDTH)
	sta inputCharsLeft

	// Load start of upper left corner of input into ZPR_2
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.SCREEN_MEMORY, ZPR_2)

	// load the color memory address of the top left corner of the input element into ZPR_3
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.COLOR_MEMORY, ZPR_3)
	lda #YELLOW
	jsr userInterfaceColorizeInputField
	
	// Draw ">" at the left (load Y with 40 to go to the next line)
	ldy #$028
	lda #$BE
	sta (ZPR_2), y
	dec inputCharsLeft

	// load the address of the buffer for the current editor text into ZPR_1
	loadPointerToZPR(currentInputEditorText, ZPR_1)

	// The actual text starts one line below, so add 41 to the destination address to land
	// correctly at the actual first position of the editor input.
	// No we can use Y for indirect-indexed addressing both the source and destination during the string copy .
	addByteValueToZPRAddress(ZPR_2, $29)
	ldy #0

editorTextLoop:
    // output the null-terminated string in "currentInputEditorText",
	// adding 128 to change it to the inverted charset
	lda (ZPR_1), y
    beq printBlankChars
	clc
	adc #$80
    sta (ZPR_2), y
    iny
	dec inputCharsLeft
    jmp editorTextLoop

printBlankChars:
	// check if there are blank characters left to draw, exit of not
	lda inputCharsLeft
	beq exit

	// lda inputCharsLeft
	// jsr debugDumpByte

blankCharsLoop:
	// draw the blank characters until the end of the input field is reached
	lda #$A0
	sta (ZPR_2), y
	iny
	dec inputCharsLeft
	bne blankCharsLoop

exit:	
	rts

inputCharsLeft:
	.byte(0)
}
