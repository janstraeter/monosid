#importonce 

/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Initializes the logo sprites (sets the VIC sprite block registers,
 * sprite colors and sprite positions)
 * The logo uses the sprites 0 through 5.
 *               
 * ---------------------------------------------------------------- */ 

logoSetupSprites:
{
    // Load the addresses
    sprite0SetBlockRegister(spriteLogo1);
    sprite1SetBlockRegister(spriteLogo2);
    sprite2SetBlockRegister(spriteLogo3);
    sprite3SetBlockRegister(spriteLogo4);
    sprite4SetBlockRegister(spriteLogo5);
    sprite5SetBlockRegister(spriteLogo6);

    // The first 4 sprites ("mono") are dark gray
    lda #YELLOW
    sta VIC.SPRITE_0_COLOR
    sta VIC.SPRITE_1_COLOR
    sta VIC.SPRITE_2_COLOR
    sta VIC.SPRITE_3_COLOR

    // The last two sprites ("SID") are white
    lda #YELLOW
    sta VIC.SPRITE_4_COLOR
    sta VIC.SPRITE_5_COLOR

    // center the logo horizontally
    .var logoLeft = 320 / 2 - 144 / 2
    
    // align the logo to the bottom, leaving space for the legal notice
    .var logoTop = 200 - 21 - 28

    // set all logo sprites accordingly
    sprite0SetPosition(logoLeft + 0,   logoTop);
    sprite1SetPosition(logoLeft + 24,  logoTop);
    sprite2SetPosition(logoLeft + 48,  logoTop);
    sprite3SetPosition(logoLeft + 72,  logoTop);
    sprite4SetPosition(logoLeft + 96,  logoTop);
    sprite5SetPosition(logoLeft + 120, logoTop);

    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Shows the logo´s sprites
 *               
 * ---------------------------------------------------------------- */ 

logoShow:
{
    lda #%00111111
    sta VIC.SPRITE_ACTIVE
    rts
}


/* -------------------------------------------------------------------
 * Subroutine
 * ----------
 *
 * Hides the logo´s sprites
 *               
 * ---------------------------------------------------------------- */ 

logoHide:
{
    lda #0
    sta VIC.SPRITE_ACTIVE
    rts
}
