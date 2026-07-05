#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up the MIDI support
 *
 * ---------------------------------------------------------------- */ 

midiInit: {
    // switch for midiDetectedCartridge
    lda midiDetectedCartridge
    cmp #MIDI_CARTRIDGE.SEQUENTIAL
    beq setupSequential
    cmp #MIDI_CARTRIDGE.NAMESOFT
    beq setupNamesoft
    cmp #MIDI_CARTRIDGE.DATEL_SIEL_JMS
    beq setupDatel
    cmp #MIDI_CARTRIDGE.PASSPORT
    beq setupPassport
    cmp #MIDI_CARTRIDGE.MAPLIN
    beq setupMaplin

    // no cartridge detected, do nothing
    rts

setupSequential:
    jsr midiSetupCartridgeSequential
    rts

setupNamesoft:
    jsr midiSetupCartridgeNamesoft
    rts

setupDatel:
    jsr midiSetupCartridgeDatel
    rts

setupPassport:
    jsr midiSetupCartridgePassport
    rts

setupMaplin:
    jsr midiSetupCartridgeMaplin
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up register addresses and initializes MIDI cartridge.
 * Version for: Sequential
 *
 * ---------------------------------------------------------------- */ 

midiSetupCartridgeSequential:
{
    // set control register
    lda #<MIDI_CARTRIDGE_SEQUENTIAL.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_SEQUENTIAL.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI

    // set status register
    lda #<MIDI_CARTRIDGE_SEQUENTIAL.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_SEQUENTIAL.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI

    // set recieve register
    lda #<MIDI_CARTRIDGE_SEQUENTIAL.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_SEQUENTIAL.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI

    // initialize
    ldy #0
    lda #MIDI_CARTRIDGE_SEQUENTIAL.MASTER_RESET_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y
    lda #MIDI_CARTRIDGE_SEQUENTIAL.SETUP_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y

    // Sequential uses IRQ
    jsr midiSetupIrqRoutine

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up register addresses and initializes MIDI cartridge.
 * Version for: Namesoft
 *
 * ---------------------------------------------------------------- */ 

midiSetupCartridgeNamesoft:
{
    // set control register
    lda #<MIDI_CARTRIDGE_NAMESOFT.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_NAMESOFT.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI

    // set status register
    lda #<MIDI_CARTRIDGE_NAMESOFT.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_NAMESOFT.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI

    // set recieve register
    lda #<MIDI_CARTRIDGE_NAMESOFT.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_NAMESOFT.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI

    // Namesoft uses NMI
    jsr midiSetupNmiRoutine

    // initialize
    ldy #0
    lda #MIDI_CARTRIDGE_NAMESOFT.MASTER_RESET_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y
    lda #MIDI_CARTRIDGE_NAMESOFT.SETUP_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up register addresses and initializes MIDI cartridge.
 * Version for: DATEL/SIEL/JMS/C-LAB
 *
 * ---------------------------------------------------------------- */ 

midiSetupCartridgeDatel:
{
    // set control register
    lda #<MIDI_CARTRIDGE_DATEL.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_DATEL.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI

    // set status register
    lda #<MIDI_CARTRIDGE_DATEL.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_DATEL.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI

    // set recieve register
    lda #<MIDI_CARTRIDGE_DATEL.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_DATEL.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI

    // initialize
    ldy #0
    lda #MIDI_CARTRIDGE_DATEL.MASTER_RESET_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y
    lda #MIDI_CARTRIDGE_DATEL.SETUP_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y

    // Datel uses IRQ
    jsr midiSetupIrqRoutine

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up register addresses and initializes MIDI cartridge.
 * Version for: Passport/Syntech
 *
 * ---------------------------------------------------------------- */ 

midiSetupCartridgePassport:
{
    // set control register
    lda #<MIDI_CARTRIDGE_PASSPORT.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_PASSPORT.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI

    // set status register
    lda #<MIDI_CARTRIDGE_PASSPORT.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_PASSPORT.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI

    // set recieve register
    lda #<MIDI_CARTRIDGE_PASSPORT.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_PASSPORT.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI

    // initialize
    ldy #0
    lda #MIDI_CARTRIDGE_PASSPORT.MASTER_RESET_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y
    lda #MIDI_CARTRIDGE_PASSPORT.SETUP_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y

    // Passport uses IRQ
    jsr midiSetupIrqRoutine

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Sets up register addresses and initializes MIDI cartridge.
 * Version for: Maplin
 *
 * ---------------------------------------------------------------- */ 

midiSetupCartridgeMaplin:
{
    // set control register
    lda #<MIDI_CARTRIDGE_MAPLIN.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_MAPLIN.CONTROL
    sta ZPR_MIDI_CONTROL_REGISTER_ADDRESS_HI

    // set status register
    lda #<MIDI_CARTRIDGE_MAPLIN.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_MAPLIN.STATUS
    sta ZPR_MIDI_STATUS_REGISTER_ADDRESS_HI

    // set recieve register
    lda #<MIDI_CARTRIDGE_MAPLIN.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_LO
    lda #>MIDI_CARTRIDGE_MAPLIN.RECIEVE
    sta ZPR_MIDI_RECIEVE_REGISTER_ADDRESS_HI

    // Maplin does not offer IRQ or NMI, just polling
    jsr midiSetupNmiPollingRoutine

    // initialize
    ldy #0
    lda #MIDI_CARTRIDGE_MAPLIN.MASTER_RESET_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y
    lda #MIDI_CARTRIDGE_MAPLIN.SETUP_VALUE
    sta (ZPR_MIDI_CONTROL_REGISTER_ADDRESS), y

    rts
}

midiSetupIrqRoutine:
{
    // setup the IRQ interrupt service routine
    sei 
    lda #<midiInterruptServiceRoutine
    sta IRQ_VECTOR_LO
    lda #>midiInterruptServiceRoutine
    sta IRQ_VECTOR_HI
    cli
    rts
}

midiSetupNmiRoutine:
{
    // setup the NMI interrupt service routine
    sei 
    lda #<midiInterruptServiceRoutineNMI
    sta NMI_VECTOR_LO
    lda #>midiInterruptServiceRoutineNMI
    sta NMI_VECTOR_HI
    cli
    rts
}


midiSetupNmiPollingRoutine:
{
    sei

    // Stop Timer A if running
    lda CIA2.CONTROL_A
    and #%11111110              // Bit 0 = 0 → stop
    sta CIA2.CONTROL_A

    // Load timer value
    lda #<MIDI_POLL_TIMER
    sta CIA2.TIMER_A_LO
    lda #>MIDI_POLL_TIMER
    sta CIA2.TIMER_A_HI

    // Enable CIA2 Timer A NMI
    // Bit 7 = 1 → enable, Bit 0 = Timer A
    lda #%10000001
    sta CIA2.INTERRUPT_CONTROL_STATE

    // Hook NMI vector
    lda #<midiInterruptServiceRoutineNMI
    sta NMI_VECTOR_LO
    lda #>midiInterruptServiceRoutineNMI
    sta NMI_VECTOR_HI

    // Start Timer A: continuous mode, count system clock
    // Bit 0 = 1 (start), Bit 3 = 0 (continuous), Bit 4 = 1 (auto-reload)
    lda #%00010001
    sta CIA2.CONTROL_A

    cli
    rts
}


/* -------------------------------------------------------------------
 * Interrupt Service Routine
 * -------------------------
 *
 * Handles the interrupts coming from the MIDI interface,
 * if the interrupt flag (highest bit) of the MIDI status register
 * is NOT set, then it's not an MIDI interrupt and the
 * interrupt is therefor handled by the custom ISR defined in monosid.asm
 *
 * Writes global variables: midiLastRecievedByte
 *
 * ---------------------------------------------------------------- */ 

midiInterruptServiceRoutine:
{
    // read status register
    ldy #0
    lda (ZPR_MIDI_STATUS_REGISTER_ADDRESS), y

    // check if MIDI interrupt
    bit interruptBitSet
    beq notMidiInterrupt

    // check if byte recieved
    bit RDRFBitSet
    beq exit

    // check if the recieved byte has an error
    bit ErrorBitSet
    bne isError

    // load recieved MIDI byte
    lda (ZPR_MIDI_RECIEVE_REGISTER_ADDRESS), y
    
    // store MIDI byte in ring buffer
    ldx midiWritePtr
    sta midiBuffer, x
    
    // increase write pointer (wrap around via AND)
    inx
    txa
    and #MIDI_BUFFER_MASK
    sta midiWritePtr

exit:
    pla
    tay
    pla
    tax
    pla
    rti

isError:
    // read the recieve register to reset the error status,
    // but then just exit and ignore this byte
    lda (ZPR_MIDI_RECIEVE_REGISTER_ADDRESS), y
    jmp exit

notMidiInterrupt:
    // the interrupt was not triggered by the MIDI interface,
    // it must has been triggered by the standard Kernal timer interrupt, then
    jmp customInterruptServiceRoutine

    // for the meaning of bits in the status byte,
    // see: https://codebase64.net/doku.php?id=base:c64_midi_interfaces

interruptBitSet:
    // MSB high indicates MIDI interrupt
    .byte(%10000000)

RDRFBitSet:
    // LSB high indicates recieved byte ready for reading
    .byte(%00000001)

ErrorBitSet:
    // bits 6-4 high indicate that an error has happend and the recieved byte is probably corrupted
    // bit 6 (Parity Error), bit 5 (Receiver Overrun), bit 4 (Framing Error)
    // we do not check bit 6, because we do not use parity checking at all
    .byte(%00110000)
}


/* -------------------------------------------------------------------
 * Interrupt Service Routine
 * -------------------------
 *
 * The NMI version of midiInterruptServiceRoutine
 * Does not check for other interrupt sources, because it only can
 * be triggered by the MIDI cartridge.
 *
 * Writes global variables: midiLastRecievedByte
 *
 * ---------------------------------------------------------------- */ 

midiInterruptServiceRoutineNMI:
{
    // in the NMI version we need to save the registers manually
    pha
    txa
    pha
    tya
    pha

    // Read CIA2 interrupt control and status — this also acknowledges the NMI
    // Bit 0 is high = Timer A fired, continue   
    // if not Timer A it could be the RESTORE key, so exit
    lda CIA2.INTERRUPT_CONTROL_STATE
    and #%00000001
    beq exit

    // read status register
    ldy #0
    lda (ZPR_MIDI_STATUS_REGISTER_ADDRESS), y

    // check if byte recieved
    bit RDRFBitSet
    beq exit

    // check if the recieved byte has an error
    bit ErrorBitSet
    bne isError

    // load recieved MIDI byte
    lda (ZPR_MIDI_RECIEVE_REGISTER_ADDRESS), y
    
    // store MIDI byte in ring buffer
    ldx midiWritePtr
    sta midiBuffer, x
    
    // increase write pointer (wrap around via AND)
    inx
    txa
    and #MIDI_BUFFER_MASK
    sta midiWritePtr

exit:
    pla
    tay
    pla
    tax
    pla
    rti

isError:
    // read the recieve register to reset the error status,
    // but then just exit and ignore this byte
    lda (ZPR_MIDI_RECIEVE_REGISTER_ADDRESS), y
    jmp exit

RDRFBitSet:
    // LSB high indicates recieved byte ready for reading
    .byte(%00000001)

ErrorBitSet:
    // bits 6-4 high indicate that an error has happend and the recieved byte is probably corrupted
    // bit 6 (Parity Error), bit 5 (Receiver Overrun), bit 4 (Framing Error)
    // we do not check bit 6, because we do not use parity checking at all
    .byte(%00110000)
}


midiProcessBuffer:
{
bufferReadLoop:
    // if read pointer = write pointer, no new byte to process
    ldx midiReadPtr
    cpx midiWritePtr
    beq bufferEmpty
    
    // read next byte
    lda midiBuffer, x

    // save A, increase write pointer
    // and wrap around via AND, restore A
    pha
    inx
    txa
    and #MIDI_BUFFER_MASK
    sta midiReadPtr
    pla

    // process MIDI byte in A
    jsr midiProcessLastRecievedByte
    
    // and check for further bytes
    jmp bufferReadLoop

bufferEmpty:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Processes the last recieved MIDI byte. Interprets the single incoming bytes
 * from the MIDI interface as MIDI messages. Handles the messages
 * our synth needs/wants to support, ignores all other.
 *
 * Parameters:              accu: the value of the last recieved byte
 *
 * Writes global variables: midiCurrentStatus, midiDataBuffer, midiDataBufferCount,
 *                          midiExpectedDataBytes, midiIgnoreDataBytesUntilNewStatus
 *
 * Reads global variables:  midiLastRecievedByte, midiCurrentStatus, midiDataBuffer,
 *                          midiDataBufferCount, midiExpectedDataBytes,
 *                          midiIgnoreDataBytesUntilNewStatus
 *
 * ---------------------------------------------------------------- */ 

midiProcessLastRecievedByte:
{
    // first check if the recieved byte is a status byte
    bit statusByteBitSet
    beq isDataByte

    // -----------------------------------------------------------
    // status byte
    // -----------------------------------------------------------
    
    // save A in X because we need an AND for the next check,
    // which destroys A
    tax

    // check if it is a realtime message,
    // because these can happen always - even in the middle of other
    // messages, we need to check early and ignore them,
    // so they do not mess up the rest of the algorithm
    and #%11111000 
    cmp #%11111000
    beq exitStatusByte

    // restore A and save the recieved byte as the new current status
    txa
    sta midiCurrentStatus

    // first check for system messages, as they are independent from the channel
    and #%11110000 
    cmp #%11110000
    beq midiMessageSystemMessages

    // now check for the channel (if midiChannel has a value different from 255)
    ldx midiChannel
    bmi handleChannelMessages

    // midiChannel set, so check for same channel in the status byte
    lda midiCurrentStatus  
    and #%00001111
    cmp midiChannel
    bne ignoredChannelMessages

    // load status byte again, because we destroyed the accu with the AND
    lda midiCurrentStatus

handleChannelMessages:

    // mask out the channel number
    and #%11110000

    // now check for channel message
    cmp #$80
    beq midiMessageNoteOff
    cmp #$90
    beq midiMessageNoteOn
    // cmp #$A0
    // beq midiMessagePolyphonicKeyPressure
    // cmp #$B0
    // beq midiMessageControlChange
    // cmp #$C0
    // beq midiMessageProgramChange
    // cmp #$D0
    // beq midiMessageChannelPressure
    cmp #$E0
    beq midiMessagePitchBendChange
    // cmp #$F0
    // beq midiMessageSystemMessages
    jmp unhandledMidiMessages

midiMessageNoteOff:
    lda #MIDI_MESSAGE.NOTE_OFF
    sta midiCurrentMessage
    lda #0
    sta midiDataBufferCount
    lda #2
    sta midiExpectedDataBytes
    lda #0
    sta midiIgnoreDataBytesUntilNewStatus
    rts

midiMessageNoteOn:
    lda #MIDI_MESSAGE.NOTE_ON
    sta midiCurrentMessage
    lda #0
    sta midiDataBufferCount
    lda #2
    sta midiExpectedDataBytes
    lda #0
    sta midiIgnoreDataBytesUntilNewStatus
    rts

midiMessagePitchBendChange:
    lda #MIDI_MESSAGE.PITCH_BEND_CHANGE
    sta midiCurrentMessage
    lda #0
    sta midiDataBufferCount
    lda #2
    sta midiExpectedDataBytes
    lda #0
    sta midiIgnoreDataBytesUntilNewStatus
    rts

midiMessagePolyphonicKeyPressure:
midiMessageControlChange:
midiMessageProgramChange:
midiMessageChannelPressure:
midiMessageSystemMessages:
unhandledMidiMessages:
ignoredChannelMessages:
    lda #1
    sta midiIgnoreDataBytesUntilNewStatus
    rts

exitStatusByte:
    rts

isDataByte:

    // -----------------------------------------------------------
    // data byte
    // -----------------------------------------------------------
    
    // check if data byte should be ignored until a new status is set
    ldy midiIgnoreDataBytesUntilNewStatus
    bne exit

    // byte should be used as part of the current MIDI message

    // write data byte into buffer and increase the buffer counter
    ldx midiDataBufferCount
    sta midiDataBuffer, x
    inc midiDataBufferCount

    // check if the number of expected data bytes for the current MIDI message is reached
    // if not, exit
    ldx midiDataBufferCount
    cpx midiExpectedDataBytes
    bcc exit

    // max. number of data bytes for the current MIDI message is reached
    // that means we have a complete MIDI message and need to handle it
    jsr midiHandleCurrentMessage

    // because we must assume that a "running status" is used by the MIDI transmitter,
    // reset the buffer
    ldx #0
    stx midiDataBufferCount

    // -----------------------------------------------------------
    // finish
    // -----------------------------------------------------------
    
exit:
    rts

statusByteBitSet:
    // MSB of the recieved byte high indicates a status byte, not a data byte
    .byte(%10000000)
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Handles the current MIDI message
 *
 * Writes global variables: midiCurrentStatus, midiDataBuffer, midiDataBufferCount,
 *
 * Reads global variables:  
 *
 * ---------------------------------------------------------------- */ 

midiHandleCurrentMessage:
{
    // switch for the MIDI message
    lda midiCurrentMessage
    cmp #MIDI_MESSAGE.NOTE_ON
    beq noteOn
    cmp #MIDI_MESSAGE.NOTE_OFF
    beq noteOff
    cmp #MIDI_MESSAGE.PITCH_BEND_CHANGE
    beq pitchBendChange
    rts

    // -----------------------------------------------------------
    // MIDI Note-on message
    // -----------------------------------------------------------

noteOn:
    // load the MIDI note value from the first data byte
    lda midiDataBufferFirstByte

    // check if it is in the playable range of the SID chip (8 octaves, C0-C7)
    // --------------------------------------------------------------------------
    // MIDI middle C (C4) has the value 60, our C4 has the index 48,
    // so we must subtract 12 to get the index into our frequency table (60-48=12)
    // Therefore the deepest MIDI note we can handle has the value 12,
    // the highest MIDI note has the value 107 (107-12=95, which is
    // the highest possible index into the note frequencies table)
    // --------------------------------------------------------------------------
    cmp #12          
    bcc exit // if smaller than 12
    cmp #108            
    bcs exit // if 108 or greater

    // the MIDI note is in our playable range,
    // so substract 12 from the note value
    sec
    sbc #12

    // load the velocity value
    ldy midiDataBufferSecondByte

    // add the note to the buffer
    jsr midiAddActiveNote

    rts

    // -----------------------------------------------------------
    // MIDI Note-off message
    // -----------------------------------------------------------

noteOff:
    // check if MIDI note is in range, as explained above
    lda midiDataBufferFirstByte
    cmp #12
    bcc exit
    cmp #108
    bcs exit

    // the MIDI note is in our playable range,
    // so substract 12 from the note value and remove the note from the buffer
    sec
    sbc #12
    jsr midiRemoveActiveNote

    rts

    // -----------------------------------------------------------
    // MIDI Pitch bend change message
    // -----------------------------------------------------------

pitchBendChange:
    // because we only want to use the MSB (most controllers ignore the low byte anyway)
    // we only use the second MIDI data byte of the pitch bend change message
    lda midiDataBufferSecondByte

    // use this value to look up the corresponding cent value
    // the lookup table contains 127 signed word values
    // multiply the value from MIDI (0-127) by 2 via left shift
    asl
    tay
    
    // load the two bytes and save them into midiPitchBendValueLo and midiPitchBendValueHi
    // because this subroutine is called by an interrupt we have to save the value of
    // ZPR_1 to the stack and restore it after usage
    pushZPR(ZPR_1)
    loadPointerToZPR(pitchBendValuesToCentTable, ZPR_1)
    lda (ZPR_1), y
    sta midiPitchBendValueLo
    iny
    lda (ZPR_1), y
    sta midiPitchBendValueHi
    pullZPR(ZPR_1)

    // set the changed flag
    lda #1
    sta midiPitchBendValueChangedFlag

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Adds a note to the buffer of currently active MIDI notes
 * If the buffer is full, removes the first entry before adding
 * the new note at the end.
 *
 * Parameters:              accu: note value (index into frequency table)
 *                          Y:    velocity value
 *
 * Writes global variables: midiActiveNotesNum, midiActiveNotesBuffer
 *
 * Reads global variables:  midiActiveNotesNum, midiActiveNotesBuffer
 *
 * ---------------------------------------------------------------- */ 

midiAddActiveNote:
{
    // It is absolutely possible that MIDI bytes/messages get lost -
    // and if a note-off message gets lost it is possible that
    // the note of the current note-on message is still somewhere in the buffer.
    // So to account for this possibility call the "midiRemoveActiveNote" subroutine
    // to delete the current note in the accu if it is found in the buffer.
    pha
    jsr midiRemoveActiveNote
    pla

    // check if buffer is empty
    ldx midiActiveNotesNum
    cpx #0
    bne doNotUpdateCurrentNoteVolume

    // buffer is empty, therefore the current MIDI note is the first pressed note
    // update the current note volume according to the velocity value of the MIDI note
    pha
    tya
    tax
    lda midiVelocityToVolumeTable, x
    sta currentNoteVolume
    ldx #0
    pla

doNotUpdateCurrentNoteVolume:
    // now check if buffer is full, if so jump to the according label
    cpx #MIDI_MAX_ACTIVE_NOTES
    bcs bufferFull
    
addNote:
    // add the value of the accu to the buffer, increase the buffer size by one
    sta midiActiveNotesBuffer, x
    inc midiActiveNotesNum

    // exit
    rts

bufferFull:
    // buffer is full already, save the accu on the stack,
    // call the subroutine to delete the first entry, restore the accu
    pha
    lda midiActiveNotesBuffer
    jsr midiRemoveActiveNote
    pla

    // now add the note
    jmp addNote
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Removes the note with the given value from the buffer.
 *
 * Parameters:              accu: note value (index into frequency table)
 *
 * Writes global variables: midiActiveNotesNum, midiActiveNotesBuffer
 *
 * Reads global variables:  midiActiveNotesNum, midiActiveNotesBuffer
 *
 * ---------------------------------------------------------------- */ 

midiRemoveActiveNote:
{
    // start the search at the left
    ldx #0

searchLoop:
    // check if the end of the buffer is reached
    cpx midiActiveNotesNum
    bcs exit

    // compare the accu (the note to remove) with the current position
    cmp midiActiveNotesBuffer, x
    beq found

    // move index to the next position in the buffer and repeat
    inx
    jmp searchLoop

found:
    // the X register contains the position of the note which should be removed
    // copy X to Y and increment Y by one
    txa
    tay
    iny

    // check if the note which should be removed is at the last position in the buffer,
    // then no editing the buffer is needed - just decrement the value in midiActiveNotesNum
    cpy midiActiveNotesNum
    bcs removingComplete

removeLoop:
    // check if the the last active note in the buffer is reached
    cpy midiActiveNotesNum
    bcs removingComplete

    // midiActiveNotesBuffer[x] = midiActiveNotesBuffer[x+1]
    lda midiActiveNotesBuffer, y
    sta midiActiveNotesBuffer, x

    // go to next byte
    inx
    iny
    jmp removeLoop

removingComplete:
    // decrement midiActiveNotesNum by one and we are done
    dec midiActiveNotesNum

exit:
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Updates the values of the global variables for the note to play
 * according to the content of the MIDI active notes buffer.
 *
 * Writes global variables: currentNote, previousNote, noteHasChangedFlag
 *
 * Reads global variables:  midiActiveNotesNum, midiActiveNotesBuffer
 *
 * ---------------------------------------------------------------- */ 

midiUpdateCurrentNote:
{
    // check if any note in the buffer, if not jump to the according label
    lda midiActiveNotesNum
    beq notNoteActive

    // load the last note in the buffer and save it in "tempCurrentNote"
    // then jump to the check for note change
    tax
    dex
    lda midiActiveNotesBuffer, x
    sta tempCurrentNote
    jmp checkForNoteChange

notNoteActive:
    // no active note found, save 255 into "tempCurrentNote"
    lda #$FF
    sta tempCurrentNote

checkForNoteChange:
    // compare "currentNote" with the last note in the buffer,
    // jump to the according label, if it is the same note
    lda currentNote
    cmp tempCurrentNote
    beq noteHasNotChanged

    // a new note to play detected, save the current note into "previousNote"
    // then save the last note from the buffer into "currentNote"
    lda currentNote
    sta previousNote
    lda tempCurrentNote
    sta currentNote
    cmp #$FF
    
    // if the new note is in fact a playable note and not 255 (indicating "no note")
    // set lastPlayedNote to the new current note
    beq doNotUpdateLastPlayedNote
    sta lastPlayedNote
doNotUpdateLastPlayedNote:

    // set the flag to indicate a note-change
    lda #$01
    sta noteHasChangedFlag

noteHasNotChanged:
    rts

tempCurrentNote:
    .byte($ff)
}