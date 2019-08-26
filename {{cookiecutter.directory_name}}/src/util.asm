/* vi: set syntax=gnuasm_m68k: */

    .global VDP_WriteTMSS
    .global VDP_LoadRegisters
    .global VDP_ClearVRAM
    .global Z80_Init
    .global PSG_Init
    .global ControllerPort_Init
    .global UploadPalette
    .global WaitVBlankStart
    .global WaitVBlankEnd
    .global InitVars
    .global Random

    .include "constants.inc"
    .include "memory_map.inc"

    .section .data

VDPRegisters:
    dc.b    0b00010100 /* 0x00: H interrupt on, palettes on */
    dc.b    0b01111100 /* 0x01: V interrupt on, display on, DMA on, Mega Drive mode on, PAL mode */
    dc.b    0x30       /* 0x02: Pattern table for Scroll Plane A at VRAM 0xC000 (bits 3-5 = bits 13-15) */
    dc.b    0x3C       /* 0x03: Pattern table for Window Plane at VRAM 0xF000 (bits 1-5 = bits 11-15) */
    dc.b    0x07       /* 0x04: Pattern table for Scroll Plane B at VRAM 0xE000 (bits 0-2 = bits 11-15) */
    dc.b    0b01101100 /* 0x05: Sprite table at VRAM 0xD800 (bits 0-6 = bits 9-15) */
    dc.b    0b00000000 /* 0x06: Unused */
    dc.b    0b00000000 /* 0x07: Background colour: bits 0-3 = colour, bits 4-5 = palette */
    dc.b    0b00000000 /* 0x08: Unused */
    dc.b    0b00000000 /* 0x09: Unused */
    dc.b    0b00001000 /* 0x0A: Frequency of Horiz. interrupt in rasters (number of lines travelled by the beam) */
    dc.b    0b00000010 /* 0x0B: External interrupts off, V scroll fullscreen, H scroll fullscreen */
    dc.b    0b10000001 /* 0x0C: Shadows and highlights off, interlace off, H40 mode (320 x 224 screen res) */
    dc.b    0b00110111 /* 0x0D: Horiz. scroll table at VRAM 0xDC00 (bits 0-5) */
    dc.b    0b00000000 /* 0x0E: Unused */
    dc.b    0b00000010 /* 0x0F: Autoincrement VRAM by 2 bytes */
    dc.b    0b00000001 /* 0x10: Scroll plane size: 64x32 tiles */
    dc.b    0b00000000 /* 0x11: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7) */
    dc.b    0b00000000 /* 0x12: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7) */
    dc.b    0b11111111 /* 0x13: DMA length low byte */
    dc.b    0b11111111 /* 0x14: DMA length high byte */
    dc.b    0b00000000 /* 0x15: DMA source address low byte */
    dc.b    0b00000000 /* 0x16: DMA source address mid byte */
    dc.b    0b10000000 /* 0x17: DMA source address high byte, memory-to-VRAM mode (bits 6-7) */
    .even

PSGData:
    dc.w 0x9fbf
    dc.w 0xdfff

    .section .text

VDP_WriteTMSS:
    move.b  hardware_ver_addr, d0
    andi.b  #0x0F, d0
    beq     .LSkipTMSS
    move.l  #tmss_signature, tmss_address
    .LSkipTMSS:
    rts

/* Set the VDP registers to the values we want by using the VDP's command port. */
VDP_LoadRegisters:
    lea     VDPRegisters, a0
    move.w  #0x18-1, d0              /* Set up the loop counter for the number of VDP registers. */
    move.w  #0x8000, d1              /* Set bit 15 and clear bit 14 which signifies a WRITE1: REGISTER SET intention. */

    .LCopyRegLoop:
    move.b  (a0)+, d1               /* Move the register value into the LSB of our control word. */
    move.w  d1, vdp_control         /* Send the control word to the VDP. */
    addi.w  #0x0100, d1              /* Increment the register number in the control word. */
    dbra    d0, .LCopyRegLoop        /* dbra checks Di.w for -1, not Di.l for 0. */

    rts

VDP_ClearVRAM:
    SetVRAMWrite 0x0000
    move.w  #(0x00010000/2)-1, d0    /* Set up the loop to clear 32k words. */
    .LClearVRAMLoop:
    move.w  #0, vdp_data            /* The VDP registers are set up so this auto-increments the address. */
    dbra    d0, .LClearVRAMLoop

    rts

Z80_Init:
    move.w  #0x0100, _z80_ctrl+0x100  /* Request access to the Z80's bus. */
    move.w  #0x0100, _z80_ctrl+0x200  /* Hold the Z80 in reset mode until the bus becomes free. */
    .LWait:
    btst    #0x0, _z80_ctrl+0x100     /* Wait for the bus access flag to be cleared. */
    bne .LWait

    move.l  #_z80_prog_start, a0
    move.l  #_z80_prog_size, d0                /* Amount of data we want to load onto the Z80. */
    move.l  #_z80_ram_start, a1
    .LCopyZ80:
    move.b  (a0)+, (a1)+
    dbra    d0, .LCopyZ80

    move.w  #0x0000, _z80_ctrl+0x200  /* Release reset state. */
    move.w  #0x0000, _z80_ctrl+0x100  /* Release control of the bus. */
    rts

PSG_Init:
    move.l  #PSGData, a0
    move.l  #0x03, d0                /* 4 bytes of data. */
    .LCopyPSG:
    move.b  (a0)+, 0x00C00011
    dbra    d0, .LCopyPSG

    rts

ControllerPort_Init:
    move.b  #0x00, 0x000A10009
    move.b  #0x00, 0x000A1000B
    move.b  #0x00, 0x000A1000D

    rts

InitVars:
    move.w  #25353, lfsr
    rts

/* Registers clobbered: */
/* a0, d0 */
UploadPalette:
    SetCRAMWrite 0x0000
    move.l  4(sp), a0
    move.l  #0x07, d0                 /* Palette size in dwords. */

    .LCopyPalette:
    move.l  (a0)+, vdp_data
    dbra    d0, .LCopyPalette

    rts

/* Registers clobbered: */
/* d0 */
WaitVBlankStart:
    move.w  vdp_control, d0 /* Move VDP status word to d0 */
    andi.w  #0x0008, d0     /* AND with bit 4 (vblank), result in status register */
    bne     WaitVBlankStart /* Branch if not equal (to zero) */
    rts

/* Registers clobbered: */
/* d0 */
WaitVBlankEnd:
    move.w  vdp_control, d0 /* Move VDP status word to d0 */
    andi.w  #0x0008, d0     /* AND with bit 4 (vblank), result in status register */
    beq     WaitVBlankEnd   /* Branch if equal (to zero) */
    rts

/* Parameters: */
/* d2 number of bits, up to 16. */
/* */
/* Returns: */
/* Random value in d1 */
/* */
/* Clobbers: */
/* d0, d1, d2 */
Random:
    subq.w  #1, d2
    move.w  #0, d1
    move.w  lfsr, d0
    .LRandomLoop:
    lsl.w   #1, d1
    lsr.w   #1, d0
    bcc     .LRandomSkip
    eori.w  #0xb400, d0
    bset    #0, d1
    .LRandomSkip:
    dbra    d2, .LRandomLoop

    move.w  d0, lfsr
    rts
