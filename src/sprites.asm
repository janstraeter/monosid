#importonce 

/* -------------------------------------------------------------------
 * Macro
 * -----
 *
 * Loads the address of the given sprite data
 * into the given VIC sprite block register. The address of
 * the sprite data needs to be aligned to 64 and be in the range
 * of VIC bank 0 ($0000-$3fff).
 *
 * Parameters:  spritePointerAddress: address of the VIC block register
 *              spriteAddress:        address of the sprite data
 * 
 * ---------------------------------------------------------------- */ 

.macro spriteSetBlockRegister(spritePointerAddress, spriteAddress)
{
    lda #spriteAddress / 64
    sta spritePointerAddress
}


/* -------------------------------------------------------------------
 * Macros
 * ------
 *
 * The follwing macros are shortcodes for setting the
 * block registers for sprite 0 through 7.
 * ---------------------------------------------------------------- */ 

.macro sprite0SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_0_BLOCK_REGISTER, spriteAddress) }
.macro sprite1SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_1_BLOCK_REGISTER, spriteAddress) }
.macro sprite2SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_2_BLOCK_REGISTER, spriteAddress) }
.macro sprite3SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_3_BLOCK_REGISTER, spriteAddress) }
.macro sprite4SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_4_BLOCK_REGISTER, spriteAddress) }
.macro sprite5SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_5_BLOCK_REGISTER, spriteAddress) }
.macro sprite6SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_6_BLOCK_REGISTER, spriteAddress) }
.macro sprite7SetBlockRegister(spriteAddress) { spriteSetBlockRegister(VIC.SPRITE_7_BLOCK_REGISTER, spriteAddress) }


/* -------------------------------------------------------------------
 * Macro
 * -----
 * 
 * Sets the position of an sprite to X/Y.
 * The addresses of the sprite`s X- and Y-registers need to given,
 * and also the bit-mask for setting the VIC register containing the 
 * most significant bits of the X-coordinates.
 * The X/Y-coordinates are expeted relative to the top-left corner of
 * the visible area (not the border)
 *
 * Parameters:  X:                  new x-coordinate
 *              Y:                  new y-coordinate
 *              spriteXRegister:    address of sprite´s x-register
 *              spriteYRegister:    address of sprite´s y-register
 *              spriteXMsbMask:     bit-mask for the sprite´s x-coordinate´s MSB
 * 
 * ---------------------------------------------------------------- */ 

.macro spriteSetPosition(x, y, spriteXRegister, spriteYRegister, spriteXMsbMask)
{
    .var xReal = x + 24;
    .var yReal = y + 50;

    .if (xReal > 255) {
        .eval xReal = xReal - 256
        lda #spriteXMsbMask
        ora VIC.SPRITES_X_MSB
        sta VIC.SPRITES_X_MSB
    } else {
        lda #~spriteXMsbMask
        and VIC.SPRITES_X_MSB
        sta VIC.SPRITES_X_MSB
    }

    lda #xReal
    sta spriteXRegister

    lda #yReal
    sta spriteYRegister
}


/* -------------------------------------------------------------------
 * Macros
 * ------
 *
 * The follwing macros are shortcodes for setting the
 * positions for sprite 0 through 7.
 * ---------------------------------------------------------------- */ 

.macro sprite0SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_0_X, VIC.SPRITE_0_Y, %00000001) }
.macro sprite1SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_1_X, VIC.SPRITE_1_Y, %00000010) }
.macro sprite2SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_2_X, VIC.SPRITE_2_Y, %00000100) }
.macro sprite3SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_3_X, VIC.SPRITE_3_Y, %00001000) }
.macro sprite4SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_4_X, VIC.SPRITE_4_Y, %00010000) }
.macro sprite5SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_5_X, VIC.SPRITE_5_Y, %00100000) }
.macro sprite6SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_6_X, VIC.SPRITE_6_Y, %01000000) }
.macro sprite7SetPosition(x, y) { spriteSetPosition(x, y, VIC.SPRITE_7_X, VIC.SPRITE_7_Y, %10000000) }