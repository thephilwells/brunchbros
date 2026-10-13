import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const palette = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);
const idle = [
  '    ########    ',
  '  ##........##  ',
  ' #..oooooooo..# ',
  '#.oo#oooo#oooo.#',
  '#.oooooooooooo.#',
  '#.ooooo##ooooo.#',
  ' #..oooooooo..# ',
  '  ############  ',
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

function distanceToSegment(x, y, start, end) {
  const dx = end[0] - start[0];
  const dy = end[1] - start[1];
  const projection = Math.max(0, Math.min(1, ((x - start[0]) * dx + (y - start[1]) * dy) / (dx * dx + dy * dy)));
  return Math.hypot(x - start[0] - projection * dx, y - start[1] - projection * dy);
}

function makePose(points) {
  const pixels = Array.from({ length: 16 }, () => Array(16).fill(' '));
  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      let distance = Infinity;
      for (let segment = 1; segment < points.length; segment++) {
        distance = Math.min(distance, distanceToSegment(x, y, points[segment - 1], points[segment]));
      }
      if (distance <= 3.5) pixels[y][x] = '#';
      if (distance <= 2.4) pixels[y][x] = 'o';
    }
  }

  for (const [x, y] of points.slice(1, -1)) {
    if (pixels[y]?.[x] === 'o') pixels[y][x] = '.';
  }

  const tip = points.at(-1);
  const previous = points.at(-2);
  const dx = tip[0] - previous[0];
  const dy = tip[1] - previous[1];
  const length = Math.hypot(dx, dy);
  const forwardX = dx / length;
  const forwardY = dy / length;
  const normalX = -forwardY;
  const normalY = forwardX;
  const faceX = Math.round(tip[0] + forwardX);
  const faceY = Math.round(tip[1] + forwardY);
  for (let offset = -1; offset <= 1; offset++) {
    const x = Math.round(faceX + normalX * offset);
    const y = Math.round(faceY + normalY * offset);
    if (pixels[y]?.[x] !== undefined) pixels[y][x] = '.';
  }
  for (const offset of [-1, 1]) {
    const x = Math.round(faceX + normalX * offset);
    const y = Math.round(faceY + normalY * offset);
    if (pixels[y]?.[x] !== undefined) pixels[y][x] = '#';
  }
  return pixels.map(row => row.join(''));
}

function rotateClockwise(points) {
  return points.map(([x, y]) => [15 - y, x]);
}

const horizontal = [
  [[3, 12], [12, 12]],
  [[3, 12], [5, 8], [8, 7], [10, 9], [12, 12]],
  [[3, 12], [5, 7], [8, 4], [11, 7], [12, 12]],
  [[3, 12], [6, 11], [9, 8], [11, 10], [13, 12]],
];
const vertical = horizontal.map(rotateClockwise);
const turns = [
  [[4, 12], [9, 12], [12, 10], [12, 5]],
  [[5, 13], [9, 12], [11, 9], [11, 4]],
  [[4, 5], [9, 5], [12, 8], [12, 13]],
  [[5, 4], [9, 5], [11, 8], [11, 13]],
];
const poses = [...horizontal, ...vertical, ...turns].map(makePose);
const motion = horizontal.flatMap(makePose);
const review = [];
for (let row = 0; row < 3; row++) {
  for (let y = 0; y < 16; y++) review.push(poses.slice(row * 4, row * 4 + 4).map(pose => pose[y]).join(''));
}

writeFileSync('gfx/weiner_idle.png', encodePng(idle));
writeFileSync('gfx/weiner_motion.png', encodePng(motion));
writeFileSync('gfx/weiner_motion_review.png', encodePng(review));
