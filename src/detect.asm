#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 * 
 * Detects if the current system is either PAL or NTSC.
 *
 * Adapted from here: https://codebase64.pokefinder.org/doku.php?id=base:detect_pal_ntsc (TWW's variant)
 *
 * Original description on the website:
 *
 * "Count's number of cycles on one scan with CIA timer and uses the 2 LSBs from the high byte of
 *  the CIA Timer to determine model. This reliably detects PAL, NTSC, NTSC2 and DREAN.
 *  Routine exits with result in A. Make sure no interrupts occur during the runtime of the routine."
 * 
 * The value in the accumulator in the end means:
 *
 * 312 rasterlines -> 63 cycles per line PAL        => 312 * 63 = 19656 Cycles / VSYNC  => #>76  %00
 * 262 rasterlines -> 64 cycles per line NTSC V1    => 262 * 64 = 16768 Cycles / VSYNC  => #>65  %01
 * 263 rasterlines -> 65 cycles per line NTSC V2    => 263 * 65 = 17095 Cycles / VSYNC  => #>66  %10
 * 312 rasterlines -> 65 cycles per line PAL DREAN  => 312 * 65 = 20280 Cycles / VSYNC  => #>79  %11
 *
 * Writes global variables: detectedC64model, detectedPALSystem
 *
 * ---------------------------------------------------------------- */ 

detectC64Model: {
    // suppress interrupts
    sei

    // Use CIA #1 Timer B to count cycled in a frame
    lda #$ff
    sta $dc06
    sta $dc07  // Latch #$ffff to Timer B

    bit $d011
    bpl *-3    // Wait untill Raster > 256
    bit $d011
    bmi *-3    // Wait untill Raster = 0

    ldx #%00011001
    stx $dc0f  // Start Timer B (One shot mode (Timer stops automatically when underflow))

    bit $d011
    bpl *-3    // Wait untill Raster > 256
    bit $d011
    bmi *-3    // Wait untill Raster = 0

    sec
    sbc $dc07  // Hibyte number of cycles used
    and #%00000011

    sta detectedC64model
    
    // check if a PAL system
    cmp #%00
    beq setPALSystemDetected
    cmp #%11
    beq setPALSystemDetected

    // no, set detectedPALSystem to FALSE
    lda #0
    sta detectedPALSystem

    jmp exit

setPALSystemDetected:
    // yes, set detectedPALSystem to TRUE
    lda #1
    sta detectedPALSystem

exit:
    // allow interrupts again
    cli

    rts
}