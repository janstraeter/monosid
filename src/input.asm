#importonce

#import "constants.asm"
#import "zpregisters.asm"
#import "structs.asm"
#import "math.asm"
#import "convert.asm"
#import "globals.asm"


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
	rts

typeInteger4Bits:
	rts

typeInteger11Bits:
	rts

typeInteger12Bits:
	rts

typeBoolean:
    jsr inputBooleanToggle
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
	rts

typeBoolean:
    jsr inputBooleanToggle
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
	rts

typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
    jsr inputIntegerIncreaseValue
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
	rts

typeInteger4Bits:
typeInteger11Bits:
typeInteger12Bits:
    jsr inputIntegerDecreaseValue
	rts
}
