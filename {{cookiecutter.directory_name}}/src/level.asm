/* vi: set syntax=gnuasm_m68k: */

    .global InitLevel

    .include "constants.inc"
    .include "memory_map.inc"
    .include "resources.inc"

InitLevel:
    move.w  #0x811c, vdp_control /* Disable the display and V interrupts. */

    move.l  #res_tile_palette_start, -(sp)
    jsr     UploadPalette
    addq.l  #4, sp

    /* Upload tileset to VDP */
    SetVRAMWrite vram_addr_tiles
    lea     res_tiles_start, a0
    move.w  #(res_tiles_size / 4 - 1), d0
    .LTileLoop:
    move.l  (a0)+, vdp_data
    dbra    d0, .LTileLoop

    move.w  #0x8700, vdp_control /* Set the background colour to palette 0, colour 0. */
    move.w  #0x817c, vdp_control /* Enable the display and V interrupts. */
    rts
