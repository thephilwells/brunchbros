import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];

function makeCanvas(width, height, shade = 0) {
  return {
    width,
    height,
    pixels: Array.from({ length: height }, () => Array(width).fill(shade)),
  };
}

function fillRect(canvas, x, y, width, height, shade) {
  const left = Math.max(0, x);
  const top = Math.max(0, y);
  const right = Math.min(canvas.width, x + width);
  const bottom = Math.min(canvas.height, y + height);
  for (let row = top; row < bottom; row++) {
    for (let column = left; column < right; column++) canvas.pixels[row][column] = shade;
  }
}

function drawCloud(canvas, x, y, width) {
  fillRect(canvas, x + 8, y, width - 16, 2, 1);
  fillRect(canvas, x, y + 2, width, 3, 1);
  fillRect(canvas, x + 6, y + 5, width - 12, 1, 1);
}

function drawFoliage(canvas, centerX, baseY, radiusX, radiusY) {
  for (let y = baseY - radiusY; y <= baseY; y++) {
    for (let x = centerX - radiusX; x <= centerX + radiusX; x++) {
      const dx = (x - centerX) / radiusX;
      const dy = (y - (baseY - radiusY / 2)) / (radiusY / 2);
      if (dx * dx + dy * dy <= 1.15) canvas.pixels[y][x] = 1;
    }
  }
}

function drawMasonry(canvas, x, y, width, height) {
  fillRect(canvas, x, y, width, height, 2);
  fillRect(canvas, x, y, width, 2, 3);
  fillRect(canvas, x, y + 2, width, 2, 0);
  fillRect(canvas, x, y + 4, width, 4, 1);
  fillRect(canvas, x, y + 8, width, 1, 3);
  fillRect(canvas, x, y, 2, height, 3);
  fillRect(canvas, x + width - 2, y, 2, height, 3);
  for (let row = y + 16; row < y + height; row += 16) {
    fillRect(canvas, x + 2, row, width - 4, 1, 1);
    const offset = ((row - y) / 16) % 2 === 0 ? 16 : 32;
    for (let column = x + offset; column < x + width - 2; column += 48) {
      fillRect(canvas, column, row - 7, 1, 7, 1);
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

function encodePng(canvas) {
  const stride = 1 + canvas.width * 4;
  const raw = Buffer.alloc(canvas.height * stride);
  for (let y = 0; y < canvas.height; y++) {
    for (let x = 0; x < canvas.width; x++) {
      const offset = y * stride + 1 + x * 4;
      raw.fill(shades[canvas.pixels[y][x]], offset, offset + 3);
      raw[offset + 3] = 255;
    }
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(canvas.width, 0);
  header.writeUInt32BE(canvas.height, 4);
  header[8] = 8;
  header[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function crop(source, x, y, width, height) {
  const result = makeCanvas(width, height);
  for (let row = 0; row < height; row++) {
    for (let column = 0; column < width; column++) {
      result.pixels[row][column] = source.pixels[y + row][x + column];
    }
  }
  return result;
}

const world = makeCanvas(320, 256);

for (const cloud of [
  [16, 16, 32], [96, 32, 24], [184, 12, 40], [264, 42, 32],
  [48, 82, 40], [152, 100, 24], [232, 76, 48],
  [8, 136, 24], [112, 148, 40], [280, 132, 24],
]) drawCloud(world, ...cloud);

for (const [x, top] of [
  [8, 208], [32, 198], [58, 204], [86, 194], [116, 202], [146, 190],
  [176, 204], [204, 196], [234, 202], [264, 192], [294, 200], [316, 194],
]) drawFoliage(world, x, 240, 18, 240 - top);

for (let y = 200; y < 240; y++) {
  for (let x = 0; x < 320; x++) {
    if (world.pixels[y][x] === 1 && (x * 3 + y * 5) % 23 === 0) world.pixels[y][x] = 2;
  }
}

fillRect(world, 0, 208, 320, 2, 2);
fillRect(world, 0, 224, 320, 3, 2);
for (const x of [8, 56, 104, 152, 200, 248, 296]) {
  fillRect(world, x, 184, 4, 56, 2);
  fillRect(world, x, 184, 2, 56, 1);
  fillRect(world, x - 2, 182, 8, 3, 2);
}

drawMasonry(world, 0, 56, 72, 16);
drawMasonry(world, 112, 56, 96, 24);
drawMasonry(world, 248, 56, 72, 16);
drawMasonry(world, 64, 56, 16, 64);
drawMasonry(world, 200, 56, 16, 64);

drawMasonry(world, 0, 120, 32, 16);
drawMasonry(world, 32, 120, 112, 24);
drawMasonry(world, 184, 120, 104, 16);
drawMasonry(world, 312, 120, 8, 64);
drawMasonry(world, 128, 120, 16, 64);

drawMasonry(world, 0, 184, 88, 24);
drawMasonry(world, 128, 184, 104, 16);
drawMasonry(world, 272, 184, 48, 24);
drawMasonry(world, 80, 184, 16, 56);
drawMasonry(world, 224, 184, 16, 56);

drawMasonry(world, 0, 240, 320, 16);

writeFileSync('gfx/patio_world_review.png', encodePng(world));
writeFileSync('gfx/patio_world_review_upper.png', encodePng(crop(world, 80, 0, 160, 144)));
writeFileSync('gfx/patio_world_review_lower.png', encodePng(crop(world, 160, 112, 160, 144)));
