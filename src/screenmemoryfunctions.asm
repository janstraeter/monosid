#importonce 

/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y) and returns it
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Offset
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateOffset(left, top) {
    .return top * 40 + left
}


/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y),
 * and adds this to the address of the screen memory
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Absolute address of the character byte at position (x, y)
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateMemoryAddress(left, top) {
    .return screenCalculateOffset(left, top) + SCREENMEM
}


/* -------------------------------------------------------------------
 * Kick Assembler function
 * -----------------------
 *
 * Calculates the offset of an screen position (x, y),
 * and adds this to the address of the color memory
 *
 * Parameters:   left: X-Position
 *               top:  Y-Position
 *
 * Return value: Absolute address of the color-byte at position (x, y)
 *
 * ---------------------------------------------------------------- */ 

.function screenCalculateColorMemoryAddress(left, top) {
    .return screenCalculateOffset(left, top) + COLORMEM
}
