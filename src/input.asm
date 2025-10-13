#importonce

#import "constants.asm"
#import "zpregisters.asm"
#import "structs.asm"
#import "string.asm"
#import "math.asm"
#import "convert.asm"
#import "globals.asm"
#import "userinterface.asm"
#import "sid.asm"


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Loads the address of the struc of the currently selected input
 * into ZPR_7 (and the address of the currently selected module`s input array into ZPR_6)
 *
 * Reads global variables:  modules, currentModuleIndex, currentInputIndex
 * Writes global variables: none
 * 
 * ---------------------------------------------------------------- */ 

inputLoadAddressOfCurrentInputToZPR7:
{
	// load the address of the modules array into ZPR_6
	loadPointerToZPR(modules, ZPR_6)

	// load the address of the currently selected module into ZPR_7
	stuctLoadPointerArrayItemToZPR(ZPR_6, currentModuleIndex, ZPR_7)

	// load the address of the currently selected module`s input array into ZPR_6
	structLoadWordToZPR(ZPR_7, STRUCT_MODULE.INPUT_ARRAY, ZPR_6)

	// load the address of the currently selected input into ZPR_7
	stuctLoadPointerArrayItemToZPR(ZPR_6, currentInputIndex, ZPR_7)

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * calls the update subroutine to transfer the current value
 * of an input struct to the corresponding control register
 * of the SID chip.
 *
 * Because the JSR instruction of the 6502/6510 cannot use indirect
 * addressing, we have to use a combination of JSR and JMP
 * (JMP can use indirect addressing)
 *
 * See here: https://www.nesdev.org/wiki/Jump_table
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputCallSidUpdateSubroutine:
{
    structLoadWordToZPR(ZPR_7, STRUCT_INPUT.UPDATE_SUBROUTINE, ZPR_1)
    jsr callSubroutine
    rts
callSubroutine:
    jmp (ZPR_1)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the current value of an integer input is higher
 * than it`s allowed max. value. If so, sets it to the max. value.
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputIntegerSanitizeValue:
{
	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	rts

typeInteger4Bits:
	// the simple case: 8 bit comparison
    // check if value is lower than 16, if not, set it to 15
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    cmp #$10
    bcc exit
    lda #$0F
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
	rts

typeInteger11Bits:
    // 16 bit comparison (for the 11 bit input fields max. value is 2047)
    // set the hibyte/MSB to 0111 binary
    lda #$07
    sta maxValue+1
	jmp SixteenBitComparison

typeInteger12Bits:
    // 16 bit comparison (for the 12 bit input fields max. value is 4095)
    // set the HiByte/MSB to 1111 binary
    lda #$0F
    sta maxValue+1

SixteenBitComparison:
    // set the LoByte/LSB to 1111 1111 binary
    lda #$FF
    sta maxValue

    // load MSB of value and compare it to MSB of maxValue
    ldy #STRUCT_INPUT.VALUE+1
    lda (ZPR_7), y        // MSB of 1st number (X)
    cmp maxValue+1        // MSB of 2nd number (Y)
    bcc isLower           // X < Y
    bne isHigher          // X > Y
    
    // load LSB of value and compare it to LSB of maxValue
    dey
    lda (ZPR_7), y        // LSB of 1st number (X)
    cmp maxValue          // LSB of 2nd number (Y)
    bcc isLower           // X < Y
    beq isSame            // X = Y
    bne isHigher          // X > Y

isHigher:
    // value is higher than the max. value, set it to the max. value
    lda maxValue
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    lda maxValue+1
    iny
    sta (ZPR_7), y

isLower:
isSame:
exit:
    rts

maxValue:
    .byte(0)
    .byte(0)
    
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Increases the value of an integer intput (if max value not reached yet)
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputIntegerIncreaseValue:
{
	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	rts

typeInteger4Bits:
	// the simple case: 8 bit comparison
    // check if max. value of 15 is reached, if not increase by 1
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    cmp #$0F
    bcs exit
    clc
    adc #1
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
	rts

typeInteger11Bits:
    // 16 bit comparison (for the 11 bit input fields max. value is 2047)
    // set the hibyte/MSB to 0111 binary
    lda #$07
    sta maxValue+1
	jmp SixteenBitComparison

typeInteger12Bits:
    // 16 bit comparison (for the 12 bit input fields max. value is 4095)
    // set the HiByte/MSB to 1111 binary
    lda #$0F
    sta maxValue+1

SixteenBitComparison:
    // set the LoByte/LSB to 1111 1111 binary
    lda #$FF
    sta maxValue

    // load MSB of value and compare it to MSB of maxValue
    ldy #STRUCT_INPUT.VALUE+1
    lda (ZPR_7), y        // MSB of 1st number (X)
    cmp maxValue+1        // MSB of 2nd number (Y)
    bcc isLower           // X < Y
    bne isHigher          // X > Y
    
    // load LSB of value and compare it to LSB of maxValue
    dey
    lda (ZPR_7), y        // LSB of 1st number (X)
    cmp maxValue          // LSB of 2nd number (Y)
    bcc isLower           // X < Y
    beq isSame            // X = Y
    bne isHigher          // X > Y

isLower:
    // value is lower than maxValue,
    // add 1 and save it back to the value in the struct
    clc
    ldy #STRUCT_INPUT.VALUE
    lda (ZPR_7), y
    adc #1
    sta (ZPR_7), y
    iny
    lda (ZPR_7), y
    adc #0
    sta (ZPR_7), y

isHigher:
isSame:
exit:
    rts

maxValue:
    .byte(0)
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Decreases the value of an integer intput (if zero not reached yet)
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputIntegerDecreaseValue:
{
	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.INTEGER_4_BITS
	beq typeInteger4Bits
	cmp #INPUT_TYPE.INTEGER_11_BITS
	beq typeInteger11Bits
	cmp #INPUT_TYPE.INTEGER_12_BITS
	beq typeInteger12Bits
	rts

typeInteger4Bits:
	// load current value and check if zero
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    cmp #0
    beq exit
    
    // current value is not zero, decrease by 1 and save value
    sec
    sbc #1
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
	rts

typeInteger11Bits:
typeInteger12Bits:

    // load MSB of value and compare it to zero
    ldy #STRUCT_INPUT.VALUE+1
    lda #0
    cmp (ZPR_7), y
    bne isGreaterThanZero
    
    // load LSB of value and compare it zero
    dey
    lda #0
    cmp (ZPR_7), y
    bne isGreaterThanZero

    // 16 bit value is zero, exit
    rts

isGreaterThanZero:
    // value is greater than zero,
    // add 1 and save it back to the value in the struct
    sec
    ldy #STRUCT_INPUT.VALUE
    lda (ZPR_7), y
    sbc #1
    sta (ZPR_7), y
    iny
    lda (ZPR_7), y
    sbc #0
    sta (ZPR_7), y

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Selects the next value of an waveform input (wraps around if necessary)
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputWaveformSelectNext:
{
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
    lda #WAVEFORM.SAWTOOTH
    jmp writeValue
	
waveformSawtooth:
    lda #WAVEFORM.SQUARE
    jmp writeValue
	
waveformSquare:
    lda #WAVEFORM.NOISE
    jmp writeValue
	
waveformNoise:
    lda #WAVEFORM.TRIANGULAR

writeValue:
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Selects the previous value of an waveform input (wraps around if necessary)
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputWaveformSelectPrevious:
{
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
    lda #WAVEFORM.NOISE
    jmp writeValue
	
waveformSawtooth:
    lda #WAVEFORM.TRIANGULAR
    jmp writeValue
	
waveformSquare:
    lda #WAVEFORM.SAWTOOTH
    jmp writeValue
	
waveformNoise:
    lda #WAVEFORM.SQUARE

writeValue:
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Toogles the value of an boolean input
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputBooleanToggle:
{
	// Load current value and check if greater than zero
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    cmp #0
    beq setOne

    // current value is greater than zero, set to zero
    lda #0
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    rts

setOne:
    // current value is zero, set to 1
    lda #1
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Is called if the user pressed return at the currently selected input.
 *
 * Action:
 * for number input fields -> start the editor mode
 * for waveform inputs -> switch to next waveform
 * for boolean inputs -> toggle
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputHandleReturnKeyPressed:
{
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
    jsr inputWaveformSelectNext
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts

typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
    jsr inputActivateEditor
	rts

typeBoolean:
    jsr inputBooleanToggle
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Is called if the user pressed space at the currently selected input.
 *
 * Action:
 * for waveform inputs -> switch to next waveform
 * for boolean inputs -> toggle
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputHandleSpaceKeyPressed:
{
	// Switch for the input´s type
	structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
	cmp #INPUT_TYPE.WAVEFORM
	beq typeWaveform
	cmp #INPUT_TYPE.BOOLEAN
	beq typeBoolean
	rts

typeWaveform:
    jsr inputWaveformSelectNext
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts

typeBoolean:
    jsr inputBooleanToggle
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Is called if the user pressed the plus key at the currently selected input.
 *
 * Action:
 * for number input fields -> increase value by 1 (if max value is not reached)
 * for waveform inputs -> switch to next waveform
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputHandlePlusKeyPressed:
{
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
	rts

typeWaveform:
    jsr inputWaveformSelectNext
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts

typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
    jsr inputIntegerIncreaseValue
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Is called if the user pressed the minus key at the currently selected input.
 *
 * Action:
 * for number input fields -> decrease value by 1 (if greater than zero)
 * for waveform inputs -> switch to previous waveform
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * ---------------------------------------------------------------- */ 

inputHandleMinusKeyPressed:
{
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
	rts

typeWaveform:
    jsr inputWaveformSelectPrevious
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts

typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
    jsr inputIntegerDecreaseValue
    jsr userInterfaceUpdateInput
    jsr inputCallSidUpdateSubroutine
	rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Engages the editor for integer intput fields. Activates the cursor
 * and sets it to the position of the current input field, 
 * switches the program into editor mode.
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * Reads global variables:  none
 * Writes global variables: currentSubMode, currentInputEditorText
 *
 * ---------------------------------------------------------------- */ 

inputActivateEditor:
{
    // activate cursor
    lda #0
    sta ZP.CURSOR_FLASH

    // empty the string referenced by "currentInputEditorText" by writing a zero to the first byte
    lda #0
    sta currentInputEditorText

    // re-draw the input field with the editor
    jsr userInterfaceDrawInputEditor

    // set cursor position accordingly
    jsr inputEditorUpdateCursorPosition

    // switch program into editor mode
    lda #MODE_MAIN_SUBMODE.INPUT_EDITOR
    sta currentSubMode

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * 
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * Reads global variables:  none
 * Writes global variables: currentSubMode, currentInputEditorText
 *
 * ---------------------------------------------------------------- */ 

inputDeactivateEditor:
{
    // deactivate cursor
    lda #$FF
    sta ZP.CURSOR_FLASH

    // switch program into editor mode
    lda #MODE_MAIN_SUBMODE.SELECT_INPUT
    sta currentSubMode

    // draw the input field
    jsr userInterfaceDrawInput
    jsr userinterfaceAddInputFocus

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets the position of the cursor to the currently selected input,
 * after the last character of the contents of "currentInputEditorText".
 *
 * Parameters: ZPR_7: Address of the input struct
 *
 * Reads global variables:  currentInputEditorText
 * Writes global variables: none
 *
 * ---------------------------------------------------------------- */ 

inputEditorUpdateCursorPosition:
{
    // get length of text in "currentInputEditorText" and save it in ZPR_0
    loadPointerToZPR(currentInputEditorText, ZPR_1)
    jsr stringGetLength
    sta ZPR_0
    
	// load input top+1 into X register
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TOP)
    tax
    inx
	
    // load input left position, add 1 and then the string length, transfer the result into Y register
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.LEFT)
    clc
    adc #1
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
 * Handles the keyboard input while the program is in main mode,
 * submode input editor
 * 
 * Parameters: ZPR_7: Address of the input struct
 *
 * Reads global variables:  none
 * Writes global variables: none
 *
 * ---------------------------------------------------------------- */ 

inputHandleKeyboardInputForEditor:
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

    // check if pressed key is in the range of the number characters "0" (PETSCII 48) - "9" (PETSCII 57)
    // if any other character, exit
    cmp #$30
    bcc exit1
    cmp #$40
    bcs exit1
    jmp numberKeyPressed

exit1:
    rts

numberKeyPressed:    
    // pressed key corresponds to a number character, first save the keycode for later
    sta pressedKeyCode

    // determine the max. length (2 characters for 4-bit fields, 4 characters for the others)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TYPE)
    cmp #INPUT_TYPE.INTEGER_4_BITS
    beq isShortInputField
    lda #4
    jmp checkIfMaxLengthIsReached

isShortInputField:
    lda #2

checkIfMaxLengthIsReached:
    // save the max. length into ZPR_0
    sta ZPR_0
    
    // determine the length of the input editors current text
    loadPointerToZPR(currentInputEditorText, ZPR_1)
    jsr stringGetLength
    
    // compare the current length with the max. length, exit of max. length is reached
    cmp ZPR_0
    bcs exit

    // max. length not reached, append the pressed keycode to the editor`s text
    tay
    lda pressedKeyCode
    sta (ZPR_1), y
    iny
    lda #0
    sta (ZPR_1), y

    // update the screen and cursor position
    jsr inputEditorUpdateCursorPosition
    jsr userInterfaceDrawInputEditor

    rts

deleteKeyPressed:
    // load address of current text into ZPR_1
    loadPointerToZPR(currentInputEditorText, ZPR_1)
    
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
    jsr inputEditorUpdateCursorPosition
    jsr userInterfaceDrawInputEditor

    rts

returnKeyPressed:
    // convert string into (16-bit unsigned) integer
    lda #$30
    sta ZPR_0
    loadPointerToZPR(currentInputEditorText, ZPR_1)
    jsr convertStringToInteger
    
    // save the result of the conversion in the input-struct´s value
    lda ZPR_2_LO
    ldy #STRUCT_INPUT.VALUE
    sta (ZPR_7), y
    iny
    lda ZPR_2_HI
    sta (ZPR_7), y

    // set value to max. if neccessary
    jsr inputIntegerSanitizeValue
    
    // deactivate the editor
    jsr inputDeactivateEditor

    // update SID chip
    jsr inputCallSidUpdateSubroutine


exit:
    rts

pressedKeyCode:
    .byte(0)
}