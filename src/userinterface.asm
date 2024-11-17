#importonce

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