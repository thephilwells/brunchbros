import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const width = 160;
const height = 144;
const shades = [255, 170, 85, 0];
const pixels = Array.from({ length: height }, () => Array(width).fill(0));

function fillRect(x, y, w, h, shade) {
  for (let row = y; row < y + h; row++) {
    for (let column = x; column < x + w; column++) pixels[row][column] = shade;
  }
}

function paintFoliage(centerX, baseY, radiusX, radiusY) {
  for (let y = baseY - radiusY; y <= baseY; y++) {
    for (let x = centerX - radiusX; x <= centerX + radiusX; x++) {
      const dx = (x - centerX) / radiusX;
      const dy = (y - (baseY - radiusY / 2)) / (radiusY / 2);
      if (dx * dx + dy * dy <= 1.15) pixels[y][x] = 1;
    }
  }
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
  const stride = 1 + width * 4;
  const raw = Buffer.alloc(height * stride);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const offset = y * stride + 1 + x * 4;
      raw.fill(shades[pixels[y][x]], offset, offset + 3);
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

fillRect(0, 0, width, height, 0);

for (const [x, y, w] of [[16, 18, 24], [88, 30, 32], [128, 12, 20]]) {
  fillRect(x + 4, y, w - 8, 2, 1);
  fillRect(x, y + 2, w, 2, 1);
  fillRect(x + 6, y + 4, w - 12, 1, 1);
}

for (const [x, y] of [[6, 70], [24, 62], [44, 68], [62, 58], [82, 72], [103, 64], [124, 70], [146, 60]]) {
  paintFoliage(x, 104, 15, 104 - y);
}

for (let y = 72; y < 104; y++) {
  for (let x = 0; x < width; x++) {
    if (pixels[y][x] === 1 && (x * 3 + y * 5) % 19 === 0) pixels[y][x] = 2;
  }
}

fillRect(0, 73, width, 2, 2);
fillRect(0, 88, width, 3, 2);
for (const x of [8, 40, 72, 104, 136]) {
  fillRect(x, 48, 4, 56, 2);
  fillRect(x, 48, 2, 56, 1);
  fillRect(x - 2, 46, 8, 3, 2);
}
for (let x = 4; x < width; x += 16) {
  pixels[73][x] = 1;
  pixels[88][x + 4] = 1;
}

fillRect(0, 104, width, 2, 3);
fillRect(0, 106, width, 2, 0);
fillRect(0, 108, width, 5, 1);
fillRect(0, 113, width, 31, 2);
for (const x of [24, 56, 88, 120, 152]) fillRect(x, 108, 2, 5, 3);
for (let y = 118; y < height; y += 8) {
  for (let x = (y % 16) + 4; x < width; x += 24) {
    fillRect(x, y, 4, 2, 1);
    pixels[y + 1][x + 4] = 3;
  }
}

writeFileSync('gfx/patio_background_review.png', encodePng());
