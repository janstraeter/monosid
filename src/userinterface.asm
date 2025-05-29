#importonce

#import "constants.asm"
#import "zpregisters.asm"
#import "structs.asm"
#import "math.asm"
#import "screen.asm"

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

userinterfaceDrawMain:
{
	screenPutString(9, 0, strMenu)
	screenPutString(18, 0, strOctave)
	screenPutString(24, 0, strNote)
	screenPutString(33, 0, strMonosid)
    jsr userInterfaceOutputCurrentKeyboardPianoOctave
    jsr userinterfaceOutputCurrentNote

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

userinterfaceOutputCurrentNote:
{
	// Check if a note is to be played
	lda currentNoteOfOctave
    cmp #$FF
    beq noNoteToPlay

    // Yes, a note. Multiply the note number with 2 (the size of the
    // note-name array elements) and transfer it to the Y-register
    clc
    asl
    tay

    // Load the address of the note-name array
    lda #<noteNames
    sta ZPR_1_LO
    lda #>noteNames
    sta ZPR_1_HI

    // Output the note name at line 0, char 29
    lda (ZPR_1), y
    sta SCREENMEM+29
    iny
    lda (ZPR_1), y
    sta SCREENMEM+30
    jmp exit

noNoteToPlay:
    
    // No note to play.
    // Output "--" at line 0, char 29
    lda #$2D
    sta SCREENMEM+29
    sta SCREENMEM+30

exit:
    rts
}

userInterfaceOutputCurrentKeyboardPianoOctave:
{
    lda currentKeyboardPianoOctave
    clc
    adc #$30
    sta SCREENMEM+22
    rts
}

userInterfaceDrawModule:
{
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

	rts

	// "Local" variables (not really local, they of course keep the last value between calls to the subroutine)
	inputIndex:       .byte($00)
	inputLoopCounter: .byte($00)
}

userInterfaceDrawInput:
{
	// Print label of the input at the pre-calculated position
	lda #LIGHT_GRAY
	sta ZPR_0
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL, ZPR_1)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_SCREEN_MEMORY, ZPR_2)
	structLoadWordToZPR(ZPR_7, STRUCT_INPUT.LABEL_COLOR_MEMORY, ZPR_3)
	jsr screenPutStringAddressColor

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
	rts

typeInteger4Bits:
	rts

typeInteger11Bits:
	rts

typeInteger12Bits:
	rts

typeBoolean:

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