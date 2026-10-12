import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const palette = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);

const fullHeart = [
  ' ##  ## ',
  '#..##..#',
  '#......#',
  '#......#',
  ' #....# ',
  '  #..#  ',
  '   ##   ',
  '        ',
];
const halfHeart = fullHeart.map(row => row.split('').map((pixel, x) => pixel === '.' && x >= 4 ? ' ' : pixel).join(''));
const emptyHeart = fullHeart.map(row => row.replaceAll('.', ' '));
const rows = fullHeart.map((row, y) => row + halfHeart[y] + emptyHeart[y]);

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

const raw = Buffer.alloc(8 * (1 + 24 * 4));
for (let y = 0; y < 8; y++) {
  for (let x = 0; x < 24; x++) {
    const shade = palette.get(rows[y][x]);
    const offset = y * 97 + 1 + x * 4;
    raw.fill(shades[shade], offset, offset + 3);
    raw[offset + 3] = 255;
  }
}

const header = Buffer.alloc(13);
header.writeUInt32BE(24, 0);
header.writeUInt32BE(8, 4);
header[8] = 8;
header[9] = 6;

writeFileSync('gfx/hud_hearts.png', Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', header),
  chunk('IDAT', deflateSync(raw)),
  chunk('IEND', Buffer.alloc(0)),
]));
