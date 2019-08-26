TL;DR:

.. code:: bash

    docker build --tag md_dev .
    docker run -it --rm -v ~/MegaDrive/:/usr/sega/ md_dev
    blastem build/hello.bin

Install m68k-linux-gnu-as and friends, as well as necessary packages for gdb:

.. code:: bash

   sudo apt install binutils-m68k-linux-gnu binutils-z80 libncurses5-dev texinfo

Build a custom version of GDB with m68k-elf as the target.

https://www.gnu.org/software/gdb/current/

.. code:: bash

   sudo mkdir /usr/m68k-linux-gnu/bin
   ./configure --target m68k-unknown-linux-gnu --enable-tui=yes
   make
   sudo make install
   sudo ln -s /usr/local/bin/m68k-unknown-linux-gnu-gdb /usr/m68k-linux-gnu/bin/gdb

Install radare2 - https://rada.re/r/
Install BlastEm - https://www.retrodev.com/blastem/
Install CMake

Compile a bin file for the emulator, and an ELF for gdb

.. code:: bash

   m68k-linux-gnu-as --bitwise-or --register-prefix-optional -mcpu=68000 -o main.o main.asm
   m68k-linux-gnu-as --bitwise-or --register-prefix-optional -mcpu=68000 -o util.o util.asm
   ...
   m68k-linux-gnu-ld --oformat binary -T link.ld -o foo.bin init.o main.o interrupts.o util.o
   m68k-linux-gnu-ld -T link.ld -o foo init.o main.o interrupts.o util.o

Generate Z80 binary data first, then it can be included in the 68k output
using the 'incbin' directive.

.. code:: bash

   z80-unknown-coff-as -o init.z80.o init.z80
   z80-unknown-coff-objcopy -O binary init.z80.o init.z80.bin
   m68k-linux-gnu-objcopy -I binary -O elf32-m68k -B m68k init.z80.bin init.z80.elf.o

Connect to blastem via gdb:

.. code::

   target remote | /usr/bin/blastem out.bin -D

