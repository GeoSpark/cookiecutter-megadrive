/* vi: set syntax=gnuasm_m68k: */

    .global INT_VInterrupt
    .global INT_HInterrupt
    .global INT_Null
    .global CPU_Exception

    .include "constants.inc"
    .include "memory_map.inc"

/* Vertical interrupt */
INT_VInterrupt:
    addq.l  #1, frame_counter
    rte

/* Horizontal interrupt - called every N lines, where N Is set in VDP register 0x0A */
INT_HInterrupt:
    rte

/* Dummy interrupt handler */
INT_Null:
    rte

/* Just halt on a CPU exception. May want to do something more complicated. */
CPU_Exception:
    stop    #0x2700
    rte
