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
.label ZPR_0    = $02

// ZPR_1 and ZPR_2 are safe to use (unsed memory locations)
// and can be used for indirect-indexed addressing
.label ZPR_1    = $FB
.label ZPR_1_LO = $FB
.label ZPR_1_HI = $FC
.label ZPR_2    = $FD
.label ZPR_2_LO = $FD
.label ZPR_2_HI = $FE

// ZPR_3 through ZPR_7 are mostly safe to use
// (they are used by the KERNAL as registers for the floating point functions)
.label ZPR_3    = $61
.label ZPR_3_LO = $61
.label ZPR_3_HI = $62
.label ZPR_4    = $63
.label ZPR_4_LO = $63
.label ZPR_4_HI = $64
.label ZPR_5    = $65
.label ZPR_5_LO = $65
.label ZPR_5_HI = $66
.label ZPR_6    = $69
.label ZPR_6_LO = $69
.label ZPR_6_HI = $6A
.label ZPR_7    = $6B
.label ZPR_7_LO = $6B
.label ZPR_7_HI = $6C


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
