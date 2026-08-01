/* -----------------------------------------------------------------------------------------------------------------------
 * 
 * ░▒███████████████████████████████████████████████████████████████████▓▓█▓▒█▓▒▓░   ░▓▓▓▓▓▒      ▓▓▓▓▓░░▓▓▓▓▓▓▓▓▒         
 * ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▒▒▓░▓░  ░▓▓▓▓▓▓▓▓▓▓▓▒   ▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓░   
 * ████░░░▒█▓░░   ░░███░░░       ░░░███░░░░   ░████▓░░░██▒░░░      ░░░▒███▒░░   ░█████  ░█████▒  ▓████░░████████████████░ 
 * ████████████▒░██████████░   ▒███████████░  ░██████████████░   ░███████████░░░██████           █████░░████▓      ▓█████░
 * █████████████████████████ ░▒██████████████ ░███████████████░ ░██████████████░░███████▓        █████░░████▓       █████░
 * ████░   ░▓█████░   ░██████▒████▒░   ░██████░████▓░   ░█████░░█████░    ▓█████░ ░█████████▒    █████░░████▓       ██████
 * ████     ▓████░     ░█████▒████▒     ░█████░████▓     █████░░█████      █████░     ░███████▒  █████░░████▓       █████░
 * ████     ▓████░     ░█████▒████▒     ░█████░████▓     █████░░█████      █████░        ▒█████░ █████░░████▓      ▓█████░
 * ████     ▓████░     ░█████░▒█████░  ██████ ░████▓     █████░░░█████▓  ▓█████░░█████   ▒█████░ ▓████░░████▓  ▒████████░ 
 * ████     ▓████░     ░█████ ░▓████████████░ ░████▓     █████░ ░▒████████████░  ░▓▓▓▓▓▓▓▓▓▓▓▓░  ▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓░   
 * ████     ▓████░     ░█████   ░▒███████▒▒░  ░████▓     █████░   ░▒▓██████▓▒░      ░▓▓▓▓▓▓▒     ▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓░       
 * 
 * A litte MIDI capable mono-synth for the Commodore 64´s SID chip
 *
 * ---------------------------------------------------------------------------------------------------------------------- */ 


// *******************************************************************
.disk [filename="monosid.d64", name="MONOSID"] 
{
    [name="MONOSID", type="prg", segments="Start, MainProgram, SpriteData, Subroutines, Data, Patches"],
    [name="MONOSID-PATCHES", type="usr", noStartAddr, segments="PatchesFileData"]
}
// *******************************************************************


// *******************************************************************
.segment PatchesFileData []
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Load the binary data from the example patches file.
 * This segment is not part of the single PRG-file,
 * but the complete disk-image (the D64-file).
 *
 * ---------------------------------------------------------------- */ 

.var ptc = LoadBinary("patches/monosid-patches")
*=0 "PatchsFileData"
.fill ptc.getSize(), ptc.get(i)


// *******************************************************************
.file [name="monosid.prg", segments="Start, MainProgram, SpriteData, Subroutines, Data, Patches"]
// *******************************************************************


// *******************************************************************
.segment Start [start=$801, modify="BasicUpstart", _start=mainProgram]
// *******************************************************************


// *******************************************************************
.segment Data [startAfter="Subroutines"]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Constants, ZP registers, memory functions and structs
 *
 * ---------------------------------------------------------------- */ 

#import "src/constants.asm"
#import "src/zpregisters.asm"
#import "src/screenmemoryfunctions.asm"
#import "src/structs.asm"

/* -------------------------------------------------------------------
 *
 * Strings and global variables
 *
 * ---------------------------------------------------------------- */ 

#import "src/strings.asm"
#import "src/lookuptables.asm"
#import "src/globals.asm"


// *******************************************************************
.segment Patches [startAfter="Data"]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Patch data - a pointer to a buffer - it needs to be at the end
 * of the program so it can use a couple of kilobytes which
 * do not interfere with the rest of the program.
 *
 * ---------------------------------------------------------------- */ 

patches:
    .byte(0)


// *******************************************************************
.segment SpriteData [startAfter="MainProgram"]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Sprite data (currently only the logo)
 *
 * ---------------------------------------------------------------- */ 

#import "src/spritedata.asm"


// *******************************************************************
.segment Subroutines [startAfter="SpriteData"]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Subroutines
 *
 * ---------------------------------------------------------------- */ 

#import "src/convert.asm"
// #import "src/debug.asm" // <- comment in again, when needed
#import "src/detect.asm"
#import "src/file.asm"
#import "src/filter.asm"
#import "src/input.asm"
#import "src/logo.asm"
#import "src/lfo.asm"
#import "src/math.asm"
#import "src/menu.asm"
#import "src/midi.asm"
#import "src/patches.asm"
#import "src/patchselector.asm"
#import "src/pitch.asm"
#import "src/pulsewidth.asm"
#import "src/screen.asm"
#import "src/sid.asm"
#import "src/sprites.asm"
#import "src/string.asm"
#import "src/userinterface.asm"


// *******************************************************************
.segment MainProgram [start=$80e]
// *******************************************************************

/* -------------------------------------------------------------------
 *
 * Main program
 *
 * ---------------------------------------------------------------- */ 

mainProgram:
{
    // ------------------------------------------------
    // Initialization
    // ------------------------------------------------

    // save the current device number for later use
    jsr fileSaveDiskDriveDeviceNumber

    // detect if PAL or NTSC
    jsr detectC64Model

    // detect MIDI cartridge
    jsr detectMidiCartridge

    // let all keys repeat
    lda $80
    sta REPEAT_FLAG

    // Setup logo sprites, but do not show yet
    jsr logoSetupSprites

    // Setup patches
    jsr patchesInit
    
    // switch to the first patch, automatically intializes the SID chip
    lda #0
    jsr patchesSwitchToPatch

    // start in the main mode, submode input select
    jsr switchToModeMain

    // initialize a custom ISR for the Kernal functionality
    jsr setupCustomInterruptServiceRoutine
    jsr lfoSetupTimer

    // initialize the MIDI interface (if any is present)
    jsr midiInit
    jsr lfoCalculateModuloInc
    
    // ------------------------------------------------
    // Begin main loop
    // ------------------------------------------------

mainLoop:
    // check if the CIA interrupt called our custom ISR,
    // if so, call the emulation of the default Kernal ISR
    // so the Kernal routines can work properly
    lda callEmulationOfKernalISR
    cmp #0
    beq doNotCallEmulationOfKernalISR
    lda #0
    sta callEmulationOfKernalISR
    jsr emulateStandardKernalISR

doNotCallEmulationOfKernalISR:
    // read the current pressed key and save it in a global variable
    lda ZP.CURRENT_PRESSED_KEY
    sta currentPressedKey

    // process all MIDI bytes currently in the ring buffer
    jsr midiProcessBuffer

    // check if the last note was played not by MIDI but the C64 keyboard
    // instead. If so ignore the MIDI notes in this loop iteration
    lda currentNoteWasPlayedByKeyboardFlag
    bne ignoreMidiNote
    
    // update the current note according to the currently active MIDI notes
    jsr midiUpdateCurrentNote

ignoreMidiNote:
    // Update the SID chip
    jsr updateVoiceFrequenciesIfNecessary
    jsr pulseWidthUpdateModulatedValuesIfNeccessary
    jsr filterUpdateModulatedCutoffValueIfNeccessary
    jsr playCurrentNote

	// Switch for the current program mode
	lda currentMode
	cmp #MODE.MAIN
	beq modeMain
	cmp #MODE.MENU
	beq modeMenu
	cmp #MODE.PATCH_SELECTOR
	beq modePatchSelector
    jmp mainLoop

modeMain:
	// Switch for the main sub mode
	lda currentSubMode
	cmp #MODE_MAIN_SUBMODE.SELECT_INPUT
	beq subModeMainSelectInput
	cmp #MODE_MAIN_SUBMODE.INPUT_EDITOR
	beq subModeMainInputEditor
    jmp mainLoop

subModeMainSelectInput:
    // check for pressed keys,
    // play notes or move the focus of the currently selected module/input
    jsr updateCurrentKeyboardPianoOctave
    jsr updateCurrentKeyboardNote
    jsr mainModeHandleKeyboardInputForSubModeSelectInput
    jmp mainLoop

subModeMainInputEditor:
    // check for pressed keys, update content of editor,
    // remove editor and update value if return key pressed
    jsr inputHandleKeyboardInputForEditor
    jmp mainLoop

modeMenu:
	// Switch for the menu submode
	lda currentSubMode
	cmp #MODE_MENU_SUBMODE.SELECT_ITEM
	beq subModeMenuSelectItem
	cmp #MODE_MENU_SUBMODE.SHOW_ERROR_MESSAGE
	beq subModeMenuShowErrorMessage
    cmp #MODE_MENU_SUBMODE.RENAME_PATCH
    beq subModeMenuRenamePatch
    cmp #MODE_MENU_SUBMODE.SET_MIDI_CHANNEL
    beq subModeMenuSetMidiChannel
    jmp mainLoop

subModeMenuSelectItem:
    // handle the keyboard input for the main menu
    jsr menuHandleKeyboardInput
    jmp mainLoop

subModeMenuShowErrorMessage:
    // wait for any key pressed after a disk error happend 
    jsr KERNAL.GETIN
    cmp #$00
    bne *+5
    jmp mainLoop
    jsr switchToModeMenu
    jmp mainLoop

subModeMenuRenamePatch:
subModeMenuSetMidiChannel:
    // handle the keyboard input for the main menu input editor
    jsr menuHandleKeyboardInputForEditor
    jmp mainLoop

modePatchSelector:
    // handle the keyboard input for the patch selector
    jsr patchSelectorHandleKeyboardInput
    jmp mainLoop
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Switches the program mode to the main mode, submode input selection
 * Clears the screen and draws the main UI
 *
 * Writes global variables: currentMode,
 *                          currentSubMode
 *
 * ---------------------------------------------------------------- */ 

switchToModeMain:
{
    lda #MODE.MAIN
    sta currentMode
    lda #MODE_MAIN_SUBMODE.SELECT_INPUT
    sta currentSubMode
    jsr logoHide
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Switches the program mode to the menu mode, submode item selection
 * Clears the screen and draws the menu UI
 *
 * Writes global variables: currentMode,
 *                          currentSubMode
 *
 * ---------------------------------------------------------------- */ 

switchToModeMenu:
{
    lda #MODE.MENU
    sta currentMode
    lda #MODE_MENU_SUBMODE.SELECT_ITEM
    sta currentSubMode
    lda #0
    sta currentMenuIndex
    jsr logoShow
    jsr menuDrawMain
    jsr menuAddItemFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Switches the program mode to the patch selector mode
 * Draws the patch selector UI
 *
 * Writes global variables: currentMode,
 *                          currentSubMode
 *
 * ---------------------------------------------------------------- */ 

switchToModePatchSelector:
{
    lda #MODE.PATCH_SELECTOR
    sta currentMode
    lda #MODE_PATCH_SELECTOR_SUBMODE.SELECT_PATCH
    sta currentSubMode
    jsr logoHide
    jsr patchSelectorDrawMain
    lda currentPatchIndex
    sta currentPatchSelectorIndex
    jsr patchSelectorCalculateCurrentColumnAndRowFromIndex
    jsr patchSelectorAddFocus
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up the custom ISR. Because the C64 is so slow, we need
 * a very, very fast interrupt routine. Almost everything must be
 * done in the main loop.
 *
 * Reading the MIDI input (if a MIDI cartridge is installed) and
 * calculating the next value of the LFO have to be done via interrupt,
 * there is no way around it.
 *
 * But everything else needs to be handled in the main loop, otherwise
 * we would probably lose MIDI bytes.
 *
 * We need to know when it is time to update the jiffy clock,
 * cursor blinking etc. The standard Kernal stuff.
 *
 * Therefore we setup a custom ISR - this ISR is called 60 times per second,
 * as setup by the Kernal. The ISR only indicates to the
 * main loop, that the standrd Kernal stuff is due - but does not do the
 * actual updating in the ISR itself.
 *
 * For the LFO we set up a second timer (CIA1 Timer B), which calles
 * this ISR 200x per second. 
 *
 * ---------------------------------------------------------------- */ 

setupCustomInterruptServiceRoutine:
{
    // if an interrup would occur while we are not finished
    // changing the vector (4 instructions)
    // the computer would freeze, not likely but possible
    sei

    // set the interrupt vector to our custom ISR
    lda #<customInterruptServiceRoutine
    sta IRQ_VECTOR_LO
    lda #>customInterruptServiceRoutine
    sta IRQ_VECTOR_HI

    // now interrupts are allowed again
    cli

    rts
}


/* -------------------------------------------------------------------
 * Interrupt Service Routine
 * -------------------------
 *
 * The actual ISR, for explaination see above.
 *
 * This ISR will be called by CIA1 Timer A and B underflow
 *
 * ---------------------------------------------------------------- */ 

customInterruptServiceRoutine:
{
    // acknowledge the interrupt
    lda CIA1.INTERRUPT_CONTROL_STATE

    // save the value, because the value of the register will change with every read
    sta interruptSource

    // check if timer A -> Kernal ISR
    and #%00000001          // Bit 0 = Timer A underflow
    beq checkTimerB

    // set the variable to 1, to indicate the main loop
    // to call the Kernal ISR emulation
    lda #1
    sta callEmulationOfKernalISR
    jmp exit

checkTimerB:
    // check Timer B -> LFO timer
    lda interruptSource
    and #%00000010          // Bit 1 = Timer B underflow
    beq exit

    // is Timer B underflow, so calculate next value of the LFO
    jsr lfoCalculateValue

exit:
    // restore the registers from the stack and return
    pla
    tay
    pla
    tax
    pla
    rti

interruptSource:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * This routine is an adaption of the disassembly of the
 * original ISR of the C64 Kernal.
 *
 * See: http://www.unusedino.de/ec64/technical/misc/c64/romlisting.html#kernal
 *
 * It is called from the main loop, whenever the custom ISR indicates
 * that it is time (60 times per second).
 *
 * It returns via RTS, not RTI as in the original, of course.
 *
 * ---------------------------------------------------------------- */ 

emulateStandardKernalISR:
{
    jsr $FFEA           // do clock
    lda $CC             // flash cursor
    bne Kernal_EA61
    dec $CD
    bne Kernal_EA61
    lda #$14
    sta $CD
    ldy $D3
    lsr $CF
    ldx $0287
    lda ($D1),Y
    bcs Kernal_EA5C
    inc $CF
    sta $CE
    jsr $EA24
    lda ($F3),Y
    sta $0287
    ldx $0286
    lda $CE
Kernal_EA5C:
    eor #$80
    jsr $EA1C           // display cursor
Kernal_EA61:
    lda $01             // checl cassette sense
    and #$10
    beq Kernal_EA71
    ldy #$00
    sty $C0
    lda $01
    ora #$20
    bne Kernal_EA79
Kernal_EA71:
    lda $C0
    bne Kernal_EA7B
    lda $01
    and #$1F
Kernal_EA79:    
    sta $01
Kernal_EA7B:
    jsr $EA87           // scan keyboard

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the current pressed key is one of the keys 1-8.
 * If it is, sets the current keyboard piano octave accordingly.
 *
 * Reads global variables:  currentPressedKey, keyboardPianoOctaveKeyCodes,
 *                          keyboardPianoOctaveOffsets
 *
 * Writes global variables: currentKeyboardPianoOctave,
 *                          currentKeyboardPianoNoteOffset
 *
 * ---------------------------------------------------------------- */ 

updateCurrentKeyboardPianoOctave:
{
    // if the shift-key is pressed, exit
    lda KERNAL.SHFLAG
    bne notFound

    // check if there is anay currently pressed key
    lda currentPressedKey
    cmp #64
    beq notFound

    // yes, a key is pressed so check if it is 1-8
    loadPointerToZPR(keyboardPianoOctaveKeyCodes, ZPR_1)
    ldy #$00

arrayLoop:
    lda (ZPR_1), y
    cmp currentPressedKey
    beq found
    iny
    cpy #$08
    bne arrayLoop
    jmp notFound

found:
    // pressed key was found, set the keyboard piano octave to the new value
    sty currentKeyboardPianoOctave
    loadPointerToZPR(keyboardPianoOctaveOffsets, ZPR_1)
    lda (ZPR_1), y
    sta currentKeyboardPianoNoteOffset

    jsr userInterfaceOutputInfoBarCurrentKeyboardPianoOctave

notFound:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Interprets the currently pressed key as a note
 *
 * Reads global variables:  keyboardPianoKeyCodes, currentPressedKey,
 *                          keyboardPianoKeyCodes, currentKeyboardPianoNoteOffset,
 *                          maxFreqTableNum
 *
 * Writes global variables: currentNote, noteChange, currentNoteOfOctave
 *
 * ---------------------------------------------------------------- */ 

updateCurrentKeyboardNote:
{
    // if the shift-key is pressed, exit
    lda KERNAL.SHFLAG
    bne notFound

    // load the current pressed key and check if the value is not 64 (which means no key pressed)
    lda currentPressedKey
    cmp #64
    beq notFound

    // load the pointer to the key codes which are used as a piano octave
    loadPointerToZPR(keyboardPianoKeyCodes, ZPR_1)
    ldy #$00

arrayLoop:
    // check if current array item corresponds to the value of the pressed key
    // if yes, jump to to the found label
    lda (ZPR_1), y
    cmp currentPressedKey
    beq found
    
    // goto next key code in array,
    iny

    // Check if last item in array is reached.
    // If no, loop again. If yes, jump to not found label
    cpy #$0D
    bne arrayLoop
    jmp notFound

found:
    // store the index of the found key code in tempCurrentNote
    sty tempCurrentNote
    
    // add the value in currentKeyboardPianoNoteOffset to tempCurrentNote
    tya
    clc
    adc currentKeyboardPianoNoteOffset
    sta tempCurrentNote

    // check if resulting note value is greater than highest playable note
    cmp #$60
    bcs notFound

    // set the flag to indicate the main loop that the note was
    // played on the C64 keyboard and should override any note from MIDI
    lda #1
    sta currentNoteWasPlayedByKeyboardFlag

    // now check if note as changed
    jmp checkForNoteChange

notFound:
    
    // check if the last note was played by the C64 keyboard
    // if no, then ignore the fact that no note was found.
    // Otherwise we would falsly assume that the currently played note should be ended
    lda currentNoteWasPlayedByKeyboardFlag
    cmp #0
    beq noteHasNotChanged

    // reset the flag, the C64 keyboard now does not play a note anymore
    lda #0
    sta currentNoteWasPlayedByKeyboardFlag

    // note was not found, so save 255 into tempCurrentNote
    lda #$FF
    sta tempCurrentNote

checkForNoteChange:
    // load current note and compare it with the new note
    lda currentNote
    cmp tempCurrentNote
    beq noteHasNotChanged

    // note has changed, store the new note as the current
    // (and last played) and the current as the previous
    lda currentNote
    sta previousNote
    lda tempCurrentNote
    sta currentNote

    // the keyboard has obviously no velocity value, so assume full volume for the note
    ldx #15
    stx currentNoteVolume

    // update lastPlayedNote, but only if there is an actual note to play
    cmp #$FF
    beq doNotUpdateLastPlayedNote
    sta lastPlayedNote

doNotUpdateLastPlayedNote:
    // set the flag to indicate that the note has changed
    lda #$01
    sta noteHasChangedFlag
    rts

noteHasNotChanged:
    rts

    // Local variables
    tempCurrentNote: .byte($ff)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the voice frequencies need to be calculated and
 * the frequency registers of the SID chip have to be updated.
 *
 * Reads global variables:  currentNote, noteHasChangedFlag,
 *                          midiPitchBendValueChangedFlag

 * Writes global variables: midiPitchBendValueChangedFlag
 *
 * ---------------------------------------------------------------- */ 

updateVoiceFrequenciesIfNecessary:
{
    // first check if the pitch bend wheel was moved,
    // if yes, update frequencies and set the pitch bend value change flag to zero
    lda midiPitchBendValueChangedFlag
    bne pitchBendValueHasChanged

    // check if the LFO modulates the pitch,
    // if so then the frequencies must be updated
    lda lfoModulatePitchValue
    bne updateFrequencies

    // if the pitch bend wheel was not moved check if the currently played note has changed
    // and the new note is a playable note (and not 255 indicating "no note")
    // if either of this checks is false, note frequency update is neccessary
    lda noteHasChangedFlag
    beq frequenciesHaveNotChanged
    lda currentNote
    cmp #$FF
    beq frequenciesHaveNotChanged

    // note has changed, update the voice frequencies
    jmp updateFrequencies

pitchBendValueHasChanged:
    // set the MIDI pitch bend value has changed flag to zero again
    lda #0
    sta midiPitchBendValueChangedFlag

updateFrequencies:
    // calculate the (possibly detuned) frequencies for all voices and update the SID chip
    jsr pitchCalculateGlobalDetuning
    jsr pitchCalculateAllVoiceFrequencies
    jsr sidUpdateVoiceFrequencies

frequenciesHaveNotChanged:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Plays the current note via the SID chip
 *
 * Reads global variables:  currentNote, noteHasChangedFlag
 * Writes global variables: noteHasChangedFlag
 *
 * ---------------------------------------------------------------- */ 

playCurrentNote:
{
    // ceck if new note to play, if no -> exit
    lda noteHasChangedFlag
    beq exit

    // reset the LFO if necessary
    jsr lfoResetOscillatorIfNecessary

    // update the gate bits
    jsr sidUpdateGateBitsForAllVoices

    // clear the note has changed flag
    lda #0
    sta noteHasChangedFlag

    // check if MIDI note velocity should be used
    lda currentVelocityUse
    beq exit

    // yes, so update main volume or the sustain volumes for the voices
    jsr sidUpdateFilterModeMainVolumeRegisterWithVelocity
    jsr sidUpdateVoice1SustainRelease
    jsr sidUpdateVoice2SustainRelease
    jsr sidUpdateVoice3SustainRelease

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Clears the MIDI buffer and stops playing any note.
 *
 * Writes global variables: midiActiveNotesNum, midiWritePtr, midiReadPtr,
 *                          currentNoteWasPlayedByKeyboardFlag, previousNote,
 *                          lastPlayedNote, noteHasChangedFlag, currentNote
 *
 * ---------------------------------------------------------------- */ 

stopAnyNote:
{
    // clear MIDI buffer
    sei
    lda #0
    sta midiActiveNotesNum
    sta midiWritePtr
    sta midiReadPtr
    jsr midiProcessBuffer
    cli

    // simulate a note change from #0 to #255 (no note to play)
    lda #0
    sta currentNoteWasPlayedByKeyboardFlag
    sta previousNote
    sta lastPlayedNote
    lda #1
    sta noteHasChangedFlag
    lda #255
    sta currentNote

    // update the gate bits of the SID chip, which in this case will stop any note
    jsr sidUpdateGateBitsForAllVoices

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the keyboard input while the program is in main mode,
 * submode select input.
 * 
 * Checks if the currently selected module/input element
 * should be updated and if so updates the corresponding global
 * variables accordingly, then updates the user interface.
 *
 * Reads global variables:  currentModuleIndex, currentInputIndex,
 *                          modules, moduleNum
 *
 * Writes global variables: currentModuleIndex, currentInputIndex
 *
 * ---------------------------------------------------------------- */ 

mainModeHandleKeyboardInputForSubModeSelectInput:
{
    // Read pressed keycode, if no key pressed, exit
    jsr KERNAL.GETIN
    cmp #$00
    bne switchKey
    rts

switchKey:

	// ----------------------------------------------------------------------------
    // Switch for the handled keys.
    // Because the subroutine is rather long, use a little trick to avoid the
    // problems with branching instructions on the 6502, which only can jump -127/+127 bytes.
    // see here: https://www.lemon64.com/forum/viewtopic.php?t=81358
	// ----------------------------------------------------------------------------
    
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
    jmp returnKeyPressed
	cmp #PETSCII.SPACE
	bne *+5
    jmp spaceKeyPressed
	
    // +/-
    cmp #PETSCII.PLUS
	bne *+5
    jmp plusKeyPressed
	cmp #PETSCII.MINUS
	bne *+5
    jmp minusKeyPressed

    // F1
    cmp #PETSCII.F1
	bne *+5
    jmp f1KeyPressed

    // F3
    cmp #PETSCII.F3
	bne *+5
    jmp f3KeyPressed

    // F5
    cmp #PETSCII.F5
	bne *+5
    jmp f5KeyPressed

    // F7
    cmp #PETSCII.F7
	bne *+5
    jmp f7KeyPressed

    // shift+1
    cmp #PETSCII.SHIFT_1
   	bne *+5
    jmp shift1KeyPressed

    // shift+2
    cmp #PETSCII.SHIFT_2
   	bne *+5
    jmp shift2KeyPressed

    // shift+3
    cmp #PETSCII.SHIFT_3
   	bne *+5
    jmp shift3KeyPressed

    // shift+F
    cmp #PETSCII.SHIFT_F
   	bne *+5
    jmp shiftFKeyPressed

    // shift+M
    cmp #PETSCII.SHIFT_M
   	bne *+5
    jmp shiftMKeyPressed

    // shift+D
    cmp #PETSCII.SHIFT_D
   	bne *+5
    jmp shiftDKeyPressed

    // shift+R
    cmp #PETSCII.SHIFT_R
   	bne *+5
    jmp shiftRKeyPressed

    // shift+V
    cmp #PETSCII.SHIFT_V
   	bne *+5
    jmp shiftVKeyPressed

    // shift+L
    cmp #PETSCII.SHIFT_L
   	bne *+5
    jmp shiftLKeyPressed

    // arrow left
    cmp #PETSCII.ARROW_LEFT
    bne *+5
    jmp arrowLeftKeyPressed

    // If no key pressed we can handle here, exit
exit:
    rts

cursorDownKeyPressed:
    // cursor down, load IID of bottom neighbor into accu and update screen
    jsr inputLoadAddressOfCurrentInputToZPR7
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.BOTTOM_NEIGHBOR_IID)
    jmp cursorKeyPressedFinalize

cursorRightKeyPressed:
    // cursor right, load IID of right neighbor into accu and update screen
    jsr inputLoadAddressOfCurrentInputToZPR7
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.RIGHT_NEIGHBOR_IID)
    jmp cursorKeyPressedFinalize

cursorUpKeyPressed:
    // cursor up, load IID of top neighbor into accu and update screen
    jsr inputLoadAddressOfCurrentInputToZPR7
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.TOP_NEIGHBOR_IID)
    jmp cursorKeyPressedFinalize

cursorLeftKeyPressed:
    // cursor left, load IID of left neighbor into accu and update screen
    jsr inputLoadAddressOfCurrentInputToZPR7
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.LEFT_NEIGHBOR_IID)
    jmp cursorKeyPressedFinalize

cursorKeyPressedFinalize:
    // save the IID from accu in variable
    sta iidOfNextSelectedInput
    
    // save current page, module and input indecies
    lda currentPage
    sta previousPage
    lda currentModuleIndex
    sta previousModuleIndex
    lda currentInputIndex
    sta previousInputIndex

    // update current page, module and input indecies to the new values,
    // according to the newly selected input element
    lda iidOfNextSelectedInput
    jsr selectInputAfterCursorKeyPress

    // check if page swap neccessary
    lda currentPage
    cmp previousPage
    beq noPageSwap

    // swap the page
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain

    // after the redrawing of the whole screen, add the focus
    jsr userinterfaceAddModuleFocus
    jsr userinterfaceAddInputFocus
    rts

noPageSwap:
    // no page swap
    // check if the module index has changed
    lda previousModuleIndex
    cmp currentModuleIndex
    beq noModuleIndexChange

    // yes, module focus needs to chang to the newly selected module
    jsr userinterfaceRemoveModuleFocus
    jsr userinterfaceAddModuleFocus

noModuleIndexChange:
    // update the focus to the newly selected input
    lda previousInputIndex
    ldx previousModuleIndex
    jsr userinterfaceRemoveInputFocus
    jsr userinterfaceAddInputFocus

    // screen updated, return
    rts

returnKeyPressed:
    // for number input fields: start the editor mode
    // for waveform inputs: switch to next waveform
    // for boolean inputs: toggle
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleReturnKeyPressed
    rts

spaceKeyPressed:
    // for waveform inputs: switch to next waveform
    // for boolean inputs: toggle
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleSpaceKeyPressed
    rts

plusKeyPressed:
    // for number input fields: increase value by 1 (if max value is not reached)
    // for waveform inputs: switch to next waveform
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandlePlusKeyPressed
    rts

minusKeyPressed:
    // for number input fields: decrease value by 1 (if greater than zero)
    // for waveform inputs: switch to previous waveform
    jsr inputLoadAddressOfCurrentInputToZPR7
    jsr inputHandleMinusKeyPressed
    rts

f1KeyPressed:
    // show the main menu
    jsr switchToModeMenu
    rts

f3KeyPressed:
    // show the patch selector
    jsr switchToModePatchSelector
    rts

f5KeyPressed:
    // select first input of first module of page 1
    lda #IID.V1_WAVE
    jmp cursorKeyPressedFinalize

f7KeyPressed:
    // select first input of first module of page 2
    lda #IID.DETUNING_V1
    jmp cursorKeyPressedFinalize

shift1KeyPressed:
    // select first input of module Voice 1
    lda #IID.V1_WAVE
    jmp cursorKeyPressedFinalize

shift2KeyPressed:
    // select first input of module Voice 2
    lda #IID.V2_WAVE
    jmp cursorKeyPressedFinalize

shift3KeyPressed:
    // select first input of module Voice 3
    lda #IID.V3_WAVE
    jmp cursorKeyPressedFinalize

shiftFKeyPressed:
    // select first input of module Filter
    lda #IID.FILTER_CUTOFF
    jmp cursorKeyPressedFinalize

shiftMKeyPressed:
    // select first input of module Main
    lda #IID.MAIN_VOL
    jmp cursorKeyPressedFinalize

shiftDKeyPressed:
    // select first input of module Detuning
    lda #IID.DETUNING_V1
    jmp cursorKeyPressedFinalize

shiftRKeyPressed:
    // select first input of module Reset Oscillators
    lda #IID.RESOSC_V1
    jmp cursorKeyPressedFinalize

shiftVKeyPressed:
    // select first input of module Velocity
    lda #IID.VELOCITY_USE
    jmp cursorKeyPressedFinalize

shiftLKeyPressed:
    // select first input of module LFO
    lda #IID.LFO_CYCLE_LENGTH
    jmp cursorKeyPressedFinalize

arrowLeftKeyPressed:
    // stop any note (panic button)
    jsr stopAnyNote
    rts
    
iidOfNextSelectedInput:
	.byte(0)
previousPage:
    .byte(0)
previousModuleIndex:
    .byte(0)
previousInputIndex:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates currentPage, currentModuleIndex and currentInputIndex accordingly to
 * the selected input element with the IID provided as parameter in the accu.
 * 
 * Parameter:               accu - IID of the selected input element
 *
 * Reads global variables:  modules, moduleNum
 *
 * Writes global variables: currentPage, currentModuleIndex, currentInputIndex
 *
 * ---------------------------------------------------------------- */ 

selectInputAfterCursorKeyPress:
{
    // the IID to find comes as a parameter in the accu, save it into searchIID
    sta searchIID

	// load address of module array into ZPR_4
    loadPointerToZPR(modules, ZPR_4)
    
    // initialize moduleIndex with zero
    lda #0
    sta moduleIndex

moduleLoop:
    // once for each module
    // load address of modules[moduleIndex] into ZPR_5
    stuctLoadPointerArrayItemToZPR(ZPR_4, moduleIndex, ZPR_5)
    
    // store number of inputs of modules[moduleIndex] in inputArrayNum
    structLoadByteToAccu(ZPR_5, STRUCT_MODULE.INPUT_ARRAY_NUM)
    sta inputArrayNum

    // store the page number of modules[moduleIndex] in page
    structLoadByteToAccu(ZPR_5, STRUCT_MODULE.PAGE)
    sta page

    // load the address of the input array of modules[moduleIndex] into ZPR_6
    structLoadWordToAddress(ZPR_5, STRUCT_MODULE.INPUT_ARRAY, ZPR_6)

    // initialize inputIndex with zero
    lda #0
    sta inputIndex

inputLoop:
    // once for each input - modules[moduleIndex][inputIndex]
    // load the address of modules[moduleIndex][inputIndex] into ZPR_7
    stuctLoadPointerArrayItemToZPR(ZPR_6, inputIndex, ZPR_7)
    
    // load the IID (unique input ID) of modules[moduleIndex][inputIndex] into the accu
    structLoadByteToAccu(ZPR_7, STRUCT_INPUT.IID)

    // compare the IID of modules[moduleIndex][inputIndex] with the value in searchIID
    cmp searchIID
    beq foundIID

    // IID not found yet - increase inputIndex, check for end of input array
    // if inputIndex != inputArrayNum goto inputLoop
    inc inputIndex
    lda inputArrayNum
    cmp inputIndex
    bne inputLoop

    // inputIndex == inputArrayNum, so increase moduleIndex, check for end of module array
    // if moduleIndex != modulesNum goto moduleLoop
    inc moduleIndex
    lda modulesNum
    cmp moduleIndex
    bne moduleLoop

    // this should never be reached - but only to be sure...
    lda #0
    sta currentPage
    sta currentModuleIndex
    sta currentInputIndex
    rts

foundIID:
    // save the indecies of the current module and input and return
    lda page
    sta currentPage
    lda moduleIndex
    sta currentModuleIndex
    lda inputIndex
    sta currentInputIndex
    rts

searchIID:
    .byte(0)
page:
    .byte(0)
moduleIndex:
    .byte(0)
inputIndex:
    .byte(0)
inputArrayNum:
    .byte(0)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Checks if the newly selected input should be displayed on a different
 * page and switches to this page if neccessary.
 *
 * Reads global variables:  modules, currentModuleIndex
 * Writes global variables: currentPage
 * 
 * ---------------------------------------------------------------- */ 

switchPageIfNeccessary:
{
	// load the designated page for the current module
    loadPointerToZPR(modules, ZPR_6)
    stuctLoadPointerArrayItemToZPR(ZPR_6, currentModuleIndex, ZPR_7);
	structLoadByteToAccu(ZPR_7, STRUCT_MODULE.PAGE)
    
    // check if it matches the current page
    cmp currentPage
    beq exit

    // no, set the new page and redraw the UI
    sta currentPage
    jsr userinterfaceInitScreen
    jsr userinterfaceDrawMain

    // if second page, show the logo, otherwise hide the logo
    lda #1
    cmp currentPage
    bne hideLogo
    jsr logoShow
    rts

hideLogo:
    jsr logoHide

exit:
    rts
}
