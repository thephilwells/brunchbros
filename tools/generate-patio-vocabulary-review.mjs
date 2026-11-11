import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const width = 160;
const height = 144;
const shades = [255, 170, 85, 0];
const pixels = Buffer.alloc(width * height * 4, 255);

function paint(x, y, shade) {
  const offset = (y * width + x) * 4;
  pixels.fill(shades[shade], offset, offset + 3);
  pixels[offset + 3] = 255;
}

function fillRect(x, y, rectWidth, rectHeight, shade) {
  for (let row = y; row < y + rectHeight; row++) for (let column = x; column < x + rectWidth; column++) paint(column, row, shade);
}

function floor(x, y, floorWidth) {
  fillRect(x, y, floorWidth, 1, 3);
  fillRect(x, y + 1, floorWidth, 2, 0);
  fillRect(x, y + 3, floorWidth, 5, 2);
  for (let column = x + 8; column < x + floorWidth; column += 16) fillRect(column, y + 5, 1, 3, 1);
}

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
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

function encodePng() {
  const rows = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) pixels.copy(rows, y * (1 + width * 4) + 1, y * width * 4, (y + 1) * width * 4);
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(rows)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

floor(8, 48, 144);
fillRect(12, 33, 32, 2, 3);
fillRect(13, 35, 30, 2, 0);
for (const x of [18, 37]) {
  fillRect(x, 37, 2, 10, 2);
  fillRect(x + 2, 45, 3, 2, 3);
}

fillRect(52, 27, 2, 20, 2);
fillRect(60, 27, 2, 20, 2);
for (const y of [28, 33, 38]) fillRect(54, y, 6, 2, 1);
fillRect(51, 39, 12, 2, 3);

fillRect(76, 30, 40, 2, 3);
for (const y of [32, 36, 40]) fillRect(78, y, 36, 2, 1);
for (const x of [80, 110]) fillRect(x, 42, 2, 5, 2);

floor(8, 96, 144);
fillRect(12, 82, 32, 2, 3);
fillRect(13, 84, 30, 11, 2);
for (const x of [15, 21, 28, 36, 41]) {
  const top = 72 + (x % 4);
  fillRect(x, top, 3, 82 - top, 1);
}
for (const [x, y] of [[13, 78], [18, 73], [25, 76], [33, 71], [39, 77]]) fillRect(x, y, 6, 5, 1);

for (const x of [58, 66, 74]) fillRect(x, 62, 1, 32, 1);
for (const y of [62, 70, 78, 86, 94]) fillRect(58, y, 17, 1, 1);
for (const [x, y] of [[59, 88], [61, 84], [63, 79], [66, 76], [68, 70], [72, 66]]) {
  paint(x, y, 2);
  paint(x + 1, y, 2);
  paint(x, y + 1, 2);
}

fillRect(88, 56, 64, 1, 3);
fillRect(88, 57, 64, 2, 2);
fillRect(88, 59, 64, 1, 3);
for (let x = 88; x < 151; x++) {
  const sag = Math.max(0, 6 - Math.floor(((x - 119) * (x - 119)) / 160));
  paint(x, 60 + sag, 2);
}
for (const x of [94, 108, 124, 140]) {
  const sag = Math.max(0, 6 - Math.floor(((x - 119) * (x - 119)) / 160));
  fillRect(x, 61 + sag, 2, 3, 3);
  fillRect(x - 1, 64 + sag, 4, 3, 1);
}

floor(8, 136, 144);
fillRect(104, 108, 40, 2, 3);
for (let x = 104; x < 144; x += 8) {
  fillRect(x, 110, 4, 12, 1);
  fillRect(x + 4, 110, 4, 12, 2);
}
for (let x = 104; x < 144; x += 8) {
  fillRect(x, 122, 4, 3, 1);
  fillRect(x + 4, 122, 4, 5, 2);
}

writeFileSync('gfx/patio_vocabulary_review.png', encodePng());
