import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const palette = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);
const poses = [
  [
    '                ',
    '     ######     ',
    '  ###......###  ',
    ' #....oooo....# ',
    '#...o######o...#',
    '##...#....#...##',
    ' ############## ',
    '   ##########   ',
  ],
  [
    '                ',
    '          ####  ',
    '      ####....# ',
    '   ###...oo...##',
    ' ##...o####o...#',
    '#.....#...#..## ',
    '#############   ',
    '  ########      ',
  ],
  [
    '                ',
    '                ',
    '    ########    ',
    ' ###........### ',
    '#....#....#....#',
    '################',
    '  ############  ',
    '                ',
  ],
  [
    '                ',
    '  ####          ',
    ' #....####      ',
    '##...oo...###   ',
    '#...o####o...## ',
    ' ##..#...#.....#',
    '   #############',
    '      ########  ',
  ],
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

for (const pose of poses) {
  if (pose.length !== 8 || pose.some(row => row.length !== 16)) throw new Error('PANCAKE poses must be 16x8');
}

const motion = poses.flat();
const review = poses[0].map((_, y) => poses.map(pose => pose[y]).join('  '));
writeFileSync('gfx/pancake_motion.png', encodePng(motion));
writeFileSync('gfx/pancake_motion_review.png', encodePng(scaleRows(review, 4)));
