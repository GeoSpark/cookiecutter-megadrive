/* vi: set syntax=gnuasm_m68k: */

    .section .header

/* This could easily be generated from a script. */

/* CPU vector table */
    dc.l    0x00FFE000           /* Initial stack pointer value */
    dc.l    CPU_EntryPoint      /* Start of program */
    dc.l    CPU_Exception       /* Bus error */
    dc.l    CPU_Exception       /* Address error */
    dc.l    CPU_Exception       /* Illegal instruction */
    dc.l    CPU_Exception       /* Division by zero */
    dc.l    CPU_Exception       /* CHK CPU_Exception */
    dc.l    CPU_Exception       /* TRAPV CPU_Exception */
    dc.l    CPU_Exception       /* Privilege violation */
    dc.l    INT_Null            /* TRACE exception */
    dc.l    INT_Null            /* Line-A emulator */
    dc.l    INT_Null            /* Line-F emulator */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Spurious exception */
    dc.l    INT_Null            /* IRQ level 1 */
    dc.l    INT_Null            /* IRQ level 2 */
    dc.l    INT_Null            /* IRQ level 3 */
    dc.l    INT_HInterrupt      /* IRQ level 4 */
    dc.l    INT_Null            /* IRQ level 5 */
    dc.l    INT_VInterrupt      /* IRQ level 6 */
    dc.l    INT_Null            /* IRQ level 7 */
    dc.l    INT_Null            /* TRAP #00 exception */
    dc.l    INT_Null            /* TRAP #01 exception */
    dc.l    INT_Null            /* TRAP #02 exception */
    dc.l    INT_Null            /* TRAP #03 exception */
    dc.l    INT_Null            /* TRAP #04 exception */
    dc.l    INT_Null            /* TRAP #05 exception */
    dc.l    INT_Null            /* TRAP #06 exception */
    dc.l    INT_Null            /* TRAP #07 exception */
    dc.l    INT_Null            /* TRAP #08 exception */
    dc.l    INT_Null            /* TRAP #09 exception */
    dc.l    INT_Null            /* TRAP #10 exception */
    dc.l    INT_Null            /* TRAP #11 exception */
    dc.l    INT_Null            /* TRAP #12 exception */
    dc.l    INT_Null            /* TRAP #13 exception */
    dc.l    INT_Null            /* TRAP #14 exception */
    dc.l    INT_Null            /* TRAP #15 exception */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */
    dc.l    INT_Null            /* Unused (reserved) */

/* Mega Drive ROM header */
    .ascii "SEGA MEGA DRIVE "  /* Console name */
    .ascii "{{ '%-16s' | format(cookiecutter.developer) | truncate(16, True, '') }}"  /* Copyright holder and date */
    .ascii "{{ '%-48s' | format(cookiecutter.game_name) | truncate(48, True, '') }}" /* Domestic name */
    .ascii "{{ '%-48s' | format(cookiecutter.game_name) | truncate(48, True, '') }}" /* International name */
    .ascii "GM XXXXXXXX-XX"    /* Version number */
    dc.w    0x0000               /* Checksum */
    .ascii "J               "  /* I/O support */
    dc.l    _rom_start          /* Start address of ROM */
    dc.l    _rom_end            /* End address of ROM */
    dc.l    _ram_start          /* Start address of RAM */
    dc.l    _ram_end            /* End address of RAM */
    dc.l    0x00000000           /* SRAM enabled */
    dc.l    0x00000000           /* Unused */
    dc.l    0x00000000           /* Start address of SRAM */
    dc.l    0x00000000           /* End address of SRAM */
    dc.l    0x00000000           /* Unused */
    dc.l    0x00000000           /* Unused */
    .ascii "                                        "          /* Notes (unused) */
    .ascii "JUE             "  /* Country codes */
