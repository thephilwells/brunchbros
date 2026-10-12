import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const palette = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);

const frames = {
  chef_attack_windup: [
    '    #########   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #########   ',
    '    #o.#..#.#   ',
    '    #o......#   ',
    '    #oo....o#   ',
    '     #.ooo.#    ',
    '    #......#    ',
    '   #..o....#    ',
    '   #..o....#    ',
    '   #oo.ooo.#    ',
    '    #.####.#    ',
    '   ####  ####   ',
    '   ####  ####   ',
  ],
  chef_attack_strike: [
    '    #########   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #########   ',
    '    #o.#..#.#   ',
    '    #o......#   ',
    '    #oo....o#   ',
    '     #.ooo.#    ',
    '    #......#    ',
    '   #..o....#    ',
    '   #..o....#    ',
    '   #oo.ooo.#    ',
    '    #.####.#    ',
    '   ####  ####   ',
    '   ####  ####   ',
  ],
  chef_attack_recovery: [
    '    #########   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #.o.o.o.#   ',
    '    #########   ',
    '    #o.#..#.#   ',
    '    #o......#   ',
    '    #oo....o#   ',
    '     #.ooo.#    ',
    '    #......#    ',
    '   #..o....#    ',
    '   #..o....#    ',
    '   #oo.ooo.#    ',
    '    #.####.#    ',
    '   ####  ####   ',
    '   ####  ####   ',
  ],
  pan_attack_windup: [
    '          ####  ',
    '        ##....##',
    '       #..oooo.#',
    '       #.oooooo#',
    '       #.oooooo#',
    '        #.oooo# ',
    '         ####   ',
    '        ##      ',
    '        ##      ',
    '       ##       ',
    '       ##       ',
    '      ##        ',
    '      ##        ',
    '     ##         ',
    '     ##         ',
    '    ##          ',
  ],
  pan_attack_strike: [
    '                ',
    '                ',
    '                ',
    '                ',
    '                ',
    '                ',
    '         #####  ',
    '        #.....# ',
    '       #..ooo..#',
    '       #.ooooo.#',
    '########.ooooo.#',
    'oooooooo.ooooo.#',
    '########.ooooo.#',
    '       #..ooo..#',
    '        #.....# ',
    '         #####  ',
  ],
  pan_attack_recovery: [
    '                ',
    '                ',
    '                ',
    '                ',
    '                ',
    '                ',
    '         #####  ',
    '        #.....# ',
    '       #..ooo..#',
    '       #.ooooo.#',
    '########.ooooo.#',
    'oooooooo.ooooo.#',
    '########.ooooo.#',
    '       #..ooo..#',
    '        #.....# ',
    '         #####  ',
  ],
};

let crcTable;
function crc32(buffer) {
  if (!crcTable) {
    crcTable = Array.from({ length: 256 }, (_, value) => {
      let crc = value;
      for (let bit = 0; bit < 8; bit++) crc = (crc & 1) ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
      return crc >>> 0;
    });
  }
  let crc = 0xffffffff;
  for (const byte of buffer) crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const name = Buffer.from(type);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE(crc32(Buffer.concat([name, data])));
  return Buffer.concat([length, name, data, checksum]);
}

function encodePng(rows) {
  if (rows.length !== 16 || rows.some(row => row.length !== 16)) throw new Error('Each frame must be exactly 16x16');
  const raw = Buffer.alloc(16 * (1 + 16 * 4));
  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      const shade = palette.get(rows[y][x]);
      if (shade === undefined) throw new Error(`Unknown pixel ${JSON.stringify(rows[y][x])}`);
      const offset = y * 65 + 1 + x * 4;
      raw.fill(shades[shade], offset, offset + 3);
      raw[offset + 3] = 255;
    }
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(16, 0);
  header.writeUInt32BE(16, 4);
  header[8] = 8;
  header[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

for (const [name, rows] of Object.entries(frames)) writeFileSync(`gfx/${name}.png`, encodePng(rows));
