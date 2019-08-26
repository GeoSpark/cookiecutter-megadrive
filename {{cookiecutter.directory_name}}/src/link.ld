ENTRY(CPU_EntryPoint)

MEMORY {
    ROM (rx)        : ORIGIN = 0x00000000, LENGTH = 0x00400000
    EXPANSION (rw)  : ORIGIN = 0x00400000, LENGTH = 0x00400000
    Z80 (rw)        : ORIGIN = 0x00a00000, LENGTH = 0x00010000
    IO_REG (rw)     : ORIGIN = 0x00a10000, LENGTH = 0x00001000
    Z80_CTRL (rw)   : ORIGIN = 0x00a11000, LENGTH = 0x00001000
    VDP (rw)        : ORIGIN = 0x00c00000, LENGTH = 0x00200000
    RAM (rw)        : ORIGIN = 0x00ff0000, LENGTH = 0x00010000
}

_rom_start = ORIGIN(ROM);
_ram_start = ORIGIN(RAM);
_ram_end = ORIGIN(RAM) + LENGTH(RAM) - 1;
_z80_ram_start = ORIGIN(Z80);
_z80_ctrl = ORIGIN(Z80_CTRL);
_z80_prog_size = _binary_src_z80_init_z80_bin_size;
_z80_prog_start = _binary_src_z80_init_z80_bin_start;

SECTIONS {
    .text :
    {
        *(.header)
        *(.text)
    } >ROM

    .z80 :
    {
        init.z80.elf.o(.data)
    } >ROM

    .data :
    {
        *(.data)
    } >ROM

    _rom_end = . - 1 ;
}
