/* vi: set syntax=gnuasm_m68k: */

    .global CPU_EntryPoint

    .include "constants.inc"
    .include "memory_map.inc"

CPU_EntryPoint:
    /* Test for reset buttons and skip initialisation if the user has reset. */
    tst.w   0x00A10008
    bne     .LMain
    tst.w   0x00A1000C
    bne     .LMain

    jsr     InitVars
    jsr     VDP_WriteTMSS
    jsr     Z80_Init
    jsr     PSG_Init
    jsr     VDP_LoadRegisters
    jsr     VDP_ClearVRAM
    jsr     ControllerPort_Init

    .LMain:
    move.l  #0, _ram_start
    /* Initialize the status register, set the interrupt  level, begin firing */
    /* H & V interrupts. */
    move.w  0b0010000000000000, sr
    jsr     InitLevel

    .LLoopForever:
    jsr     WaitVBlankStart
    jsr     WaitVBlankEnd

    bra     .LLoopForever
