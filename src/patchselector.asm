#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears th screen and draws the UI of the patch selector
 *
 * ---------------------------------------------------------------- */ 

patchSelectorDrawMain:
{
	// clear screen
    jsr screenClear
    lda #GRAY
    jsr screenClearColor

    jsr screenSwitchToUpperCase

    // draw selector border
    screenDrawRectangleColor(0, 1, 38, 22, YELLOW)

    // draw headline
    screenPutStringColor(1, 0, strPatchSelectorHeadline, YELLOW)

    // --------------------------------------
    // draw the 3 columns with patch indecies and names
    // --------------------------------------

    // start at patch 0
    lda #0
    sta patchIndex

    // draw 1. column       
    lda #22
    sta rowCount
    patchSelectorLoadColumn1MemoryAddresses()
    patchSelectorDrawColumn(patchIndex, rowCount)

    // draw 2. column
    lda #22
    sta rowCount
    patchSelectorLoadColumn2MemoryAddresses()
    patchSelectorDrawColumn(patchIndex, rowCount)

    // draw 3. column
    lda #20
    sta rowCount
    patchSelectorLoadColumn3MemoryAddresses()
    patchSelectorDrawColumn(patchIndex, rowCount)

    rts

rowCount:
    .byte(0)
patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Calculates the screen and color memory addresses for the 1. column
 *
 * Return values:  ZPR_1 - screen address of top left corner of column
 *                 ZPR_3 - color address of top left corner of column
 * 
 * ---------------------------------------------------------------- */ 

.macro patchSelectorLoadColumn1MemoryAddresses()
{
    .var column1Address = screenCalculateMemoryAddress(1, 2)
    loadPointerToZPR(column1Address, ZPR_1)
    
    .var column1ColorAddress = screenCalculateColorMemoryAddress(1, 2)
    loadPointerToZPR(column1ColorAddress, ZPR_3)
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Calculates the screen and color memory addresses for the 2. column
 *
 * Return values:  ZPR_1 - screen address of top left corner of column
 *                 ZPR_3 - color address of top left corner of column
 * 
 * ---------------------------------------------------------------- */ 

.macro patchSelectorLoadColumn2MemoryAddresses()
{
    .var column2Address = screenCalculateMemoryAddress(14, 2)
    loadPointerToZPR(column2Address, ZPR_1)
    
    .var column2ColorAddress = screenCalculateColorMemoryAddress(14, 2)
    loadPointerToZPR(column2ColorAddress, ZPR_3)
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Calculates the screen and color memory addresses for the 3. column
 *
 * Return values:  ZPR_1 - screen address of top left corner of column
 *                 ZPR_3 - color address of top left corner of column
 * 
 * ---------------------------------------------------------------- */ 

.macro patchSelectorLoadColumn3MemoryAddresses()
{
    .var column3Address = screenCalculateMemoryAddress(27, 2)
    loadPointerToZPR(column3Address, ZPR_1)
    
    .var column3ColorAddress = screenCalculateColorMemoryAddress(27, 2)
    loadPointerToZPR(column3ColorAddress, ZPR_3)
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Draws a patch selector column
 *
 * Parameters:   ZPR_1:      address into screen memory (top left corner of column)
 *               ZPR_3:      address into color memory (top left corner of column)
 *               patchIndex: current patch index (0 for 1. column)
 *               rowCount:   number of rows to draw
 * 
 * ---------------------------------------------------------------- */ 

.macro patchSelectorDrawColumn(patchIndex, rowCount)
{
columnRowLoop:
    ldx #2
    lda #WHITE
    jsr screenPutColorLengthAddress

    lda patchIndex
    jsr patchesOutputPatchNumber

    addByteValueToZPRAddress(ZPR_1, 3)

    lda patchIndex
    jsr patchesLoadPatchMemoryAddressIntoZPR8
    jsr patchesOutputPatchName

    addByteValueToZPRAddress(ZPR_1, 37)
    addByteValueToZPRAddress(ZPR_3, 40)

    inc patchIndex
    dec rowCount
    bne columnRowLoop
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the screen and color memory address of the currently
 * selected patch item
 *
 * Reads global variabels: currentPatchSelectorColumn, currentPatchSelectorRow
 *
 * Returns: ZPR_1 - address into screen memory
 *          ZPR_3 - address into color memory
 *
 * ---------------------------------------------------------------- */ 

patchSelectorCalculateCurrentSelectionAddresses:
{
    // switch for currentPatchSelectorColumn
    lda currentPatchSelectorColumn
    cmp #0
    beq column1Selected
    cmp #1
    beq column2Selected
    cmp #2
    beq column3Selected
    rts

column1Selected:
    // calculate address for top left corner of column 1
    patchSelectorLoadColumn1MemoryAddresses()
    jmp addRowOffset

column2Selected:
    // calculate address for top left corner of column 2
    patchSelectorLoadColumn2MemoryAddresses()
    jmp addRowOffset

column3Selected:
    // calculate address for top left corner of column 3
    patchSelectorLoadColumn3MemoryAddresses()
    jmp addRowOffset

addRowOffset:
    // calculate rowOffset = currentPatchSelectorRow * 40
    lda currentPatchSelectorRow
    ldx #40
    jsr mathMultiply
    stx rowOffset
    sta rowOffset+1

    // add the offset to both the screen and the color memory addresses
    addWordToZPRAddress(ZPR_1, rowOffset)
    addWordToZPRAddress(ZPR_3, rowOffset)

    rts

rowOffset:
    .byte(0)
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Draws the focus (yellow bar) for the currently selected patch
 *
 * Reads global variables: currentPatchSelectorColumn, currentPatchSelectorRow
 *
 * ---------------------------------------------------------------- */ 

patchSelectorAddFocus:
{
    // calculate ZPR_1 (screen memory address) and ZPR_3 (color memory address)
    jsr patchSelectorCalculateCurrentSelectionAddresses

    ldy #0
loop:
    lda (ZPR_1), y
    clc
    adc #128
    sta (ZPR_1), y
    lda #YELLOW
    sta (ZPR_3), y
    iny
    cpy #11
    bne loop

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Re-draws the currently selected (focused) patch item, before
 * the focus will be applied to the new selection
 *
 * Parameters:             Accu - index of currently selected patch
 *                         (the global variable currentPatchSelectorIndex,
 *                         contains the newly selected index at this point)
 *
 * Reads global variables: currentPatchSelectorColumn, currentPatchSelectorRow
 *
 * ---------------------------------------------------------------- */ 

patchSelectorRemoveFocus:
{
    sta patchIndex

    // calculate ZPR_1 (screen memory address) and ZPR_3 (color memory address)
    jsr patchSelectorCalculateCurrentSelectionAddresses

    // paint the first two characters in white
    ldx #2
    lda #WHITE
    jsr screenPutColorLengthAddress

    // paint the next 9 characters in gray
    addByteValueToZPRAddress(ZPR_3, 2)
    ldx #9
    lda #GRAY
    jsr screenPutColorLengthAddress

    // print the patch index number
    lda patchIndex
    jsr patchesOutputPatchNumber

    // print a space between patch index number and patch name
    lda #32
    ldy #2
    sta (ZPR_1), y

    // print patch name
    addByteValueToZPRAddress(ZPR_1, 3)
    lda patchIndex
    jsr patchesLoadPatchMemoryAddressIntoZPR8
    jsr patchesOutputPatchName

    rts

patchIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the values for currentPatchSelectorColumn and currentPatchSelectorRow
 * derived from the current value of currentPatchSelectorIndex
 *
 * Reads global variables:   currentPatchSelectorIndex
 *
 * Writes global variables:  currentPatchSelectorColumn, currentPatchSelectorRow
 *
 * ---------------------------------------------------------------- */ 

patchSelectorCalculateCurrentColumnAndRowFromIndex:
{
    // switch by value of currentPatchSelectorIndex  
    lda currentPatchSelectorIndex
    cmp #44
    bcs thirdColumn
    cmp #22
    bcs secondColumn

    // is first column
    // set currentPatchSelectorRow to currentPatchSelectorIndex
    // and currentPatchSelectorColumn to 0
    sta currentPatchSelectorRow
    lda #0
    sta currentPatchSelectorColumn
    rts

secondColumn:
    // is second column
    // set currentPatchSelectorRow to currentPatchSelectorIndex - 22
    // and currentPatchSelectorColumn to 1
    sec
    sbc #22
    sta currentPatchSelectorRow
    lda #1
    sta currentPatchSelectorColumn
    rts

thirdColumn:
    // is second column
    // set currentPatchSelectorRow to currentPatchSelectorIndex - 44
    // and currentPatchSelectorColumn to 2
    sec
    sbc #44
    sta currentPatchSelectorRow
    lda #2
    sta currentPatchSelectorColumn
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the keyboard input for the patch selector
 *
 * Reads global variables:  currentPatchSelectorIndex, currentPatchSelectorColumn,
 *                          currentPatchSelectorRow
 *
 * Writes global variables: currentPatchSelectorIndex, currentPatchSelectorColumn,
 *                          currentPatchSelectorRow
 *
 * ---------------------------------------------------------------- */ 

patchSelectorHandleKeyboardInput:
{
    // save the current selected patch index
    lda currentPatchSelectorIndex
    sta oldPatchIndex

    // Read pressed keycode, if no key pressed, exit
    jsr KERNAL.GETIN
    cmp #$00
    beq exit

	// Switch for the handled keys.
    // Because the subroutine is rather long, use a little trick to avoid the
    // problems with branching instructions on the 6502, which only can jump -127/+127 bytes.
    // see here: https://www.lemon64.com/forum/viewtopic.php?t=81358
    
    // WASD
    cmp #PETSCII.S
	bne *+5
    jmp cursorDownKeyPressed
	cmp #PETSCII.D
	bne *+5
    jmp cursorRightKeyPressed
	cmp #PETSCII.W
	bne *+5
    jmp cursorUpKeyPressed
	cmp #PETSCII.A
	bne *+5
    jmp cursorLeftKeyPressed

    // cursor keys
    cmp #PETSCII.CURSOR_DOWN
	bne *+5
    jmp cursorDownKeyPressed
	cmp #PETSCII.CURSOR_RIGHT
	bne *+5
    jmp cursorRightKeyPressed
	cmp #PETSCII.CURSOR_UP
	bne *+5
    jmp cursorUpKeyPressed
	cmp #PETSCII.CURSOR_LEFT
	bne *+5
    jmp cursorLeftKeyPressed
	
    // return and space
    cmp #PETSCII.RETURN
	bne *+5
    jmp returnOrSpaceKeyPressed
	cmp #PETSCII.SPACE
	bne *+5
    jmp returnOrSpaceKeyPressed

    // F3
    cmp #PETSCII.F3
	bne *+5
    jmp f3KeyPressed

exit:
    // If no key pressed we can handle here, exit
    rts

    // ----------------------------------------------------
    // key down - increase the selected patch index by 1,
    // wrap around if bigger than 63
    // ----------------------------------------------------

cursorDownKeyPressed:
    lda currentPatchSelectorIndex
    cmp #63
    bcs cursorDownWrapAround

    inc currentPatchSelectorIndex
    jmp finalizeCursorMovement

cursorDownWrapAround:
    lda #0
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // key right - increase the selected patch index by 22,
    // wrap around if bigger than 63
    // ----------------------------------------------------

cursorRightKeyPressed:
    lda currentPatchSelectorIndex
    cmp #44
    bcs cursorRightWrapAround

    clc
    adc #22
    sta currentPatchSelectorIndex
    cmp #64
    bcc finalizeCursorMovement

    lda #63
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

cursorRightWrapAround:
    sec
    sbc #44
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // key up - decrease the selected patch index by 1,
    // wrap around if less then 0
    // ----------------------------------------------------

cursorUpKeyPressed:
    lda currentPatchSelectorIndex
    cmp #0
    beq cursorKeyUpWrapAround

    dec currentPatchSelectorIndex
    jmp finalizeCursorMovement

cursorKeyUpWrapAround:
    lda #63
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // key left - decrease the selected patch index by 22,
    // wrap around if less then 0
    // ----------------------------------------------------

cursorLeftKeyPressed:
    lda currentPatchSelectorIndex
    cmp #22
    bcc cursorLeftWrapAround

    sec
    sbc #22
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

cursorLeftWrapAround:
    clc
    adc #44
    sta currentPatchSelectorIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // return or space key - user selected a new patch,
    // switch to the new patch then close the patch selector
    // ----------------------------------------------------

returnOrSpaceKeyPressed:
    // check if the selected patch index
    // is different from the current patch index
    lda currentPatchSelectorIndex
    cmp currentPatchIndex
    beq samePatchIndexAsBefore

    // yes, different index -> save the current patch
    // then switch to the selected patch
    lda currentPatchIndex
    jsr patchesTransferFromModulesToPatch
    lda currentPatchSelectorIndex
    jsr patchesSwitchToPatch

samePatchIndexAsBefore:
    jsr switchToModeMain
    rts

    // ----------------------------------------------------
    // f3 key - cancel and close the patch selector
    // ----------------------------------------------------

f3KeyPressed:
    jsr switchToModeMain
    rts

    // ----------------------------------------------------
    // after each cursor movement move the focus to the
    // newly selected item
    // ----------------------------------------------------

finalizeCursorMovement:
    lda oldPatchIndex
    jsr patchSelectorRemoveFocus
    jsr patchSelectorCalculateCurrentColumnAndRowFromIndex
    jsr patchSelectorAddFocus
    rts

oldPatchIndex:
    .byte(0)
}
