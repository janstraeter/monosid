#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the screen and draws the main menu, switches to the
 * mixed case character set
 *
 * ---------------------------------------------------------------- */ 

menuDrawMain:
{
    // clear screen and switch to mixed case character set
    jsr userinterfaceInitScreen
    jsr screenSwitchToMixedCase

    // print menu items
    screenPutString(5, 1, strMainMenuSavePatchesToDisk)
    screenPutString(5, 3, strMainMenuLoadPatchesFromDisk)
    screenPutString(5, 5, strMainMenuRenameCurrentPatch)
    screenPutString(5, 7, strMainMenuClearCurrentPatch)
    screenPutString(5, 9, strMainMenuMidiCartridgeSetup)
    screenPutString(5, 11, strMainMenuSetMidiChannel)
    screenPutString(5, 13, strMainMenuSaveMidiSettings)
    screenPutString(5, 15, strMainMenuReturn)

    // print developer info
    screenPutStringColor(5, 23, strMainMenuDevelopedBy, DARK_GRAY)
    screenPutStringColor(9, 24, strMainMenuWebsite, DARK_GRAY)
    
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the screen and color memory address of the top left
 * corner of the given menu item
 *
 * Parameters:     Accu - zero based index of menu item
 *
 * Returns values: ZPR_1 - screen memory address
 *                 ZPR_3 - color memory address
 *
 * ---------------------------------------------------------------- */ 

menuCalculateAddressOfCurrentMenuItem:
{
    // calculate the address offset of the currently selected menu item
    ldx #80
    jsr mathMultiply
    stx rowOffset
    sta rowOffset+1

    // load screen memory address of top left corner of the menu into ZPR_1
    .var menuTopLeftAddress = screenCalculateMemoryAddress(3, 1)
    loadPointerToZPR(menuTopLeftAddress, ZPR_1)
    
    // load color memory address of top left corner of the menu into ZPR_3
    .var menuTopLeftColorAddress = screenCalculateColorMemoryAddress(3, 1)
    loadPointerToZPR(menuTopLeftColorAddress, ZPR_3)

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
 * Adds the focus to the currently selected menu item,
 * adds a ">" in front of it and changes the color to yellow
 *
 * Reads global variables: currentMenuIndex
 *
 * ---------------------------------------------------------------- */ 

menuAddItemFocus:
{
    // load currently selected menu index and calculate addresses
    lda currentMenuIndex
    jsr menuCalculateAddressOfCurrentMenuItem

    // print ">" in front of the item
    lda strMainMenuFocusedItem
    ldy #0
    sta (ZPR_1), y

    // make the item yellow
    lda #YELLOW
    ldx #35
    jsr screenPutColorLengthAddress

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Removes the focus to the currently selected menu item
 *
 * Parameters:     Accu - zero based index of menu item
 *
 * ---------------------------------------------------------------- */ 

menuRemoveItemFocus:
{
    // index is in the accu, calculate addresses
    jsr menuCalculateAddressOfCurrentMenuItem

    // overwrite the ">" with a blank space
    lda #32
    ldy #0
    sta (ZPR_1), y

    // make the item gray again
    lda #GRAY
    ldx #35
    jsr screenPutColorLengthAddress

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the keyboard input of the main menu
 *
 * Reads global variables: currentMenuIndex
 *
 * Writes global variables: currentMenuIndex
 *
 * ---------------------------------------------------------------- */ 

menuHandleKeyboardInput:
{
    // save the current selected menu item index
    lda currentMenuIndex
    sta oldMenuItemIndex

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
	cmp #PETSCII.W
	bne *+5
    jmp cursorUpKeyPressed

    // cursor keys
    cmp #PETSCII.CURSOR_DOWN
	bne *+5
    jmp cursorDownKeyPressed
	cmp #PETSCII.CURSOR_UP
	bne *+5
    jmp cursorUpKeyPressed
	
    // return and space
    cmp #PETSCII.RETURN
	bne *+5
    jmp returnOrSpaceKeyPressed
	cmp #PETSCII.SPACE
	bne *+5
    jmp returnOrSpaceKeyPressed

    // F1
    cmp #PETSCII.F1
	bne *+5
    jmp f1KeyPressed

exit:
    // If no key pressed we can handle here, exit
    rts

    // ----------------------------------------------------
    // key down - increase the selected menu item index by 1,
    // wrap around if bigger than MENU_ITEMS_NUM - 1
    // ----------------------------------------------------

cursorDownKeyPressed:
    lda currentMenuIndex
    cmp #MENU_ITEMS_NUM - 1
    bcs cursorDownWrapAround

    inc currentMenuIndex
    jmp finalizeCursorMovement

cursorDownWrapAround:
    lda #0
    sta currentMenuIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // key up - decrease the selected menu item index by 1,
    // wrap around if less then 0
    // ----------------------------------------------------

cursorUpKeyPressed:
    lda currentMenuIndex
    cmp #0
    beq cursorKeyUpWrapAround

    dec currentMenuIndex
    jmp finalizeCursorMovement

cursorKeyUpWrapAround:
    lda #MENU_ITEMS_NUM - 1
    sta currentMenuIndex
    jmp finalizeCursorMovement

    // ----------------------------------------------------
    // return or space key - user wants to execute
    // the selected menu item, so call the handling subroutine
    // ----------------------------------------------------

returnOrSpaceKeyPressed:
    jsr menuHandleSelectedMainMenuItem
    rts

    // ----------------------------------------------------
    // f1 key - cancel and close the patch selector
    // ----------------------------------------------------

f1KeyPressed:
    jsr switchToModeMain
    rts

    // ----------------------------------------------------
    // after each cursor movement move the focus to the
    // newly selected item
    // ----------------------------------------------------

finalizeCursorMovement:
    lda oldMenuItemIndex
    jsr menuRemoveItemFocus
    jsr menuAddItemFocus
    rts

oldMenuItemIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Executes the corresponding action of the currently selected main menu item
 *
 * Reads global variables: currentMenuIndex
 *
 * ---------------------------------------------------------------- */ 

menuHandleSelectedMainMenuItem:
{
    // switch for currentMenuIndex
    lda currentMenuIndex
    cmp #MENU_ITEM.SAVE_PATCHES
    beq savePatches
    cmp #MENU_ITEM.LOAD_PATCHES
    beq loadPatches
    cmp #MENU_ITEM.RENAME_CURRENT_PATCH
    beq renameCurrentPatch
    cmp #MENU_ITEM.CLEAR_CURRENT_PATCH
    beq clearCurrentPatch
    cmp #MENU_ITEM.MIDI_CARTRIDGE_SETUP
    beq midiCartridgeSetup
    cmp #MENU_ITEM.SET_MIDI_CHANNEL
    beq setMidiChannel
    cmp #MENU_ITEM.SAVE_MIDI_SETTINGS
    beq saveMidiSettings
    cmp #MENU_ITEM.RETURN
    beq return

    // if index can not be handled, exit
    rts

    // ----------------------------------------------------
    // save patches to disk
    // ----------------------------------------------------

savePatches:
    lda currentPatchIndex
    jsr patchesTransferFromModulesToPatch
    jsr patchesDrawSaveScreen
    jsr patchesSaveToDisk
    bcc savePatchesSuccessful
    lda #MODE_MENU_SUBMODE.SHOW_ERROR_MESSAGE
    sta currentSubMode
    rts

savePatchesSuccessful:
    jsr switchToModeMain
    rts

    // ----------------------------------------------------
    // load patches from disk
    // ----------------------------------------------------

loadPatches:
    jsr patchesDrawLoadScreen
    jsr patchesLoadFromDisk
    bcc loadPatchesSuccessful
    lda #MODE_MENU_SUBMODE.SHOW_ERROR_MESSAGE
    sta currentSubMode
    rts

loadPatchesSuccessful:
    lda currentPatchIndex
    jsr patchesTransferFromPatchToModules
    jsr sidUpdateAllRegisters
    jsr switchToModeMain
    rts

    // ----------------------------------------------------
    // rename current patch
    // ----------------------------------------------------

renameCurrentPatch:
    rts

    // ----------------------------------------------------
    // clear current patch
    // ----------------------------------------------------

clearCurrentPatch:
    jsr menuHandleMenuItemActionClearCurrentPatch
    rts

    // ----------------------------------------------------
    // midi cartridge setup
    // ----------------------------------------------------

midiCartridgeSetup:
    rts

    // ----------------------------------------------------
    //set midi channel
    // ----------------------------------------------------

setMidiChannel:
    rts

    // ----------------------------------------------------
    // save midi settings
    // ----------------------------------------------------

saveMidiSettings:
    rts

    // ----------------------------------------------------
    // return to main mode
    // ----------------------------------------------------

return:
    jsr switchToModeMain
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Empties the current patch and updates the SID and the UI
 *
 * Reads global variables: currentPatchIndex
 *
 * ---------------------------------------------------------------- */ 

menuHandleMenuItemActionClearCurrentPatch:
{
    // reset the current patch data to the initial state
    lda currentPatchIndex
    jsr patchesInitPatch
    
    // tranfer patch data to the input fields of the modules
    lda currentPatchIndex
    jsr patchesTransferFromPatchToModules
    
    // update the SID and return to the main UI
    jsr sidUpdateAllRegisters
    jsr switchToModeMain

    rts
}
