import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const pixels = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);
const frames = [
  [[6, 7, 3.5], [10, 7, 3.5], [8, 10, 3.5]],
  [[3, 5, 2.5], [8, 3, 2], [12, 6, 2.5], [4, 11, 2.5], [10, 11, 3], [8, 7, 2.5]],
  [[2, 3, 1.5], [8, 1, 1], [14, 4, 1.5], [3, 13, 1.5], [9, 10, 1.5], [14, 13, 1]],
];

function drawFrame(circles) {
  const rows = Array.from({ length: 16 }, () => Array(16).fill(' '));
  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      for (const [centerX, centerY, radius] of circles) {
        const distance = Math.hypot(x - centerX, y - centerY);
        if (distance <= radius) rows[y][x] = '#';
        if (distance <= radius - 1) rows[y][x] = 'o';
        if (distance <= radius - 2) rows[y][x] = '.';
      }
    }
  }
  return rows.map(row => row.join(''));
}

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

const rows = frames.flatMap(drawFrame);
const raw = Buffer.alloc(48 * (1 + 16 * 4));
for (let y = 0; y < 48; y++) {
  for (let x = 0; x < 16; x++) {
    const shade = pixels.get(rows[y][x]);
    const offset = y * 65 + 1 + x * 4;
    raw.fill(shades[shade], offset, offset + 3);
    raw[offset + 3] = 255;
  }
}

const header = Buffer.alloc(13);
header.writeUInt32BE(16, 0);
header.writeUInt32BE(48, 4);
header[8] = 8;
header[9] = 6;

writeFileSync('gfx/enemy_cloudburst.png', Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', header),
  chunk('IDAT', deflateSync(raw)),
  chunk('IEND', Buffer.alloc(0)),
]));
