#importonce

userinterfaceDrawMain:
{
	jsr screenClear
	
	lda modulesNum
	sta moduleLoopCounter
	loadPointerToZPR(modules, ZPR_6)

modulesLoop:

	// Load address of module struct in to ZPR_7
	ldy moduleIndex
	lda (ZPR_6), y
	sta ZPR_7_LO
	iny 
	lda (ZPR_6), y
	sta ZPR_7_HI

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

	// Goto next module
	inc moduleIndex
	inc moduleIndex

	// Loop counter
	dec moduleLoopCounter
	bne modulesLoop

	rts

	// Local variables
	moduleIndex:       .byte($00)
	moduleLoopCounter: .byte($00)
}