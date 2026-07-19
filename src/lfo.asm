#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up CIA 1 Timer B to call our custom ISR 200x per second
 *
 * Reads global variables: detectedPALSystem
 *
 * ---------------------------------------------------------------- */ 
 
lfoSetupTimer:
{
    // in our case the shortest LFO cycle length is 1/100 second
    // or 100 hz. According to the Nyquist–Shannon sampling theorem
    // we need at least 200 samples per second to handle the 100 hz
    .const IRQ_FREQUENCY = 200

    // the CIA timer of the C64 counts in actual CPU cycles,
    // which are different for PAL and NTSC systems
    .const CLOCK_PAL  = 985248
    .const CLOCK_NTSC = 1022727

    // the CIA timer counts [value+1] CPU cycles until underflow, so we need to substract 1
    .const TIMERB_VAL_PAL  = round(CLOCK_PAL  / IRQ_FREQUENCY) - 1
    .const TIMERB_VAL_NTSC = round(CLOCK_NTSC / IRQ_FREQUENCY) - 1

    // supress interrupts
    sei

    // Disable all CIA1 IRQ sources and clear the pending flag
    lda #%01111111
    sta CIA1.INTERRUPT_CONTROL_STATE
    
    // Read confirms/clears pending IRQs
    lda CIA1.INTERRUPT_CONTROL_STATE

    // Pause Timer B during configuration
    lda #%00000000
    sta CIA1.CONTROL_B

    // Select PAL or NTSC timer value
    ldx detectedPALSystem
    bne palValue
    lda #<TIMERB_VAL_NTSC
    ldy #>TIMERB_VAL_NTSC
    jmp setValue

palValue:
    lda #<TIMERB_VAL_PAL
    ldy #>TIMERB_VAL_PAL

setValue:
    // set CIA1 Timer B value
    sta CIA1.TIMER_B_LO
    sty CIA1.TIMER_B_HI

    // Enable Timer A and Timer B as IRQ sources (Timer A was already set up by the kernel)
    lda #%10000011
    sta CIA1.INTERRUPT_CONTROL_STATE

    // Timer B starten: Start=1, Continuous(Bit3=0), Force-Load=1, Count Phi2
    lda #%00010001
    sta CIA1.CONTROL_B

    // enable interrupts again
    cli

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculate the next LFO value and modulate it with the current envelope value
 * of voice #3, if the option is selected.
 *
 * Reads global variables:  lfoModulateWithVoice3EnvelopeValue
 *
 * Writes global variables: lfoValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoCalculateValue:
{
    // calculate lfoValue
    jsr lfoCalculateOscillatorValue

    // check if the LFO should be modulated with the current envelope value of voice #3
    lda lfoModulateWithVoice3EnvelopeValue
    bne modulateWithEnvelope
    
    // no, so just exit
    rts

modulateWithEnvelope:
    // yes, multiply lfoValue by the envelope value of voice #3

    // because this subroutine will be called inside of an interrupt service routine,
    // save ZPR_0 on the stack because the multiply subroutine destroys it
    lda ZPR_0
    pha

    // multiply
    lda lfoValue
    ldx SID.ENVELOPE_VOICE_3
    jsr mathMultiply

    // save the high-byte of the result as the new value for lfoValue
    sta lfoValue

    pla
    sta ZPR_0

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculate the next LFO value
 *
 * Reads global variables: lfoModuloCounter, lfoModuloInc, lfoSquareWaveValue
 *
 * Writes global variables: lfoValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoCalculateOscillatorValue:
{
    // increment modulo counter
    clc
    lda lfoModuloCounter
    adc lfoModuloInc
    sta lfoModuloCounter
    lda lfoModuloCounter+1
    adc lfoModuloInc+1
    sta lfoModuloCounter+1

    // check if LFO waveform is set to square
    lda lfoSquareWaveValue
    bne calculateSquareWave

    // ----------------------------------------------
    // triangle wave
    // ----------------------------------------------

    // check bit 7, if set the value is >= 32768
    lda lfoModuloCounter+1
    bmi triangleModuloCounterIsGreaterOrEqual

    // load low byte, shift left, which shifts the MSB into the carry
    lda lfoModuloCounter
    asl
    
    // load high byte, rotate left, which shifts the MSB of the low byte into the first bit of the high byte
    lda lfoModuloCounter+1
    rol
    
    // save the value and exit
    sta lfoValue
    rts

triangleModuloCounterIsGreaterOrEqual:
    
    // tempLfoModuloCounter = 65535 - lfoModuloCounter
    sec
    lda #$ff
    sbc lfoModuloCounter+1
    sta tempLfoModuloCounter+1
    lda #$ff
    sbc lfoModuloCounter
    sta tempLfoModuloCounter

    // load low byte, shift left, which shifts the MSB into the carry
    lda tempLfoModuloCounter
    asl

    // load high byte, rotate left, which shifts the MSB of the low byte into the first bit of the high byte
    lda tempLfoModuloCounter+1
    rol

    // save the value and exit
    sta lfoValue
    rts

calculateSquareWave:

    // ----------------------------------------------
    // square wave
    // ----------------------------------------------

    // check bit 7, if set the value is >= 32768
    lda lfoModuloCounter+1
    bmi squareModuloCounterIsGreaterOrEqual
  
    // set value to 0 and exit
    lda #0
    sta lfoValue
    rts

squareModuloCounterIsGreaterOrEqual:
    
    // set value to 255 and exit
    lda #$ff
    sta lfoValue
    rts

tempLfoModuloCounter:
    .word(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Calculates the value for lfoModuloInc depending on lfoCycleLengthValue
 *
 * The formula for this is:
 * lfoModuloInc = round((1 / (lfoCycleLengthValue/ 100)) / 200 * 65535)
 *
 * But this formula can be simplified and boils to down to this:
 * lfoModuloInc = round(65535​ / (lfoCycleLengthValue * 2))
 *
 * Reads global variables: lfoCycleLengthValue
 *
 * Writes global variables: lfoModuloInc
 *
 * ---------------------------------------------------------------- */ 
 
lfoCalculateModuloInc:
{
    // check if lfoCycleLengthValue = 0
    lda lfoCycleLengthValue
    ora lfoCycleLengthValue+1
    beq cycleLengthIsNull

    // ZPR_1 = lfoCycleLengthValue * 2 (1 shift left)
    lda lfoCycleLengthValue
    asl
    sta ZPR_1_LO
    lda lfoCycleLengthValue+1
    rol
    sta ZPR_1_HI

    // ZPR_2 = 65535 (all bits set)
    lda #$ff
    sta ZPR_2_LO
    sta ZPR_2_HI

    // ZPR_2 = 65535 / (lfoCycleLengthValue * 2), ZPR_3 = remainder
    jsr mathDivide16Bit

    // check if round-up is necessary:
    // round up if ZPR_3 (remainder) >= lfoCycleLengthValue
    // (16 bit unsigned comparison, see https://6502.org/tutorials/compare_beyond.html)
    lda ZPR_3_HI          // compare high bytes
    cmp lfoCycleLengthValue+1
    bcc doNotRoundUp      // if ZPR_3_HI < lfoCycleLengthValue+1 then ZPR_3 < lfoCycleLengthValue
    bne roundUp           // if ZPR_3_HI <> lfoCycleLengthValue+1 then ZPR_3 > lfoCycleLengthValue (so ZPR_3 >= lfoCycleLengthValue)
    lda ZPR_3_LO          // compare low bytes
    cmp lfoCycleLengthValue
    bcc doNotRoundUp      // if ZPR_3_LO < lfoCycleLengthValue then ZPR_3 < lfoCycleLengthValue

roundUp:
    // round up needed -> increase by 1
    clc
    lda ZPR_2_LO
    adc #1
    sta ZPR_2_LO
    lda ZPR_2_HI
    adc #0
    sta ZPR_2_HI

doNotRoundUp:  
    // save the new modulo increment value
    // and reset the current modulo counter value
    // suppress IRQs during the process, to prevent garbage values
    sei
    lda ZPR_2_LO
    sta lfoModuloInc
    lda ZPR_2_HI
    sta lfoModuloInc+1
    lda #0
    sta lfoModuloCounter
    sta lfoModuloCounter+1
    cli
    rts

cycleLengthIsNull:
    // cycle length is null,
    // just set modulo increment and modulo counter values to zero
    sei
    lda #0
    sta lfoModuloInc
    sta lfoModuloInc+1
    sta lfoModuloCounter
    sta lfoModuloCounter+1
    cli
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Resets the oscillator if the following 3 conditions are true:
 * 1) the option is activated (lfoResetOscillatorValue > 0)
 * 2) the played note has changed generally
 * 3) before no note was played, now a note is played (gate should be opened)
 *
 * Reads global variables: lfoResetOscillatorValue, noteHasChangedFlag,
 *                         previousNote
 *
 * Writes global variables: lfoModuloCounter
 *
 * ---------------------------------------------------------------- */ 
 
lfoResetOscillatorIfNecessary:
{
    // check if reset osciallator is active
    lda lfoResetOscillatorValue
    beq exit

    // check if note changed
    lda noteHasChangedFlag
    beq exit

    // check if gate should be opened because no previous note was playes
    lda previousNote
    cmp #$ff
    bne exit

    // yes, all three tests were positive, reset the LFO
    sei
    lda #0
    sta lfoModuloCounter
    sta lfoModuloCounter+1
    sta lfoValue
    cli

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoSquareWave input into
 * lfoSquareWaveValue for faster/easier access
 *
 * Reads global variables:  lfoSquareWave
 *
 * Writes global variables: lfoSquareWaveValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoSquareWaveValue:
{
    // 
    loadPointerToZPR(lfoSquareWave, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    sta lfoSquareWaveValue
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoResetOscillator input into
 * lfoResetOscillatorValue for faster/easier access
 *
 * Reads global variables:  lfoResetOscillator
 *
 * Writes global variables: lfoResetOscillatorValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoResetOscillatorValue:
{
    loadPointerToZPR(lfoResetOscillator, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    sta lfoResetOscillatorValue
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoModulateWithVoice3Envelope input into
 * lfoModulateWithVoice3EnvelopeValue for faster/easier access
 *
 * Reads global variables:  lfoModulateWithVoice3Envelope
 *
 * Writes global variables: lfoModulateWithVoice3EnvelopeValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoModulateWithVoice3EnvelopeValue:
{
    loadPointerToZPR(lfoModulateWithVoice3Envelope, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    sta lfoModulateWithVoice3EnvelopeValue
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoCycleLength input into
 * lfoCycleLengthValue for faster/easier access
 *
 * Reads global variables:  lfoCycleLength
 *
 * Writes global variables: lfoCycleLengthValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoCycleLengthValue:
{
    loadPointerToZPR(lfoCycleLength, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx lfoCycleLengthValue
    sta lfoCycleLengthValue+1

    // re-calculate the value of lfoModuloInc
    jsr lfoCalculateModuloInc

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoModulatePitch input into
 * lfoModulatePitchValue for faster/easier access
 *
 * Reads global variables:  lfoModulatePitch
 *
 * Writes global variables: lfoModulatePitchValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoModulatePitchValue:
{
    loadPointerToZPR(lfoModulatePitch, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    sta lfoModulatePitchValue
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoPitch input into
 * lfoPitchValue for faster/easier access
 *
 * Reads global variables:  lfoPitch
 *
 * Writes global variables: lfoPitchValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoPitchValue:
{
    loadPointerToZPR(lfoPitch, ZPR_7)
    structLoadWordToXAccu(ZPR_7, STRUCT_INPUT.VALUE)
    stx lfoPitchValue
    sta lfoPitchValue+1
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Copies the current value of the lfoPitchNegative input into
 * lfoPitchNegativeValue for faster/easier access
 *
 * Reads global variables:  lfoPitch
 *
 * Writes global variables: lfoPitchValue
 *
 * ---------------------------------------------------------------- */ 
 
lfoUpdateLfoPitchNegativeValue:
{
    loadPointerToZPR(lfoPitchNegative, ZPR_7)
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.VALUE)
    sta lfoPitchNegativeValue
    rts
}