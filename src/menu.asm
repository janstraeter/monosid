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
    screenPutString(10, 1, strMainMenuSavePatchesToDisk)
    screenPutString(10, 3, strMainMenuLoadPatchesFromDisk)
    screenPutString(10, 5, strMainMenuRenameCurrentPatch)
    screenPutString(10, 7, strMainMenuClearCurrentPatch)
    screenPutString(10, 9, strMainMenuSetMidiChannel)
    screenPutString(10, 11, strMainMenuReturn)

    // print developer info
    screenPutStringColor(3, 23, strVersion, DARK_GRAY)
    screenPutStringColor(8, 23, strMainMenuDevelopedBy, DARK_GRAY)
    screenPutStringColor(9, 24, strMainMenuWebsite, DARK_GRAY)

    // print MIDI info headline
    screenPutStringColor(10, 14, strMidiInfoHeadline, WHITE)

    // print MIDI cartridge info
    screenPutString(10, 15, strMidiDetectedCartridge)

    // switch for midiDetectedCartridge
    lda midiDetectedCartridge
    cmp #MIDI_CARTRIDGE.SEQUENTIAL
    bne *+5
    jmp printMidiCartridgeSequential
    cmp #MIDI_CARTRIDGE.NAMESOFT
    bne *+5
    jmp printMidiCartridgeNamesoft
    cmp #MIDI_CARTRIDGE.DATEL_SIEL_JMS
    bne *+5
    jmp printMidiCartridgeDatel
    cmp #MIDI_CARTRIDGE.PASSPORT
    bne *+5
    jmp printMidiCartridgePassport
    cmp #MIDI_CARTRIDGE.MAPLIN
    bne *+5
    jmp printMidiCartridgeMaplin

    // no cartridge detected
    screenPutString(21, 15, strMidiCartridgeNone)
    jmp printMidiChannelInfo

printMidiCartridgeSequential:
    screenPutString(21, 15, strMidiCartridgeSequential)
    jmp printMidiChannelInfo

printMidiCartridgeNamesoft:
    screenPutString(21, 15, strMidiCartridgeNamesoft)
    jmp printMidiChannelInfo

printMidiCartridgeDatel:
    screenPutString(21, 15, strMidiCartridgeDatel)
    jmp printMidiChannelInfo

printMidiCartridgePassport:
    screenPutString(21, 15, strMidiCartridgePassport)
    jmp printMidiChannelInfo

printMidiCartridgeMaplin:
    screenPutString(21, 15, strMidiCartridgeMaplin)
    jmp printMidiChannelInfo

printMidiChannelInfo:
    // print MIDI channel info
    screenPutString(10, 16, strMidiChannel)
    
    // check if a specific channel is set (<> 255)
    lda midiChannel
    cmp #255
    beq printMidiChannelAny

    // add 1, because by convention the zero based MIDI channel is communicated to the user as 1-16
    clc
    adc #1
    
    // convert the channel number into string
    sta ZPR_1_LO
    lda #$00
    sta ZPR_1_HI
    loadPointerToZPR(stringBuffer, ZPR_2)
    lda #$30
    sta ZPR_0
    jsr convertIntegerToString

    // print the converted channel number
    screenPutString(21, 16, stringBuffer)

    rts

printMidiChannelAny:
    screenPutString(21, 16, strMidiChannelAny)

    rts

stringBuffer:
    .fill 6, 0
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
    .var menuTopLeftAddress = screenCalculateMemoryAddress(8, 1)
    loadPointerToZPR(menuTopLeftAddress, ZPR_1)
    
    // load color memory address of top left corner of the menu into ZPR_3
    .var menuTopLeftColorAddress = screenCalculateColorMemoryAddress(8, 1)
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
    ldx #28
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
    ldx #28
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
    cmp #MENU_ITEM.SET_MIDI_CHANNEL
    beq setMidiChannel
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
    jsr patchesDrawRenameScreen
    jsr menuActivateEditorForPatchRename
    lda #MODE_MENU_SUBMODE.RENAME_PATCH
    sta currentSubMode
    rts

    // ----------------------------------------------------
    // clear current patch
    // ----------------------------------------------------

clearCurrentPatch:
    jsr menuHandleMenuItemActionClearCurrentPatch
    rts

    // ----------------------------------------------------
    //set midi channel
    // ----------------------------------------------------

setMidiChannel:
    jsr menuDrawSetMidiChannelScreen
    jsr menuActivateEditorForSetMidiChannel
    lda #MODE_MENU_SUBMODE.SET_MIDI_CHANNEL
    sta currentSubMode
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


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the "Set MIDI channel" screen
 *
 * Reads global variables: midiChannel
 *
 * ---------------------------------------------------------------- */ 

menuDrawSetMidiChannelScreen:
{
    // clear screen, use uppercase, hide logo
    jsr screenSwitchToUpperCase
    jsr logoHide
    jsr userinterfaceInitScreen
    
    // print headline
    screenPutStringColor(12, 8, strSetMidiChannelHeadline, WHITE)

    // print box for channel input
    screenDrawRectangleColor(17, 11, 3, 1, YELLOW)
    screenPutColorLength(18, 12, 3, WHITE)
    
    // print additional info text
    screenPutString(10, 16, strSetMidiChannelInfo1)
    screenPutString(1, 17, strSetMidiChannelInfo2)

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prepares the menu input editor to be used for renaming the current
 * patch. 
 * 
 *
 * Writes global variables: menuInputEditorX, menuInputEditorY,
 *                          menuInputEditorMaxLength,
 *                          menuInputEditorAllowedCharactersMin,
 *                          menuInputEditorAllowedCharactersMax
 *
 * ---------------------------------------------------------------- */ 

menuActivateEditorForPatchRename:
{
    // set the menu editor`s variables
    lda #15
    sta menuInputEditorX
    lda #12
    sta menuInputEditorY
    lda #8
    sta menuInputEditorMaxLength
    lda #32
    sta menuInputEditorAllowedCharactersMin
    lda #96
    sta menuInputEditorAllowedCharactersMax

    // activate the editor
    jsr menuActivateEditor

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prepares the menu input editor to be used for setting the
 * MIDI channel
 * 
 *
 * Writes global variables: menuInputEditorX, menuInputEditorY,
 *                          menuInputEditorMaxLength,
 *                          menuInputEditorAllowedCharactersMin,
 *                          menuInputEditorAllowedCharactersMax
 *
 * ---------------------------------------------------------------- */ 

menuActivateEditorForSetMidiChannel:
{
    // set the menu editor`s variables
    lda #18
    sta menuInputEditorX
    lda #12
    sta menuInputEditorY
    lda #2
    sta menuInputEditorMaxLength
    lda #48
    sta menuInputEditorAllowedCharactersMin
    lda #57
    sta menuInputEditorAllowedCharactersMax

    // activate the editor
    jsr menuActivateEditor

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Activates the menu input editor. Clears the input buffer,
 * sets the cursor position to the beginning of the input field,
 * activates the cursor blinking.
 *
 * Writes global variables: menuInputEditorBuffer
 *
 * ---------------------------------------------------------------- */ 

menuActivateEditor:
{
    // set cursor color
    lda #WHITE
    sta KERNAL.TEXTCOLOR
    sta KERNAL.CURSORCOLOR

    // activate cursor
    lda #0
    sta ZP.CURSOR_FLASH

    // empty the string referenced by "menuInputEditorBuffer" by writing a zero to the first byte
    lda #0
    sta menuInputEditorBuffer

    // set cursor position accordingly
    jsr menuEditorUpdateCursorPosition

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Deactivates the cursor blinking and switches to the main mode
 *
 * ---------------------------------------------------------------- */ 

menuDeactivateEditor:
{
    // deactivate cursor
    lda #$FF
    sta ZP.CURSOR_FLASH

    // return to main screen
    jsr switchToModeMain

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets the position of the cursor to the menu input editor,
 * after the last character of the contents of "menuInputEditorBuffer".
 *
 * Reads global variables:  menuInputEditorBuffer, menuInputEditorX,
 *                          menuInputEditorY
 *
 * Writes global variables: none
 *
 * ---------------------------------------------------------------- */ 

menuEditorUpdateCursorPosition:
{
    // get length of text in "menuInputEditorBuffer" and save it in ZPR_0
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    jsr stringGetLength
    sta ZPR_0
    
	// load Y position into X
    ldx menuInputEditorY
    
    // load X position (menuInputEditorX + string length) into Y
    lda menuInputEditorX
    clc
    adc ZPR_0
    tay

    // clear carry to indicate that we want to set the position of the cursor not read it
    clc
    
    // call the Kernal function (https://www.pagetable.com/c64ref/kernal/, search for "$FFF0" or "plot")
    jsr KERNAL.PLOT

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Prints the current content of the input buffer and pads it
 * with blanks if shorter than the max. length
 *
 * Reads global variables:  menuInputEditorBuffer, menuInputEditorX,
 *                          menuInputEditorY
 *
 * ---------------------------------------------------------------- */ 

menuEditorOutputCurrentString:
{
    // load address of input buffer into ZPR_1
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)

    // load X and Y position into ZPR_2
    lda menuInputEditorX
    sta ZPR_2_LO
    lda menuInputEditorY
    sta ZPR_2_HI

    // print the string
    jsr screenPutStringXY

    // ZPR_2 now contains the screen memory address (screenPutStringXY calculated it)
    // the Y register contains the number of written bytes

    // calculate the number of characters to pad
    // padding = menuInputEditorMaxLength + 1 - bytesWritten
    tya
    sta bytesWritten
    lda menuInputEditorMaxLength
    clc
    adc #1
    sec
    sbc bytesWritten
    beq exit

    // pad the remaining characters of the input field with blank spaces
    sta padding
    lda #32

paddingLoop:
    sta (ZPR_2), y
    iny
    dec padding
    bne paddingLoop

exit:
    rts

bytesWritten:
    .byte(0)

padding:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the keyboard input for the menu input editor
 * 
 * Reads global variables:  menuInputEditorAllowedCharactersMin,
 *                          menuInputEditorAllowedCharactersMax
 *
 * ---------------------------------------------------------------- */ 

menuHandleKeyboardInputForEditor:
{
    // Read pressed keycode, if no key pressed, exit
    jsr KERNAL.GETIN
    cmp #$00
    beq exit1

    // check if return or delete is pressed and jump accordingly
    cmp #PETSCII.DELETE
	beq deleteKeyPressed
    cmp #PETSCII.RETURN
	beq returnKeyPressed

    // check if pressed key is in the range of allowed characters 
    // if any other character, exit
    cmp menuInputEditorAllowedCharactersMin
    bcc exit1
    cmp menuInputEditorAllowedCharactersMax
    beq validCharacter
    bcs exit1
    jmp validCharacter

exit1:
    rts

validCharacter:    
    // convert the chraracter into screen code and save it into pressedKeyCode
    jsr convertPetsciiToScreenCode
    sta pressedKeyCode

    // determine the length of the input editors current text
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    jsr stringGetLength
    
    // compare the current length with the max. length, exit of max. length is reached
    cmp menuInputEditorMaxLength
    bcs exit

    // max. length not reached, append the pressed keycode to the editor`s text
    tay
    lda pressedKeyCode
    sta (ZPR_1), y
    iny
    lda #0
    sta (ZPR_1), y

    // update the screen and cursor position
    jsr menuEditorUpdateCursorPosition
    jsr menuEditorOutputCurrentString

    rts

deleteKeyPressed:
    // load address of current text into ZPR_1
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    
    // determine the length of the input editors current text
    jsr stringGetLength
    
    // check current length for zero - if zero, exit
    cmp #0
    beq exit

    // length is greater than zero,
    // move one byte to the left and write a null byte
    tay
    dey
    lda #0
    sta (ZPR_1), y

    // update the screen and cursor position
    jsr menuEditorUpdateCursorPosition
    jsr menuEditorOutputCurrentString

    rts

returnKeyPressed:
    // return key pressed - finish the editor
    jsr menuHandleInputEditorFinish

exit:
    rts

pressedKeyCode:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Finishes the menu input editor after return key pressed.
 * Handles renaming the current patch or setting the midi channel
 * according to the current sub mode
 * 
 * Reads global variables:  currentSubMode,
 *                          menuInputEditorBuffer
 *
 * Writes global variables: currentPatchAddress
 *
 * ---------------------------------------------------------------- */ 

menuHandleInputEditorFinish:
{
    // switch for menu sub mode
    lda currentSubMode
    cmp #MODE_MENU_SUBMODE.RENAME_PATCH
    beq finishRenamePatch
    cmp #MODE_MENU_SUBMODE.SET_MIDI_CHANNEL
    beq finishSetMidiChannel
    jmp finish

    // ----------------------------------------------------
    // rename patch
    // ----------------------------------------------------

finishRenamePatch:

    // load address of buffer into ZPR_1
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    
    // check if string length, do not update the name if zero
    jsr stringGetLength
    cmp #0
    beq finish
	
    // load address of current patch into ZPR_2
    lda currentPatchAddress
	sta ZPR_2_LO
	lda currentPatchAddress+1
	sta ZPR_2_HI
    
    // copy over the new patch name and done
    jsr stringCopy
    jmp finish

    // ----------------------------------------------------
    // change midi channel
    // ----------------------------------------------------

finishSetMidiChannel:

    // load address of buffer into ZPR_1
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    
    // check if string length, set to any channel if zero
    jsr stringGetLength
    cmp #0
    beq setToAnyChannel
	
    // convert string into (16-bit unsigned) integer
    lda #$30
    sta ZPR_0
    loadPointerToZPR(menuInputEditorBuffer, ZPR_1)
    jsr convertStringToInteger
    
    // ZPR_2_LO now contains the low byte of the conversion
    lda ZPR_2_LO

    // check if in range 1-16, if out of range, set to any channel
    cmp #1
    bcc setToAnyChannel
    cmp #17
    bcs setToAnyChannel

    // is 1-16, set as new MIDI channel number and done
    sec
    sbc #1
    sta midiChannel
    jmp finish

setToAnyChannel:
    // assume any channel
    lda #255
    sta midiChannel

finish:
    // deactivate the editor
    jsr menuDeactivateEditor

    rts
}
