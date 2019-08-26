cmake_minimum_required(VERSION 3.5)
project({{cookiecutter.directory_name}} LANGUAGES NONE)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake_modules/")

enable_language(ASM-GNUM68K ASM-GNUZ80)

set (CMAKE_ASM-GNUM68K_FLAGS "--bitwise-or --register-prefix-optional -mcpu=68000 -I ${CMAKE_SOURCE_DIR}/src/include -I ${CMAKE_SOURCE_DIR}/src/resources")
# set (CMAKE_ASM-GNUZ80_FLAGS "")
set (CMAKE_LINKER "/usr/bin/m68k-linux-gnu-ld")
set (CMAKE_OBJCOPY "/usr/bin/m68k-linux-gnu-objcopy")
set (CMAKE_Z80_OBJCOPY "/usr/bin/z80-unknown-coff-objcopy")

set (linker_script "../src/link.ld")

set (m68k_sources
    src/header.asm
    src/main.asm
    src/util.asm
    src/interrupts.asm
    src/level.asm
    src/resources/resources.asm
)

set (z80_sources
    src/z80/init.z80
)

set (resource_manifest
    src/resources.json
)

#set_source_files_properties("src/level.asm" PROPERTIES COMPILE_FLAGS "-L level_symb.lst")

add_library(m68k_libs OBJECT ${m68k_sources})
add_library(z80_libs OBJECT ${z80_sources})

add_executable(${CMAKE_PROJECT_NAME}.bin $<TARGET_OBJECTS:m68k_libs>)
set_target_properties(${CMAKE_PROJECT_NAME}.bin PROPERTIES LINK_DEPENDS ${linker_script})
set_target_properties(${CMAKE_PROJECT_NAME}.bin PROPERTIES LINKER_LANGUAGE ASM)
set_target_properties(${CMAKE_PROJECT_NAME}.bin PROPERTIES LINK_FLAGS "--oformat binary -T ${linker_script} -L ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/z80_libs.dir/src/z80/")
add_dependencies(${CMAKE_PROJECT_NAME}.bin m68k_libs z80_libs)

string (REGEX REPLACE "([^;]+)" "\\1.bin" z80_bins ${z80_sources})
string (REGEX REPLACE "([^;]+)" "\\1.o" z80_coff_bins ${z80_sources})
string (REGEX REPLACE "([^;]+)" "\\1.elf.o" z80_elf_bins ${z80_sources})

add_custom_command(TARGET ${CMAKE_PROJECT_NAME}.bin PRE_BUILD
    COMMAND ${CMAKE_Z80_OBJCOPY} -O binary ${z80_coff_bins} ${z80_bins}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/z80_libs.dir/
    COMMENT "Converting Z80 machine code to raw binary."
)

add_custom_command(TARGET ${CMAKE_PROJECT_NAME}.bin PRE_BUILD
    COMMAND ${CMAKE_OBJCOPY} -I binary -O elf32-m68k -B m68k ${z80_bins} ${z80_elf_bins}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/z80_libs.dir/
    COMMENT "Converting Z80 machine code to an m68k relocatable blob."
)

add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/src/resources/resources.asm
    MAIN_DEPENDENCY ${CMAKE_SOURCE_DIR}/${resource_manifest}
    COMMAND python3.6 ${CMAKE_SOURCE_DIR}/tools/build_resources.py ${CMAKE_SOURCE_DIR}/${resource_manifest} ${CMAKE_SOURCE_DIR}/src/resources/
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src/
    COMMENT "Generating resources."
)

add_executable(${CMAKE_PROJECT_NAME}.elf $<TARGET_OBJECTS:m68k_libs>)
set_target_properties(${CMAKE_PROJECT_NAME}.elf PROPERTIES LINK_DEPENDS ${linker_script})
set_target_properties(${CMAKE_PROJECT_NAME}.elf PROPERTIES LINKER_LANGUAGE ASM)
set_target_properties(${CMAKE_PROJECT_NAME}.elf PROPERTIES LINK_FLAGS "-T ${linker_script} -L ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/z80_libs.dir/src/z80/")
add_dependencies(${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.bin)
