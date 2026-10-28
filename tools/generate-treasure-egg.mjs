import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const palette = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);
const eggs = [
  [
    '                ',
    '      ####      ',
    '    ##....##    ',
    '   #........#   ',
    '  #..........#  ',
    ' #............# ',
    ' #............# ',
    ' #............# ',
    ' #...........o# ',
    ' #..........oo# ',
    ' #.........ooo# ',
    '  #.......ooo#  ',
    '  #......oooo#  ',
    '   ##..oooo##   ',
    '     ######     ',
    '                ',
  ],
  [
    '                ',
    '      ####      ',
    '    ##....##    ',
    '   #........#   ',
    '  #.....#....#  ',
    ' #.....##.....# ',
    ' #.....#......# ',
    ' #....##......# ',
    ' #...##......o# ',
    ' #....#.....oo# ',
    ' #....##...ooo# ',
    '  #....#...oo#  ',
    '  #...##.oooo#  ',
    '   ##..oooo##   ',
    '     ######     ',
    '                ',
  ],
];
const heart = [
  ' ##  ## ',
  '#..##..#',
  '#......#',
  '#......#',
  ' #....# ',
  '  #..#  ',
  '   ##   ',
  '        ',
];
const key = [
  '  ####  ',
  ' #....# ',
  ' #.  .# ',
  ' #....# ',
  '  ####  ',
  '   ##   ',
  '   #### ',
  '   ## # ',
];

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
  const width = rows[0].length;
  const height = rows.length;
  const stride = 1 + width * 4;
  const raw = Buffer.alloc(height * stride);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const shade = palette.get(rows[y][x]);
      const offset = y * stride + 1 + x * 4;
      raw.fill(shades[shade], offset, offset + 3);
      raw[offset + 3] = 255;
    }
  }

  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 6;

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function scaleRows(rows, scale) {
  return rows.flatMap(row => Array(scale).fill([...row].map(pixel => pixel.repeat(scale)).join('')));
}

for (const egg of eggs) {
  if (egg.length !== 16 || egg.some(row => row.length !== 16)) throw new Error('Treasure egg poses must be 16x16');
}
if (heart.length !== 8 || heart.some(row => row.length !== 8)) throw new Error('Dropped heart must be 8x8');
if (key.length !== 8 || key.some(row => row.length !== 8)) throw new Error('Dropped key must be 8x8');

const heartPanel = Array.from({ length: 16 }, (_, y) => {
  if (y < 4 || y >= 12) return ' '.repeat(16);
  return `    ${heart[y - 4]}    `;
});
const keyPanel = Array.from({ length: 16 }, (_, y) => {
  if (y < 4 || y >= 12) return ' '.repeat(16);
  return `    ${key[y - 4]}    `;
});
const review = eggs[0].map((_, y) => `${eggs[0][y]}  ${eggs[1][y]}  ${heartPanel[y]}  ${keyPanel[y]}`);

writeFileSync('gfx/treasure_egg.png', encodePng(eggs.flat()));
writeFileSync('gfx/dropped_heart.png', encodePng(heart));
writeFileSync('gfx/dropped_key.png', encodePng(key));
writeFileSync('gfx/treasure_egg_review.png', encodePng(scaleRows(review, 6)));
