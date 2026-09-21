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

for (let id = 25; id <= 30; id++) fill(id, 1);
for (let y = 0; y < 24; y++) for (let x = 0; x < 16; x++) {
  const frame = (y === 0 && x >= 4 && x <= 11) ||
    (y === 1 && (x === 2 || x === 3 || x === 12 || x === 13)) ||
    (y >= 2 && (x === 1 || x === 14)) ||
    (y === 22 && x >= 1 && x <= 14) ||
    (y === 23 && x >= 0 && x <= 15);
  const interior = y >= 2 && y < 22 && x >= 2 && x <= 13;
  composite(25, 2, x, y, frame ? 3 : interior ? 2 : 1);
}
for (let y = 10; y <= 13; y++) for (let x = 6; x <= 9; x++) composite(25, 2, x, y, 0);
for (let y = 14; y <= 17; y++) {
  const inset = y - 14;
  for (let x = 4 + inset; x <= 11 - inset; x++) composite(25, 2, x, y, 0);
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

for (let id = 44; id <= 49; id++) fill(id, 1);
for (let y = 0; y < 16; y++) for (let x = 0; x < 16; x++) {
  const distance = (2 * x - 15) ** 2 + (2 * y - 15) ** 2;
  const shade = distance > 196 ? 1 : distance > 120 ? 2 : 0;
  composite(44, 2, x, y, shade);
}
for (const [x, y] of [[7, 3], [7, 4], [7, 7], [8, 8], [9, 8], [10, 8]]) composite(44, 2, x, y, 3);
for (const [x, y] of [[7, 2], [13, 7], [7, 13], [2, 7]]) composite(44, 2, x, y, 2);

for (let y = 2; y <= 7; y++) for (let x = 2; x <= 5; x++) paint(48, x, y, 0);
for (let y = 3; y <= 6; y++) {
  paint(48, 1, y, 2);
  paint(48, 6, y, 2);
}
for (let x = 2; x <= 5; x++) {
  paint(49, x, 1, 2);
  paint(49, x, 6, 2);
}
for (let y = 2; y <= 5; y++) {
  paint(49, 2, y, 2);
  paint(49, 5, y, 2);
}
paint(49, 3, 3, 3);
paint(49, 4, 3, 3);

fill(50, 1);
for (let x = 0; x < 8; x++) {
  paint(50, x, 0, 3);
  paint(50, x, 1, 0);
}
for (let x = 1; x < 7; x++) paint(50, x, 2, 2);

for (let id = 51; id <= 55; id++) fill(id, 1);
for (let id = 51; id <= 53; id++) {
  for (let x = 0; x < 8; x++) {
    paint(id, x, 0, 3);
    paint(id, x, 1, 0);
    paint(id, x, 2, 2);
    paint(id, x, 3, 2);
    paint(id, x, 4, 3);
  }
}
for (let y = 1; y <= 4; y++) {
  paint(51, 0, y, 3);
  paint(53, 7, y, 3);
}
for (const [top, leg, center] of [[51, 54, 4], [53, 55, 3]]) {
  for (let y = 5; y < 8; y++) {
    for (let x = center - 1; x <= center + 1; x++) paint(top, x, y, x === center ? 2 : 3);
  }
  for (let y = 0; y < 7; y++) {
    for (let x = center - 1; x <= center + 1; x++) paint(leg, x, y, x === center ? 2 : 3);
  }
  for (let x = center - 2; x <= center + 2; x++) paint(leg, x, 7, 3);
}

for (let id = 56; id <= 58; id++) fill(id, 1);
for (let x = 3; x < 8; x++) paint(56, x, 0, 3);
for (let x = 4; x < 7; x++) paint(56, x, 1, 0);
for (let y = 2; y < 8; y++) {
  paint(56, 5, y, 3);
  paint(56, 6, y, 2);
  paint(56, 7, y, 3);
}
for (let id = 57; id <= 58; id++) {
  for (let x = 0; x < 8; x++) {
    paint(id, x, 0, 3);
    paint(id, x, 1, 0);
    paint(id, x, 2, 2);
    paint(id, x, 3, 3);
  }
}
for (let y = 1; y <= 3; y++) {
  paint(57, 0, y, 3);
  paint(58, 7, y, 3);
}
for (const [id, center] of [[57, 2], [58, 5]]) {
  for (let y = 4; y < 7; y++) {
    paint(id, center, y, 3);
    paint(id, center + 1, y, 2);
  }
  for (let x = center - 1; x <= center + 2; x++) paint(id, x, 7, 3);
}

for (let id = 59; id <= 62; id++) fill(id, 2);
for (let id = 59; id <= 61; id++) {
  for (let x = 0; x < 8; x++) {
    paint(id, x, 0, 3);
    paint(id, x, 1, 0);
  }
  for (let x = 3; x <= 4; x++) paint(id, x, 4, 1);
}
for (let y = 0; y < 8; y++) {
  paint(59, 0, y, 3);
  paint(61, 7, y, 3);
}
for (const [x, y] of [[3, 2], [4, 2], [2, 3], [5, 3], [3, 4], [4, 4]]) paint(62, x, y, 1);
fill(63, 2);
for (let x = 0; x < 8; x++) {
  paint(63, x, 0, 3);
  paint(63, x, 1, 0);
  paint(63, x, 4, 3);
  paint(63, x, 7, 3);
}

for (let id = 64; id <= 75; id++) fill(id, 1);
for (let y = 0; y < 24; y++) for (let x = 0; x < 32; x++) {
  let shade = 1;
  if (x === 0 || x === 31 || y === 0 || y === 23) shade = 2;
  else if (x === 1 || x === 30 || y === 1 || y === 22) shade = 0;
  else if (x >= 3 && x <= 28 && y >= 4 && y <= 18) shade = 2;
  if (x >= 4 && x <= 27 && y === 5) shade = 1;
  if (x >= 13 && x <= 19 && y === 16) shade = 0;
  if (x >= 14 && x <= 18 && y === 17) shade = 0;
  if (x >= 15 && x <= 17 && y === 18) shade = 0;
  composite(64, 4, x, y, shade);
}

fill(80, 1);
for (const [x, y] of [[3, 2], [2, 3], [4, 3], [3, 4]]) paint(80, x, y, 0);
paint(80, 3, 3, 2);

for (let id = 112; id <= 115; id++) fill(id, 2);
for (let id = 112; id <= 114; id++) {
  for (let x = 0; x < 8; x++) {
    paint(id, x, 0, 3);
    paint(id, x, 1, 0);
    paint(id, x, 2, 0);
    paint(id, x, 4, 3);
  }
}
for (let y = 1; y < 8; y++) {
  paint(112, 0, y, 3);
  paint(114, 7, y, 3);
}
for (let y = 2; y < 6; y++) for (let x = 2; x < 6; x++) paint(115, x, y, 1);
for (let x = 0; x < 8; x++) paint(115, x, 7, 3);

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
const collisionKinds = { empty: 0, solid: 1, one_way: 2 };
const collisionTypes = Buffer.alloc(128);
const tiles = Array.from({ length: 128 }, (_, id) => {
  let name = `reserved_${id}`;
  let role = 'reserved';
  let collision = 'empty';
  const properties = [];
  if (id === 0) { name = 'empty'; role = 'empty'; }
  else if (id <= 16) { name = `solid_${id - 1}`; role = 'structure'; collision = 'solid'; }
  else if (id <= 20) { name = rearNames[id - 17]; role = 'rear'; }
  else if (id <= 24) { name = trimNames[id - 21]; role = 'trim'; }
  else if (id <= 30) {
    name = `descent_exit_${id - 25}`;
    role = 'exit';
    properties.push('<property name="component" value="descent_exit"/>');
    properties.push(`<property name="part_x" type="int" value="${(id - 25) % 2}"/>`);
    properties.push(`<property name="part_y" type="int" value="${Math.floor((id - 25) / 2)}"/>`);
    properties.push('<property name="interaction" value="press_down"/>');
  } else if (id >= 32 && id <= 39) {
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
  } else if (id >= 44 && id <= 47) {
    name = `wall_clock_${id - 44}`;
    role = 'fixture';
    properties.push('<property name="component" value="wall_clock"/>');
    properties.push(`<property name="part_x" type="int" value="${(id - 44) % 2}"/>`);
    properties.push(`<property name="part_y" type="int" value="${Math.floor((id - 44) / 2)}"/>`);
  } else if (id >= 48 && id <= 49) {
    name = `wall_sconce_${id - 48}`;
    role = 'fixture';
    properties.push('<property name="component" value="wall_sconce"/>');
    properties.push('<property name="part_x" type="int" value="0"/>');
    properties.push(`<property name="part_y" type="int" value="${id - 48}"/>`);
  } else if (id === 50) {
    name = 'one_way_test_top';
    role = 'platform_test';
    collision = 'one_way';
  } else if (id >= 51 && id <= 55) {
    name = ['table_top_left', 'table_top_middle', 'table_top_right', 'table_leg_left', 'table_leg_right'][id - 51];
    role = 'fixture';
    collision = id <= 53 ? 'one_way' : 'empty';
    properties.push('<property name="component" value="dining_table"/>');
  } else if (id >= 56 && id <= 58) {
    name = ['chair_back_right', 'chair_seat_left', 'chair_seat_right'][id - 56];
    role = 'fixture';
    collision = id === 56 ? 'empty' : 'one_way';
    properties.push('<property name="component" value="dining_chair"/>');
  } else if (id >= 59 && id <= 63) {
    name = ['booth_back_left', 'booth_back_middle', 'booth_back_right', 'booth_back_lower', 'booth_seat'][id - 59];
    role = 'fixture';
    collision = id === 63 ? 'one_way' : 'empty';
    properties.push('<property name="component" value="dining_booth"/>');
  } else if (id >= 64 && id <= 75) {
    name = `serving_hatch_${id - 64}`;
    role = 'landmark';
    properties.push('<property name="component" value="serving_hatch"/>');
    properties.push(`<property name="part_x" type="int" value="${(id - 64) % 4}"/>`);
    properties.push(`<property name="part_y" type="int" value="${Math.floor((id - 64) / 4)}"/>`);
  } else if (id === 80) {
    name = 'dining_wallpaper_motif';
    role = 'rear';
  } else if (id >= 112 && id <= 115) {
    name = ['counter_top_left', 'counter_top_middle', 'counter_top_right', 'counter_front'][id - 112];
    role = 'fixture';
    collision = id <= 114 ? 'one_way' : 'empty';
    properties.push('<property name="component" value="dining_counter"/>');
  }
  properties.unshift(
    `<property name="name" value="${name}"/>`,
    `<property name="collision" value="${collision}"/>`,
    `<property name="role" value="${role}"/>`,
  );
  if (id >= 1 && id <= 16) properties.push(`<property name="neighbor_mask" type="int" value="${id - 1}"/>`);
  collisionTypes[id] = collisionKinds[collision];
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
writeFileSync('build/dining_room_collision.bin', collisionTypes);

const solid = Array.from({ length: 32 }, () => Array(32).fill(false));
for (let y = 27; y < 32; y++) for (let x = 0; x < 32; x++) solid[y][x] = true;
for (let x = 1; x <= 7; x++) solid[20][x] = true;
for (let x = 20; x <= 25; x++) solid[21][x] = true;
for (let y = 22; y <= 26; y++) solid[y][25] = true;

const ids = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < 31 && solid[y][x + 1] ? 2 : 0) +
    (y < 31 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (x >= 27 && x <= 30 && y >= 7 && y <= 9) return 20;
  if ((y <= 10 && (x <= 9 || x >= 22)) || (y >= 20 && y <= 26 && x <= 19)) {
    return x % 4 === 1 && y % 3 === 1 ? 80 : 17;
  }
  if ((x + y * 3) % 17 === 0) return 18;
  if ((x * 3 + y) % 23 === 0) return 19;
  return 17;
}));

function place(x, y, id) {
  if (solid[y][x]) throw new Error(`Fixture overlaps solid tile at ${x},${y}`);
  ids[y][x] = id;
}

function placeComponent(x, y, id, tileWidth, tileHeight) {
  for (let row = 0; row < tileHeight; row++) {
    for (let column = 0; column < tileWidth; column++) {
      place(x + column, y + row, id + row * tileWidth + column);
    }
  }
}

for (let x = 0; x < 32; x++) place(x, 11, x === 0 ? 21 : x === 31 ? 23 : 22);
place(18, 4, 24);
placeComponent(3, 4, 32, 4, 2);
placeComponent(24, 4, 40, 2, 2);
placeComponent(8, 4, 44, 2, 2);
placeComponent(19, 4, 48, 1, 2);
placeComponent(13, 3, 64, 4, 3);
placeComponent(1, 22, 32, 4, 2);
placeComponent(6, 22, 44, 2, 2);
placeComponent(9, 21, 64, 4, 3);
placeComponent(14, 22, 48, 1, 2);
placeComponent(16, 22, 40, 2, 2);
for (let x = 9; x <= 12; x++) place(x, 24, 50);
for (const [x, id] of [[14, 51], [15, 52], [16, 52], [17, 53]]) place(x, 25, id);
place(14, 26, 54);
place(15, 26, 17);
place(16, 26, 17);
place(17, 26, 55);
place(19, 25, 17);
place(20, 25, 56);
place(19, 26, 57);
place(20, 26, 58);
for (const [x, id] of [[2, 59], [3, 60], [4, 60], [5, 61]]) place(x, 24, id);
for (let x = 2; x <= 5; x++) {
  place(x, 25, 62);
  place(x, 26, 63);
}
for (const [x, id] of [[21, 112], [22, 113], [23, 113], [24, 114]]) place(x, 25, id);
for (let x = 21; x <= 24; x++) place(x, 26, 115);
placeComponent(28, 24, 25, 2, 3);

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
