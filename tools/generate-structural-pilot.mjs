import { writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';

const width = 128;
const height = 64;
const shades = [255, 170, 85, 0];
const pixels = Buffer.alloc(width * height * 4, 255);

for (let mask = 0; mask < 16; mask++) {
  const tileId = mask + 1;
  const tileX = (tileId % 16) * 8;
  const tileY = Math.floor(tileId / 16) * 8;

  for (let y = 0; y < 8; y++) {
    for (let x = 0; x < 8; x++) {
      const exposed = (y === 0 && !(mask & 1)) ||
        (x === 7 && !(mask & 2)) ||
        (y === 7 && !(mask & 4)) ||
        (x === 0 && !(mask & 8));
      const grain = (x === 2 && y === 2) || (x === 5 && y === 5);
      const shade = exposed ? 3 : grain ? 1 : 2;
      const offset = ((tileY + y) * width + tileX + x) * 4;
      pixels.fill(shades[shade], offset, offset + 3);
    }
  }
}

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit++) {
    value = value & 1 ? (value >>> 1) ^ 0xedb88320 : value >>> 1;
  }
  return value >>> 0;
});

function chunk(type, data) {
  const name = Buffer.from(type);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  let crc = 0xffffffff;
  for (const byte of Buffer.concat([name, data])) {
    crc = (crc >>> 8) ^ crcTable[(crc ^ byte) & 255];
  }
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE((crc ^ 0xffffffff) >>> 0);
  return Buffer.concat([length, name, data, checksum]);
}

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(width, 0);
ihdr.writeUInt32BE(height, 4);
ihdr[8] = 8;
ihdr[9] = 6;
const rows = Buffer.alloc(height * (1 + width * 4));
for (let y = 0; y < height; y++) {
  pixels.copy(rows, y * (1 + width * 4) + 1, y * width * 4, (y + 1) * width * 4);
}
writeFileSync('gfx/structural_pilot.png', Buffer.concat([
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
  chunk('IHDR', ihdr),
  chunk('IDAT', deflateSync(rows)),
  chunk('IEND', Buffer.alloc(0)),
]));

const tiles = Array.from({ length: 128 }, (_, id) => {
  const assigned = id <= 16;
  const name = id === 0 ? 'empty' : assigned ? `solid_${id - 1}` : `reserved_${id}`;
  const properties = [
    `<property name="name" value="${name}"/>`,
    `<property name="collision" value="${assigned && id !== 0 ? 'solid' : 'empty'}"/>`,
    `<property name="role" value="${id === 0 ? 'empty' : assigned ? 'structure' : 'reserved'}"/>`,
  ];
  if (id > 0 && assigned) {
    properties.push(`<property name="neighbor_mask" type="int" value="${id - 1}"/>`);
  }
  return ` <tile id="${id}"><properties>${properties.join('')}</properties></tile>`;
});
writeFileSync('gfx/structural_pilot.tsx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<tileset version="1.10" tiledversion="1.12.2" name="structural_pilot" tilewidth="8" tileheight="8" tilecount="128" columns="16">',
  ' <image source="structural_pilot.png" width="128" height="64"/>',
  ...tiles,
  '</tileset>',
  '',
].join('\n'));

const solid = Array.from({ length: 32 }, () => Array(32).fill(false));
for (let mask = 0; mask < 16; mask++) {
  const x = 3 + (mask % 4) * 7;
  const y = 3 + Math.floor(mask / 4) * 7;
  solid[y][x] = true;
  if (mask & 1) solid[y - 1][x] = true;
  if (mask & 2) solid[y][x + 1] = true;
  if (mask & 4) solid[y + 1][x] = true;
  if (mask & 8) solid[y][x - 1] = true;
}
for (let x = 0; x < 32; x++) {
  solid[30][x] = true;
  solid[31][x] = true;
}

const ids = solid.map((row, y) => row.map((occupied, x) => {
  if (!occupied) return 0;
  return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < 31 && solid[y][x + 1] ? 2 : 0) +
    (y < 31 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
}));
writeFileSync('gfx/structural_fixture.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="32" height="32" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">',
  ' <tileset firstgid="1" source="structural_pilot.tsx"/>',
  ' <layer id="1" name="Terrain" width="32" height="32">',
  '  <data encoding="csv">',
  ids.map(row => row.map(id => id === 0 ? 0 : id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  '</map>',
  '',
].join('\n'));

writeFileSync('build/structural_fixture.tilemap', Buffer.from(ids.flat()));
