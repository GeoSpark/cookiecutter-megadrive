import sys
import struct
import json
import io
from collections import OrderedDict
import os
import csv
import itertools

from PIL import Image


def gen_palette(resource):
    if 'file' in resource.keys():
        return parse_palette(resource)

    palette = [((colour[0] & 0xe0) >> 4) + (colour[1] & 0xe0) + ((colour[2] & 0xe0) << 4)
               for colour in resource['colours']]

    if len(palette) < 16:
        palette.extend([0] * (16 - len(palette)))

    return struct.pack('>16H', *palette[:16])


def parse_palette(resource):
    with open(resource['file'], 'rb') as f:
        five_bits = struct.unpack('<16H', f.read(32))

    palette = []

    for colour in five_bits:
        r = (colour & 0x7000) >> 3
        r += (colour & 0x0380) >> 2
        r += (colour & 0x001c) >> 1
        palette.append(r)

    if len(palette) < 16:
        palette.extend([0] * (16 - len(palette)))

    return struct.pack('>16H', *palette[:16])


def gen_tiles(resource):
    i = Image.open(resource['file'])

    f = io.BytesIO()

    for y in range(0, i.height, 8):
        for x in range(0, i.width, 8):
            tile = i.crop((x, y, x + 8, y + 8))

            b = bytearray(tile.tobytes())
            pixels = [(pixel[0] << 4) + pixel[1] for pixel in list(zip(b[::2], b[1::2]))]
            f.write(struct.pack('>32B', *pixels))

    f.seek(0)
    b = f.read()
    f.close()
    return b


def gen_tile_map(resource):
    with open(resource['file'], 'rt') as f:
        b = list()
        map_reader = csv.reader(f)

        for row in map_reader:
            for column in row:
                tile_index = int(''.join(itertools.takewhile(str.isdigit, column)))
                if 'H' in column:
                    tile_index += 1 << 11
                if 'V' in column:
                    tile_index += 1 << 12

                b.append(tile_index)

    return struct.pack('>{0}H'.format(len(b)), *b)


def build():
    manifest = json.load(open(sys.argv[1], 'rt'))

    resources = OrderedDict()

    for resource in manifest['resources']:
        if resource['type'] == 'palette':
            resources[resource['name']] = gen_palette(resource)
        elif resource['type'] == 'tiles':
            resources[resource['name']] = gen_tiles(resource)
        elif resource['type'] == 'tile_map':
            resources[resource['name']] = gen_tile_map(resource)

    if not os.path.exists(sys.argv[2]):
        os.makedirs(sys.argv[2])

    with open(os.path.join(sys.argv[2], 'resources.bin'), 'wb') as resource_bin_file:
        for byte_stream in resources.values():
            resource_bin_file.write(byte_stream)

    header = """
    .section .data

    .global resources_start
    .global resources_end
    """

    resource_asm_file = open(os.path.join(sys.argv[2], 'resources.asm'), 'wt')
    resource_asm_file.write(header)

    resource_asm_file.write('\nresources_start:\n')
    resource_asm_file.write('    .incbin "resources.bin"\n')
    resource_asm_file.write('    .even\n')
    resource_asm_file.write('resources_end:\n')

    resource_asm_file.close()

    resource_inc_file = open(os.path.join(sys.argv[2], 'resources.inc'), 'wt')

    offset = 0

    for symbol_name, byte_stream in resources.items():
        resource_inc_file.write('.equ res_{0}_start, resources_start+{1}\n'.format(symbol_name, offset))
        resource_inc_file.write('.equ res_{0}_size, {1}\n'.format(symbol_name, len(byte_stream)))
        offset += len(byte_stream)

    resource_inc_file.close()

    r2_flags_file = open(os.path.join(sys.argv[2], 'resources.r2'), 'wt')
    offset = 0
#    r2_flags_file.write('fs resources\n')
#
    for symbol_name, byte_stream in resources.items():
        r2_flags_file.write('f res_{0} @ section..data+{1}\n'.format(symbol_name, offset))
        r2_flags_file.write('Cd 1 {0} @ section..data+{1}\n'.format(len(byte_stream), offset))
        offset += len(byte_stream)

#    r2_flags_file.write('fs *\n')


if __name__ == '__main__':
    build()
