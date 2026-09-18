import { readFileSync, writeFileSync } from 'node:fs';
import { deflateSync, inflateSync } from 'node:zlib';

const width = 128;
const height = 64;
const shades = [255, 170, 85, 0];
const pilot = readFileSync('gfx/structural_pilot.png');
const compressed = [];
for (let offset = 8; offset < pilot.length;) {
  const length = pilot.readUInt32BE(offset);
  const type = pilot.toString('ascii', offset + 4, offset + 8);
  if (type === 'IDAT') compressed.push(pilot.subarray(offset + 8, offset + 8 + length));
  offset += length + 12;
}
const sourceRows = inflateSync(Buffer.concat(compressed));
const pixels = Buffer.alloc(width * height * 4);
for (let y = 0; y < height; y++) {
  sourceRows.copy(pixels, y * width * 4, y * (1 + width * 4) + 1, (y + 1) * (1 + width * 4));
}

function paint(id, x, y, shade) {
  const pixelX = (id % 16) * 8 + x;
  const pixelY = Math.floor(id / 16) * 8 + y;
  const offset = (pixelY * width + pixelX) * 4;
  pixels.fill(shades[shade], offset, offset + 3);
}

function fill(id, shade) {
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) paint(id, x, y, shade);
}

fill(17, 1);
fill(18, 1);
paint(18, 2, 2, 0);
paint(18, 5, 5, 2);
fill(19, 1);
paint(19, 5, 2, 0);
paint(19, 2, 5, 2);
fill(20, 2);
paint(20, 2, 2, 1);
paint(20, 5, 5, 1);

for (let id = 21; id <= 24; id++) {
  fill(id, 1);
  for (let x = 0; x < 8; x++) {
    paint(id, x, 3, 0);
    paint(id, x, 4, 2);
    paint(id, x, 5, 2);
  }
  if (id === 21 || id === 24) for (let y = 2; y < 7; y++) paint(id, 1, y, 2);
  if (id === 23 || id === 24) for (let y = 2; y < 7; y++) paint(id, 6, y, 2);
}

function composite(base, tileWidth, x, y, shade) {
  paint(base + Math.floor(y / 8) * tileWidth + Math.floor(x / 8), x % 8, y % 8, shade);
}

for (let id = 32; id <= 43; id++) fill(id, 1);
for (let y = 0; y < 16; y++) for (let x = 0; x < 32; x++) {
  if (x === 0 || x === 31 || y === 0 || y === 15) composite(32, 4, x, y, 2);
  else if (x === 1 || x === 30 || y === 1 || y === 14) composite(32, 4, x, y, 1);
  else composite(32, 4, x, y, 2);
}
for (let row = 0; row < 2; row++) {
  const y = row === 0 ? 5 : 10;
  for (let x = 4; x <= 7; x++) composite(32, 4, x, y, 0);
  for (let x = 11; x <= 14; x += 2) composite(32, 4, x, y, 1);
  for (let x = 19; x <= 22; x++) composite(32, 4, x, y, 0);
  for (let x = 26; x <= 28; x += 2) composite(32, 4, x, y, 1);
}
composite(32, 4, 5, 4, 0);
composite(32, 4, 20, 4, 0);
composite(32, 4, 5, 9, 0);
composite(32, 4, 20, 9, 0);

for (let y = 0; y < 16; y++) for (let x = 0; x < 16; x++) {
  let shade = 1;
  if (x === 0 || x === 15 || y === 0 || y === 15) shade = 2;
  else if (x >= 2 && x <= 13 && y >= 2 && y <= 13) shade = 0;
  if (x >= 3 && x <= 12 && y >= 3 && y <= 12 && (x + y === 13 || x + y === 14 || x + y === 20)) shade = 1;
  composite(40, 2, x, y, shade);
}

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit++) value = value & 1 ? (value >>> 1) ^ 0xedb88320 : value >>> 1;
  return value >>> 0;
});

function chunk(type, data) {
  const name = Buffer.from(type);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  let crc = 0xffffffff;
  for (const byte of Buffer.concat([name, data])) crc = (crc >>> 8) ^ crcTable[(crc ^ byte) & 255];
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE((crc ^ 0xffffffff) >>> 0);
  return Buffer.concat([length, name, data, checksum]);
}

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(width, 0);
ihdr.writeUInt32BE(height, 4);
ihdr[8] = 8;
ihdr[9] = 6;
const pngRows = Buffer.alloc(height * (1 + width * 4));
for (let y = 0; y < height; y++) pixels.copy(pngRows, y * (1 + width * 4) + 1, y * width * 4, (y + 1) * width * 4);
writeFileSync('gfx/dining_room.png', Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', ihdr),
  chunk('IDAT', deflateSync(pngRows)),
  chunk('IEND', Buffer.alloc(0)),
]));

const rearNames = ['rear_plain', 'rear_texture_a', 'rear_texture_b', 'rear_recess'];
const trimNames = ['trim_h_left', 'trim_h_middle', 'trim_h_right', 'trim_h_single'];
const tiles = Array.from({ length: 128 }, (_, id) => {
  let name = `reserved_${id}`;
  let role = 'reserved';
  let collision = 'empty';
  const properties = [];
  if (id === 0) { name = 'empty'; role = 'empty'; }
  else if (id <= 16) { name = `solid_${id - 1}`; role = 'structure'; collision = 'solid'; }
  else if (id <= 20) { name = rearNames[id - 17]; role = 'rear'; }
  else if (id <= 24) { name = trimNames[id - 21]; role = 'trim'; }
  else if (id >= 32 && id <= 39) {
    name = `menu_board_${id - 32}`;
    role = 'fixture';
    properties.push('<property name="component" value="menu_board"/>');
    properties.push(`<property name="part_x" type="int" value="${(id - 32) % 4}"/>`);
    properties.push(`<property name="part_y" type="int" value="${Math.floor((id - 32) / 4)}"/>`);
  } else if (id >= 40 && id <= 43) {
    name = `wall_mirror_${id - 40}`;
    role = 'fixture';
    properties.push('<property name="component" value="wall_mirror"/>');
    properties.push(`<property name="part_x" type="int" value="${(id - 40) % 2}"/>`);
    properties.push(`<property name="part_y" type="int" value="${Math.floor((id - 40) / 2)}"/>`);
  }
  properties.unshift(
    `<property name="name" value="${name}"/>`,
    `<property name="collision" value="${collision}"/>`,
    `<property name="role" value="${role}"/>`,
  );
  if (id >= 1 && id <= 16) properties.push(`<property name="neighbor_mask" type="int" value="${id - 1}"/>`);
  return ` <tile id="${id}"><properties>${properties.join('')}</properties></tile>`;
});
writeFileSync('gfx/dining_room.tsx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<tileset version="1.10" tiledversion="1.12.2" name="dining_room" tilewidth="8" tileheight="8" tilecount="128" columns="16">',
  ' <image source="dining_room.png" width="128" height="64"/>',
  ...tiles,
  '</tileset>',
  '',
].join('\n'));

const solid = Array.from({ length: 32 }, () => Array(32).fill(false));
for (let y = 27; y < 32; y++) for (let x = 0; x < 32; x++) solid[y][x] = true;
for (let x = 8; x <= 14; x++) solid[18][x] = true;
for (let x = 20; x <= 25; x++) solid[21][x] = true;
for (let y = 22; y <= 26; y++) solid[y][25] = true;

const ids = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < 31 && solid[y][x + 1] ? 2 : 0) +
    (y < 31 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (x >= 12 && x <= 15 && y >= 5 && y <= 7) return 20;
  if ((x + y * 3) % 17 === 0) return 18;
  if ((x * 3 + y) % 23 === 0) return 19;
  return 17;
}));

function place(x, y, id) {
  if (solid[y][x]) throw new Error(`Fixture overlaps solid tile at ${x},${y}`);
  ids[y][x] = id;
}

for (let x = 0; x < 32; x++) place(x, 11, x === 0 ? 21 : x === 31 ? 23 : 22);
place(18, 4, 24);
for (let y = 0; y < 2; y++) for (let x = 0; x < 4; x++) place(3 + x, 4 + y, 32 + y * 4 + x);
for (let y = 0; y < 2; y++) for (let x = 0; x < 2; x++) place(24 + x, 4 + y, 40 + y * 2 + x);

writeFileSync('gfx/dining_room_fixture.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="32" height="32" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">',
  ' <tileset firstgid="1" source="dining_room.tsx"/>',
  ' <layer id="1" name="Terrain" width="32" height="32">',
  '  <data encoding="csv">',
  ids.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  '</map>',
  '',
].join('\n'));
writeFileSync('build/dining_room_fixture.tilemap', Buffer.from(ids.flat()));
