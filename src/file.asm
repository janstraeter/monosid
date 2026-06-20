#importonce 

/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Opens a file via the Kernal functions SETLFS, SETNAM und OPEN 
 *
 * Parameters:  logicalFileNumber:  the LFN (1-255)
 *              secondaryAddress: the SA (0-31)
 *              filename:  address of PETSCII encoded filename string
 *              filenameLength: length of filename string
 * 
 * ---------------------------------------------------------------- */ 

.macro fileOpen(logicalFileNumber, secondaryAddress, filename, filenameLength)
{
    // set logical file number, device number and secondary address
    lda #logicalFileNumber
    ldx #8
    ldy #secondaryAddress
    jsr KERNAL.SETLFS

    // set filename
    lda #filenameLength
    ldx #<filename
    ldy #>filename
    jsr KERNAL.SETNAM

    // open file
    jsr KERNAL.OPEN
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Closed a file via the Kernal function CLOSE
 *
 * Parameters:  logicalFileNumber:  the LFN previously used to open
 * 
 * ---------------------------------------------------------------- */ 

.macro fileClose(logicalFileNumber)
{
    lda #logicalFileNumber
    jsr KERNAL.CLOSE
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Opens the disk drive error channel (LFN 15, SA 15, no filename)
 * 
 * ---------------------------------------------------------------- */ 

.macro fileOpenErrorChannel()
{
    // logical filenumber to 15, device number and secondary address to 15
    lda #KERNAL.LFN_ERR
    ldx #8
    ldy #KERNAL.SA_ERR
    jsr KERNAL.SETLFS

    // set empty filename, because the filename length is 0 the address is irrelevant
    lda #0
    jsr KERNAL.SETNAM

    // open error channel
    jsr KERNAL.OPEN
}


/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Closes the disk drive error channel
 * 
 * ---------------------------------------------------------------- */ 

.macro fileCloseErrorChannel()
{
    lda #KERNAL.LFN_ERR
    jsr KERNAL.CLOSE
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Reads the current error message from the disk drive
 * The error channel has to opened before
 *
 * Writes global variables: diskDriveErrorBuffer, diskDriveErrorLength
 *
 * Returns: Accu - the error code (0 if no error)
 *                
 * ---------------------------------------------------------------- */ 

fileReadErrorChannel:
{
    // activate error channel as current input channel
    ldx #KERNAL.LFN_ERR
    jsr KERNAL.CHKIN

    // ----------------------------------------------------
    // read characters until End-of-File (READST bit 1 or 6)
    // ----------------------------------------------------

    // index into diskDriveErrorBuffer
    lda #0
    sta bufferIndex

read:
    // read character into accu, save it on the stack temporarily
    jsr KERNAL.CHRIN
    pha

    // read I/O status, check for EOF
    jsr KERNAL.READST
    and #$40
    bne done

    // store character in buffer
    pla
    ldy bufferIndex
    sta diskDriveErrorBuffer, y
    
    // increase buffer index, check for max. buffer size,
    // of buffer not full, read next byte
    inc bufferIndex
    lda bufferIndex
    cmp #39
    bcc read

done:
    // discard pushed character, add null-byte as last character, save string length
    pla
    lda #0
    ldy bufferIndex
    sta diskDriveErrorBuffer,y
    sty diskDriveErrorLength

    // ----------------------------------------------------
    // error message read completley, interpret the first
    // two characters as integer
    // ----------------------------------------------------

    // calculate error number from first 2 characters
    lda diskDriveErrorBuffer+0 // tens digit (ASCII)
    sec
    sbc #$30                   // → 0–9
    sta tmpErrorNum
    asl                        // × 2
    asl                        // × 4
    asl                        // × 8
    adc tmpErrorNum            // + 1× = × 9  (trick for ×10)
    adc tmpErrorNum            // + 1× = ×10
    adc diskDriveErrorBuffer+1 // + units digit (ASCII)
    sec
    sbc #$30                   // − '0' → decimal value
    
    // the accu now holds the error number (0–99)
    rts

tmpErrorNum:
    .byte(0)

bufferIndex:
    .byte(0)
}
