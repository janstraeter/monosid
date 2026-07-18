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

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 * 
 * Detects which (if any) MIDI cartridge is installed by trying out
 * their respective register addresses
 *
 * Sequential and Namesoft share the same addresses, and can not be
 * differentiated by this subroutine.
 *
 * Shamelessly stolen from here: https://github.com/MichaelTroelsen/SIDDetector-II
 *
 * Original description of the subroutine:
 * --------------------------------------------------------------------------------------------------
 * checkmidi: probe each documented C64 MIDI cart for a 6850 ACIA signature.
 * Reference: https://codebase.c64.org/doku.php?id=base:c64_midi_interfaces
 *
 * A 6850 ACIA after master reset (write $03 to its control register) returns
 *   status & $73 == $02   (TDRE=1, RDRF=0, no FE/OVRN/PE).
 * VICE's built-in MIDI emulation matches this.  CTS/DCD/IRQ (bits 2/3/7) are
 * masked off because they're modem-control inputs that vary by cart wiring.
 *
 * Probe order is first-hit-wins (per codebase reference + user constraint:
 * only ONE MIDI cartridge can be attached at a time):
 *   1) Sequential / Namesoft : ctrl $DE00, status $DE02
 *   2) DATEL / Siel / JMS    : ctrl $DE04, status $DE06
 *   3) Passport              : ctrl/status $DE08 (write=ctrl, read=status)
 *   4) Maplin                : ctrl/status $DF00 (write=ctrl, read=status)
 *
 * Sequential and Namesoft share the polled-read fingerprint (only IRQ vs
 * NMI line routing differs); both report as SEQUENTIAL.
 *
 * Two-read consistency check on each candidate filters open-bus jitter on
 * real hardware (no cart present → $DE/$DF reads are bus noise).
 *
 * Guards on the $DF00 (Maplin) probe — same set as checkfmyam since they
 * all contend for I/O2:
 *   - data4=$30        (SIDFX area, may also clobber SCI handshake)
 *   - is_u64 != 0      (Ultimate64 UCI at $DF1C-$DF1F)
 *   - skpico_fm >= 4   (SIDKick-pico OPL2 at $DF00)
 *   - armsid_map_h2 lo nibble = 3   (ARM2SID SFX- slot at $DF00)
 *
 * --------------------------------------------------------------------------------------------------
 *
 * Sets midiDetectedCartridge:
 *   0 = none, 1 = SEQ/Namesoft, 3 = DATEL, 4 = Passport, 5 = Maplin.
 *
 * Writes global variables: midiDetectedCartridge
 *
 * ---------------------------------------------------------------- */ 

detectMidiCartridgeByRegisterAddresses:
{
    lda #$00
    sta midiDetectedCartridge

    // 1) Sequential / Namesoft @ $DE00 / $DE02
    lda #$03
    sta $DE00              // master reset → ACIA control
    lda $DE02              // status read
    and #$73               // mask CTS/DCD/IRQ
    cmp #$02
    bne cmidi_n1
    lda $DE02              // 2nd read confirms it's not bus jitter
    and #$73
    cmp #$02
    bne cmidi_n1
    lda #MIDI_CARTRIDGE.SEQUENTIAL
    sta midiDetectedCartridge
    rts
cmidi_n1:
    // 2) DATEL / Siel / JMS @ $DE04 / $DE06
    lda #$03
    sta $DE04
    lda $DE06
    and #$73
    cmp #$02
    bne cmidi_n2
    lda $DE06
    and #$73
    cmp #$02
    bne cmidi_n2
    lda #MIDI_CARTRIDGE.DATEL_SIEL_JMS
    sta midiDetectedCartridge
    rts
cmidi_n2:
    // 3) Passport @ $DE08 (CR/SR share addr; read returns SR)
    lda #$03
    sta $DE08
    lda $DE08
    and #$73
    cmp #$02
    bne cmidi_n3
    lda $DE08
    and #$73
    cmp #$02
    bne cmidi_n3
    lda #MIDI_CARTRIDGE.PASSPORT
    sta midiDetectedCartridge
    rts
cmidi_n3:
    // 4) Maplin @ $DF00 — guarded against I/O2 owners
    /*

    // ------------------------------------------------
    // Commented out this part, because it uses 
    // variables from other parts of the SIDDetector-II
    // which I do not want to include here

    lda data4
    cmp #$30
    beq cmidi_done         // SIDFX
    lda is_u64
    bne cmidi_done         // U64 UCI
    lda skpico_fm
    cmp #$04
    bcs cmidi_done         // SKpico FM
    lda armsid_map_h2
    and #$0F
    cmp #$03
    beq cmidi_done         // ARM2SID SFX-
    
    // ------------------------------------------------

    */
    lda #$03
    sta $DF00
    lda $DF00
    and #$73
    cmp #$02
    bne cmidi_done
    lda $DF00
    and #$73
    cmp #$02
    bne cmidi_done
    lda #MIDI_CARTRIDGE.MAPLIN
    sta midiDetectedCartridge
cmidi_done:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 * 
 * Detects if the Sequantial or the Namesoft MIDI cartridge is active
 * Becuse these two cartridges use the exact same register addresses,
 * the only way to differentiate them is to set up test IRQ-
 * and NMI-routines and check which of the two get invoked.
 *
 * In case of a Squential cartridge the IRQ handler will be called,
 * for the Namesoft the NMI handler will be called.
 *
 * This routine should only be called when it is clear that a
 * Sequential or Namesoft cartridge ist installed.
 *
 * Writes global variables: midiDetectedCartridge
 *
 * ---------------------------------------------------------------- */ 

detectSequentialOrNamesoft:
{
    .const MIDI_CTRL    = $DE00     // Control register for Squential/Namesoft
    .const MIDI_RESET   = $03       // Master Reset
    .const MIDI_TXINT   = $35       // 8N1, /16, transmit interrupt enabled
    .const MIDI_ENABLE  = $15       // 8N1, /16, no interrupt enabled

    // suppress IRQ interrupts
    sei

    // initialize variables
    lda #0
    sta irqFired
    sta nmiFired

    // deactivate CIA1, so it can not mess up our code
    lda #$7F
    sta CIA1.INTERRUPT_CONTROL_STATE

    // clear CIA1 for good measure
    lda CIA1.INTERRUPT_CONTROL_STATE

    // set our test IRQ handler
    lda #<testIrqHandler
    sta IRQ_VECTOR_LO
    lda #>testIrqHandler
    sta IRQ_VECTOR_HI

    // set our test NMI handler
    lda #<testNmiHandler
    sta NMI_VECTOR_LO
    lda #>testNmiHandler
    sta NMI_VECTOR_HI

    // 6850 Master Reset
    lda #MIDI_RESET
    sta MIDI_CTRL

    // initialize MIDI cartridge,
    // activate transmitting interrupt
    lda #MIDI_TXINT
    sta MIDI_CTRL

    // activate IRQs, the only IRQ possible is the MIDI transmitting interrupt
    cli
    
    // wait a short period of time
    .for (var i = 0; i < 16; i++) { nop }
    
    // suppress IRQs again
    sei

    // deactivate the transmitting interrupt of the 6850
    lda #MIDI_ENABLE
    sta MIDI_CTRL

    // re-activate the CIA1 timer
    lda #$81
    sta CIA1.INTERRUPT_CONTROL_STATE

    // set the IRQ vector back to the original
    lda #<KERNAL.INTERRUPT_ROUTINE
    sta IRQ_VECTOR_LO
    lda #>KERNAL.INTERRUPT_ROUTINE
    sta IRQ_VECTOR_HI

    // allow interrupts again
    cli

    // check the results
    lda irqFired
    beq checkNmi
    lda #MIDI_CARTRIDGE.SEQUENTIAL
    sta midiDetectedCartridge
    rts

checkNmi:
    lda nmiFired
    beq unknown
    lda #MIDI_CARTRIDGE.NAMESOFT
    sta midiDetectedCartridge
    rts

unknown:
    rts

    // ------------------------------------------
    // Test IRQ handler
    // ------------------------------------------

testIrqHandler:
    lda #MIDI_ENABLE
    sta MIDI_CTRL
    lda #1
    sta irqFired
    pla
    tay
    pla
    tax
    pla
    rti

    // ------------------------------------------
    // Test NMI handler
    // ------------------------------------------
    
testNmiHandler:
    pha
    lda #MIDI_ENABLE
    sta MIDI_CTRL
    lda #1
    sta nmiFired
    pla
    rti

irqFired:
    .byte(0)

nmiFired:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 * 
 * Detects which (if any) MIDI cartridge is installed
 *
 * Writes global variables: midiDetectedCartridge
 *
 * ---------------------------------------------------------------- */ 

detectMidiCartridge:
{
    // first try to detect by register address
    jsr detectMidiCartridgeByRegisterAddresses
    
    // check for value of 1 (Sequential/Namesoft)
    lda midiDetectedCartridge
    cmp #1
    bne exit

    // yes, Sequential or Namesoft, now try to determine which one
    jsr detectSequentialOrNamesoft

exit:
    rts
}