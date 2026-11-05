import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const shades = [255, 170, 85, 0];
const pixels = new Map([[' ', 0], ['.', 1], ['o', 2], ['#', 3]]);

const idleUpper = [
  '    #########   ',
  '    #.o.o.o.#   ',
  '    #.o.o.o.#   ',
  '    #.o.o.o.#   ',
  '    #########   ',
  '    #o.#..#.#   ',
  '    #o......#   ',
  '    #oo....o#   ',
];

const uncrackedEggRows = [
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
];

const carryUpper = [
  ' ## #########   ',
  '#..##.o.o.o.#   ',
  '#.o##.o.o.o.#   ',
  ' #.##.o.o.o.#   ',
  ' #.##########   ',
  ' #.##o.#..#.#   ',
  ' #.##o......#   ',
  '  ###oo....o#   ',
];

const reachLower = [
  '     #.ooo.#    ',
  '    #......#####',
  '   #..o........#',
  '   #..o....#####',
  '   #oo.ooo.#    ',
  '    #.####.#    ',
  '   ####  ####   ',
  '   ####  ####   ',
];

const carryIdleLower = [
  '  #.##.ooo.#    ',
  '  #.#......#    ',
  '    #.o.....#   ',
  '    #.o.....#   ',
  '    #o.ooo.o#   ',
  '    #.####.#    ',
  '   ####  ####   ',
  '   ####  ####   ',
];

const carryMove0Lower = [
  '  #.##.ooo.#    ',
  '  #.#......#    ',
  '    #.o.....#   ',
  '    #.o.....#   ',
  '    #o.ooo.o#   ',
  '     #.#####    ',
  '     #######    ',
  '     ####       ',
];

const carryMove1Lower = [
  '  #.##.ooo.#    ',
  '  #.#......#    ',
  '    #.o.....#   ',
  '    #.o.....#   ',
  '    #o.ooo.o#   ',
  '     ####.##    ',
  '      ######    ',
  '        ####    ',
];

const carryJumpLower = [
  '  #.##.ooo.#    ',
  '  #.#......#    ',
  '    #.o.....#   ',
  '    #.o.....#   ',
  '    #o.ooo.o#   ',
  '  ##..########  ',
  '  ####     ##   ',
  '  ##            ',
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
  const height = rows.length;
  const width = rows[0].length;
  const raw = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) {
    if (rows[y].length !== width) throw new Error('Rows must have equal widths');
    for (let x = 0; x < width; x++) {
      const shade = typeof rows[y][x] === 'number' ? rows[y][x] : pixels.get(rows[y][x]);
      if (shade === undefined) throw new Error(`Unknown pixel ${JSON.stringify(rows[y][x])}`);
      const offset = y * (1 + width * 4) + 1 + x * 4;
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

function frameFromRows(rows) {
  return rows.map(row => [...row].map(pixel => pixels.get(pixel)));
}

function draw(target, source, left, top) {
  for (let y = 0; y < source.length; y++) {
    for (let x = 0; x < source[y].length; x++) {
      if (source[y][x]) target[top + y][left + x] = source[y][x];
    }
  }
}

function flip(frame) {
  return frame.map(row => [...row].reverse());
}

function panel(base, carrying, facingLeft) {
  const canvas = Array.from({ length: 40 }, () => Array(32).fill(0));
  const chef = facingLeft ? flip(base) : base;
  if (carrying) {
    const egg = facingLeft ? flip(uncrackedEgg) : uncrackedEgg;
    draw(canvas, egg, 8, 1);
    draw(canvas, chef, 8, 17);
  } else {
    draw(canvas, chef, 4, 17);
  }
  return canvas;
}

function scale(frame, factor) {
  return frame.flatMap(row => Array.from({ length: factor }, () => row.flatMap(pixel => Array(factor).fill(pixel))));
}

const uncrackedEgg = frameFromRows(uncrackedEggRows);
const reachFrame = [
  ...frameFromRows(idleUpper),
  ...frameFromRows(reachLower),
];
const carryIdleFrame = frameFromRows([...carryUpper, ...carryIdleLower]);
const carryMove0Frame = frameFromRows([...carryUpper, ...carryMove0Lower]);
const carryMove1Frame = frameFromRows([...carryUpper, ...carryMove1Lower]);
const carryJumpFrame = frameFromRows([...carryUpper, ...carryJumpLower]);

const poses = [
  [reachFrame, false],
  [carryIdleFrame, true],
  [carryMove0Frame, true],
  [carryMove1Frame, true],
  [carryJumpFrame, true],
];
const sheet = Array.from({ length: 3 * 42 }, () => Array(4 * 34).fill(0));
for (let index = 0; index < poses.length; index++) {
  const row = Math.floor(index / 2);
  const column = (index % 2) * 2;
  const [base, carrying] = poses[index];
  draw(sheet, panel(base, carrying, false), column * 34, row * 42);
  draw(sheet, panel(base, carrying, true), (column + 1) * 34, row * 42);
}

writeFileSync('gfx/chef_heave_carry_upper.png', encodePng(carryUpper));
writeFileSync('gfx/chef_heave_reach_lower.png', encodePng(reachLower));
writeFileSync('gfx/chef_heave_carry_idle_lower.png', encodePng(carryIdleLower));
writeFileSync('gfx/chef_heave_carry_move0_lower.png', encodePng(carryMove0Lower));
writeFileSync('gfx/chef_heave_carry_move1_lower.png', encodePng(carryMove1Lower));
writeFileSync('gfx/chef_heave_carry_jump_lower.png', encodePng(carryJumpLower));
writeFileSync('gfx/chef_heave_review.png', encodePng(scale(sheet, 3)));
