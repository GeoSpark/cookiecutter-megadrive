/* vi: set syntax=gnuasm_m68k: */

/* VDP port addresses */
.equ vdp_control, 0x00C00004
.equ vdp_data, 0x00C00000

/* VDP commands */
.equ vdp_cmd_vram_write, 0x40000000
.equ vdp_cmd_cram_write, 0xC0000000
.equ vdp_cmd_vsram_write, 0x40000010

/* VDP addresses according to VDP registers 0x02 and 0x04 */
.equ vram_addr_tiles, 0x0000
.equ vram_addr_plane_a, 0xC000
.equ vram_addr_plane_b, 0xE000
.equ vram_addr_hscroll, 0xDC00

/* Screen width and height in tiles for H40 PAL */
.equ vdp_screen_width, 0x28
.equ vdp_screen_height, 0x1E
/* Change this for NTSC */
/* vdp_screen_height   equ 0x1C */

/* Plane size in tiles, according to VDP register 0x10 */
.equ vdp_plane_width, 0x40
.equ vdp_plane_height, 0x20

/* Hardware version address */
.equ hardware_ver_addr, 0x00A10001

/* TMSS */
.equ tmss_address, 0x00A14000
.equ tmss_signature, 0x53454741 /* "SEGA" */

/* Useful macros */
.macro SetVRAMWrite p
    move.l  #(vdp_cmd_vram_write)|((\p)&0x3FFF)<<16|(\p)>>14, vdp_control
.endm

.macro SetVRAMWriteR p
    move.l  #0, d1
    move.w  \p, d1
    move.w  \p, d2
    and.w   #0x3fff, d1
    lsl.l   #8, d1
    lsl.l   #8, d1
    lsr.w   #8, d2
    lsr.w   #6, d2
    add.w   d2, d1
    add.l   #vdp_cmd_vram_write, d1
    move.l  d1, vdp_control
.endm

.macro SetCRAMWrite p
    move.l  #(vdp_cmd_cram_write)|((\p)&0x3FFF)<<16|(\p)>>14, vdp_control
.endm

/* Set the VSRAM (vertical scroll RAM) address to write to next */
.macro SetVSRAMWrite p
    move.l  #(vdp_cmd_vsram_write)|((\p)&0x3FFF)<<16|(\p)>>14, vdp_control
.endm
