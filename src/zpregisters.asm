#importonce

/* -------------------------------------------------------------------
 * Constants
 * ---------
 *
 * The following constants to zeropage addresses will be used
 * at various places in the program to pass parameters to
 * subroutines and for indirect-indexed addressing
 *
 * See https://www.c64-wiki.com/wiki/Zeropage for a list of all
 * zeropage addresses and their purposes
 *
 * ---------------------------------------------------------------- */ 

// ZPR_0 is safe to use, but is only a single-byte zeropage register,
// because the unused memory location at $02 is only one single byte
// so it can't be used for indirect-indexed addressing
.label ZPR_0     = $02

// ZPR_1 and ZPR_2 are safe to use (unsed memory locations)
// and can be used for indirect-indexed addressing
.label ZPR_1     = $FB
.label ZPR_1_LO  = $FB
.label ZPR_1_HI  = $FC
.label ZPR_2     = $FD
.label ZPR_2_LO  = $FD
.label ZPR_2_HI  = $FE

// ZPR_3 through ZPR_8 are mostly safe to use
// (they are used by the KERNAL as registers for the floating point functions)
.label ZPR_3     = $61
.label ZPR_3_LO  = $61
.label ZPR_3_HI  = $62
.label ZPR_4     = $63
.label ZPR_4_LO  = $63
.label ZPR_4_HI  = $64
.label ZPR_5     = $65
.label ZPR_5_LO  = $65
.label ZPR_5_HI  = $66
.label ZPR_6     = $69
.label ZPR_6_LO  = $69
.label ZPR_6_HI  = $6A
.label ZPR_7     = $6B
.label ZPR_7_LO  = $6B
.label ZPR_7_HI  = $6C
.label ZPR_8     = $6D
.label ZPR_8_LO  = $6D
.label ZPR_8_HI  = $6E

// because the addresses for the MIDI interface registers differ between the interfaces,
// we need to store the addresses and while beeing able to  access them in a convenient
// and computationally fast way.
// Therefor I decided to use zero page registers.
// $6F and $70 are used by the KERNAL as registers for the floating point functions,
// the others are unused.
.label ZPR_MIDI_CONTROL_REGISTER_ADDRESS    = $6F
.label ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO = $6F
.label ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI = $70
.label ZPR_MIDI_STATUS_REGISTER_ADDRESS     = $03
.label ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO  = $03
.label ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI  = $04
.label ZPR_MIDI_RECIEVE_REGISTER_ADDRESS    = $05
.label ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO = $05
.label ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI = $06


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Loads a pointer/16 bit memory address (e.g. defined by a label)
 * into the specified zeropage register
 *
 * Parameters:   pointer: 16 bit memory address
 *               ZPR:     address of zeropage register
 * 
 * ---------------------------------------------------------------- */ 

.macro loadPointerToZPR(pointer, ZPR) {
    lda #<pointer
    sta ZPR
    lda #>pointer
    sta ZPR+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pushes the specified 16-bit ZPR to the stack
 *
 * Parameters:   ZPR: address of zeropage register
 * 
 * ---------------------------------------------------------------- */ 

.macro pushZPR(ZPR) {
    lda ZPR+1
    pha
    lda ZPR
    pha
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Pulls the last 2 bytes from the stack and saves them in the specified ZPR
 *
 * Parameters:   ZPR: address of zeropage register
 * 
 * ---------------------------------------------------------------- */ 

.macro pullZPR(ZPR) {
    pla
    sta ZPR
    pla
    sta ZPR+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Copies the value of one 16-bit ZPR to another
 *
 * Parameters:   srcZPR: address of source zeropage register
 *               destZPR: address of source zeropage register
 * 
 * ---------------------------------------------------------------- */ 

.macro copyZPR(srcZPR, destZPR) {
    lda srcZPR
    sta destZPR
    lda srcZPR+1
    sta destZPR+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Adds an 8-bit value to an ZPR containing an 16-bit address
 *
 * Parameters:   ZPR: address of zeropage register
 *               byteValue: value to be added
 * 
 * ---------------------------------------------------------------- */ 

.macro addByteValueToZPRAddress(ZPR, byteValue) {
    clc
    lda ZPR
    adc #byteValue
    sta ZPR
    lda ZPR+1
    adc #$00
    sta ZPR+1
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Adds the first byte of an memory address to an ZPR containing an 16-bit address
 *
 * Parameters:   ZPR: address of zeropage register
 *               byteValue: value to be added
 * 
 * ---------------------------------------------------------------- */ 

.macro addByteAddressToZPRAddress(ZPR, byteAddress) {
    clc
    lda ZPR
    adc byteAddress
    sta ZPR
    lda ZPR+1
    adc #$00
    sta ZPR+1
}
