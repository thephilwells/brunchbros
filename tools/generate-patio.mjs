import { readFileSync, writeFileSync } from 'node:fs';
import { deflateSync, inflateSync } from 'node:zlib';

const atlasWidth = 128;
const atlasHeight = 64;
const fixtureWidth = 40;
const fixtureHeight = 32;
const shades = [255, 170, 85, 0];
const pixels = Buffer.alloc(atlasWidth * atlasHeight * 4, 255);

function paint(id, x, y, shade) {
  const pixelX = (id % 16) * 8 + x;
  const pixelY = Math.floor(id / 16) * 8 + y;
  const offset = (pixelY * atlasWidth + pixelX) * 4;
  pixels.fill(shades[shade], offset, offset + 3);
  pixels[offset + 3] = 255;
}

function fill(id, shade) {
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) paint(id, x, y, shade);
}

function readPng(path) {
  const png = readFileSync(path);
  const chunks = [];
  let width;
  let height;
  for (let offset = 8; offset < png.length;) {
    const length = png.readUInt32BE(offset);
    const type = png.toString('ascii', offset + 4, offset + 8);
    if (type === 'IHDR') {
      width = png.readUInt32BE(offset + 8);
      height = png.readUInt32BE(offset + 12);
    }
    if (type === 'IDAT') chunks.push(png.subarray(offset + 8, offset + 8 + length));
    offset += length + 12;
  }
  const rows = inflateSync(Buffer.concat(chunks));
  const result = Buffer.alloc(width * height * 4);
  for (let y = 0; y < height; y++) {
    const rowOffset = y * (1 + width * 4);
    if (rows[rowOffset] !== 0) throw new Error(`${path} uses an unsupported PNG filter`);
    rows.copy(result, y * width * 4, rowOffset + 1, rowOffset + 1 + width * 4);
  }
  return { width, height, pixels: result };
}

function copyTile(source, id) {
  const sourceX = (id % 16) * 8;
  const sourceY = Math.floor(id / 16) * 8;
  for (let y = 0; y < 8; y++) {
    const sourceOffset = ((sourceY + y) * source.width + sourceX) * 4;
    const targetOffset = ((sourceY + y) * atlasWidth + sourceX) * 4;
    source.pixels.copy(pixels, targetOffset, sourceOffset, sourceOffset + 32);
  }
}

for (let mask = 0; mask < 16; mask++) {
  const id = mask + 1;
  fill(id, 2);
  for (let x = 0; x < 8; x++) paint(id, x, 5, 1);
  for (let y = 3; y < 5; y++) paint(id, 3, y, 1);
  for (let y = 6; y < 8; y++) paint(id, 6, y, 1);
  if (!(mask & 1)) {
    for (let x = 0; x < 8; x++) {
      paint(id, x, 0, 3);
      paint(id, x, 1, 0);
      paint(id, x, 2, 1);
    }
  }
  if (!(mask & 2)) for (let y = 0; y < 8; y++) paint(id, 7, y, 3);
  if (!(mask & 4)) for (let x = 0; x < 8; x++) paint(id, x, 7, 3);
  if (!(mask & 8)) for (let y = 0; y < 8; y++) paint(id, 0, y, 3);
}

for (let id = 17; id <= 42; id++) fill(id, 0);

for (const [x, y] of [[5, 2], [6, 2], [3, 3], [4, 3], [5, 3], [6, 3], [7, 3], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [3, 5], [4, 5], [5, 5], [6, 5], [7, 5]]) paint(18, x, y, 1);
for (const [x, y] of [[1, 2], [2, 2], [3, 2], [4, 2], [5, 2], [6, 2], [0, 3], [1, 3], [2, 3], [3, 3], [4, 3], [5, 3], [6, 3], [7, 3], [0, 4], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [1, 5], [2, 5], [3, 5], [4, 5], [5, 5], [6, 5]]) paint(19, x, y, 1);
for (const [x, y] of [[0, 2], [1, 2], [0, 3], [1, 3], [2, 3], [3, 3], [4, 3], [0, 4], [1, 4], [2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [0, 5], [1, 5], [2, 5], [3, 5], [4, 5]]) paint(20, x, y, 1);

for (let x = 0; x < 8; x++) {
  paint(21, x, 2, 2);
  paint(21, x, 3, 2);
  paint(22, x, 2, 2);
  paint(22, x, 3, 2);
  paint(23, x, 2, 2);
  paint(23, x, 3, 2);
  paint(24, x, 2, 2);
  paint(24, x, 3, 2);
}
for (let y = 1; y < 7; y++) paint(21, 0, y, 3);
for (let y = 1; y < 7; y++) paint(23, 7, y, 3);
for (let y = 1; y < 7; y++) {
  paint(24, 0, y, 3);
  paint(24, 7, y, 3);
}

for (let y = 1; y < 8; y++) {
  paint(31, 3, y, 2);
  paint(31, 4, y, 2);
}
for (let x = 1; x < 7; x++) paint(31, x, 0, 2);

function foliageTop(id, phase) {
  fill(id, 0);
  const heights = phase === 0 ? [5, 4, 3, 3, 2, 3, 4, 4] : [4, 3, 4, 2, 2, 3, 3, 5];
  for (let x = 0; x < 8; x++) for (let y = heights[x]; y < 8; y++) paint(id, x, y, 1);
  for (const [x, y] of phase === 0 ? [[2, 6], [6, 5]] : [[1, 5], [5, 6]]) paint(id, x, y, 2);
}

function foliageFill(id, phase) {
  fill(id, 1);
  for (const [x, y] of phase === 0 ? [[2, 2], [6, 5]] : [[1, 5], [5, 2]]) paint(id, x, y, 2);
}

foliageTop(32, 0);
foliageTop(33, 1);
foliageFill(34, 0);
foliageFill(35, 1);
for (let id = 36; id <= 41; id++) {
  if ([36, 38, 40].includes(id)) foliageTop(id, id === 36 ? 0 : 1);
  else foliageFill(id, id === 37 ? 0 : 1);
}
for (const id of [36, 37, 40, 41]) for (let x = 0; x < 8; x++) {
  paint(id, x, 2, 2);
  paint(id, x, 3, 2);
}
for (const id of [38, 39, 40, 41]) for (let y = 0; y < 8; y++) {
  paint(id, 3, y, 2);
  paint(id, 4, y, 2);
}
for (const id of [40, 41]) for (let x = 1; x < 7; x++) paint(id, x, 0, 2);

for (let x = 0; x < 8; x++) {
  paint(42, x, 2, 2);
  paint(42, x, 3, 2);
}
for (const [x, y] of [[2, 7], [3, 6], [4, 6], [5, 7]]) paint(42, x, y, 1);
paint(42, 3, 7, 2);
paint(42, 4, 7, 2);

const dining = readPng('gfx/dining_room.png');
for (const id of [...Array.from({ length: 6 }, (_, index) => 25 + index), ...Array.from({ length: 6 }, (_, index) => 81 + index), ...Array.from({ length: 12 }, (_, index) => 116 + index)]) copyTile(dining, id);
const diningTsx = readFileSync('gfx/dining_room.tsx', 'utf8');
const sharedProperties = new Map([...diningTsx.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)].map(([, id, properties]) => [Number(id), properties]));

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

function encodePng(width, height, rgba) {
  const rows = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) rgba.copy(rows, y * (1 + width * 4) + 1, y * width * 4, (y + 1) * width * 4);
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

const metadata = new Map([
  [0, ['sky_empty', 'empty', 'empty']],
  [17, ['sky_plain', 'empty', 'rear']],
  [18, ['cloud_left', 'empty', 'rear']],
  [19, ['cloud_middle', 'empty', 'rear']],
  [20, ['cloud_right', 'empty', 'rear']],
  [21, ['fence_rail_left', 'empty', 'rear']],
  [22, ['fence_rail_middle', 'empty', 'rear']],
  [23, ['fence_rail_right', 'empty', 'rear']],
  [24, ['fence_rail_single', 'empty', 'rear']],
  [31, ['fence_post_sky', 'empty', 'rear']],
  [32, ['foliage_top_a', 'empty', 'rear']],
  [33, ['foliage_top_b', 'empty', 'rear']],
  [34, ['foliage_fill_a', 'empty', 'rear']],
  [35, ['foliage_fill_b', 'empty', 'rear']],
  [36, ['foliage_top_rail', 'empty', 'rear']],
  [37, ['foliage_fill_rail', 'empty', 'rear']],
  [38, ['foliage_top_post', 'empty', 'rear']],
  [39, ['foliage_fill_post', 'empty', 'rear']],
  [40, ['foliage_top_post_rail', 'empty', 'rear']],
  [41, ['foliage_fill_post_rail', 'empty', 'rear']],
  [42, ['foliage_divot_rail', 'empty', 'rear']],
]);
for (let id = 1; id <= 16; id++) metadata.set(id, [`masonry_${id - 1}`, 'solid', 'structure']);
for (let id = 25; id <= 30; id++) metadata.set(id, [`exit_locked_${id - 25}`, 'empty', 'exit_locked']);
for (let id = 81; id <= 86; id++) metadata.set(id, [`exit_open_${id - 81}`, 'empty', 'exit_open']);
for (const [index, letter] of ['A', 'B', 'C', 'E', 'H', 'N', 'O', 'P', 'R', 'S', 'T', 'U'].entries()) metadata.set(116 + index, [`title_${letter}`, 'empty', 'font']);

const tileXml = Array.from({ length: 128 }, (_, id) => {
  if (sharedProperties.has(id) && ((id >= 25 && id <= 30) || (id >= 81 && id <= 86) || id >= 116)) {
    return ` <tile id="${id}"><properties>${sharedProperties.get(id)}</properties></tile>`;
  }
  const [name, collision, role] = metadata.get(id) ?? [`reserved_${id}`, 'empty', 'reserved'];
  const properties = [
    `<property name="name" value="${name}"/>`,
    `<property name="collision" value="${collision}"/>`,
    `<property name="role" value="${role}"/>`,
  ];
  if (id >= 1 && id <= 16) properties.push(`<property name="neighbor_mask" type="int" value="${id - 1}"/>`);
  return ` <tile id="${id}"><properties>${properties.join('')}</properties></tile>`;
});

const solid = Array.from({ length: fixtureHeight }, () => Array(fixtureWidth).fill(false));
function solidRect(x, y, width, height) {
  for (let row = y; row < y + height; row++) for (let column = x; column < x + width; column++) solid[row][column] = true;
}
solidRect(0, 7, 9, 2);
solidRect(8, 7, 2, 8);
solidRect(14, 7, 12, 3);
solidRect(25, 7, 2, 8);
solidRect(31, 7, 9, 2);
solidRect(0, 15, 4, 2);
solidRect(4, 15, 14, 3);
solidRect(16, 15, 2, 8);
solidRect(23, 15, 13, 2);
solidRect(35, 15, 2, 8);
solidRect(39, 15, 1, 8);
solidRect(0, 23, 8, 2);
solidRect(16, 23, 8, 2);
solidRect(32, 23, 8, 2);
solidRect(0, 30, 40, 2);

const fixture = Array.from({ length: fixtureHeight }, () => Array(fixtureWidth).fill(17));
for (const [x, y, width] of [[2, 2, 3], [12, 4, 3], [23, 2, 3], [33, 5, 3], [5, 11, 3], [20, 12, 3], [29, 10, 3]]) {
  fixture[y][x] = 18;
  for (let offset = 1; offset < width - 1; offset++) fixture[y][x + offset] = 19;
  fixture[y][x + width - 1] = 20;
}
for (let x = 0; x < fixtureWidth; x++) {
  const post = x % 6 === 1;
  const divot = [4, 11, 18, 29, 36].includes(x);
  fixture[25][x] = post ? 40 : divot ? 42 : 36;
  fixture[26][x] = post ? 39 : (x % 2 === 0 ? 34 : 35);
  fixture[27][x] = post ? 41 : 37;
  fixture[28][x] = post ? 39 : (x % 2 === 0 ? 35 : 34);
  fixture[29][x] = post ? 39 : (x % 2 === 0 ? 34 : 35);
  if (post && !solid[24][x]) fixture[24][x] = 31;
}
for (let y = 0; y < fixtureHeight; y++) for (let x = 0; x < fixtureWidth; x++) {
  if (!solid[y][x]) continue;
  const mask = (y > 0 && solid[y - 1][x] ? 1 : 0) |
    (x < fixtureWidth - 1 && solid[y][x + 1] ? 2 : 0) |
    (y < fixtureHeight - 1 && solid[y + 1][x] ? 4 : 0) |
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  fixture[y][x] = 1 + mask;
}
for (let row = 0; row < 3; row++) for (let column = 0; column < 2; column++) fixture[27 + row][19 + column] = 25 + row * 2 + column;

const fixturePixels = Buffer.alloc(fixtureWidth * 8 * fixtureHeight * 8 * 4);
for (let tileY = 0; tileY < fixtureHeight; tileY++) for (let tileX = 0; tileX < fixtureWidth; tileX++) {
  const id = fixture[tileY][tileX];
  const atlasX = (id % 16) * 8;
  const atlasY = Math.floor(id / 16) * 8;
  for (let y = 0; y < 8; y++) {
    const sourceOffset = ((atlasY + y) * atlasWidth + atlasX) * 4;
    const targetOffset = (((tileY * 8 + y) * fixtureWidth * 8) + tileX * 8) * 4;
    pixels.copy(fixturePixels, targetOffset, sourceOffset, sourceOffset + 32);
  }
}

writeFileSync('gfx/patio.png', encodePng(atlasWidth, atlasHeight, pixels));
writeFileSync('gfx/patio.tsx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<tileset version="1.10" tiledversion="1.12.2" name="patio" tilewidth="8" tileheight="8" tilecount="128" columns="16">',
  ' <image source="patio.png" width="128" height="64"/>',
  ...tileXml,
  '</tileset>',
  '',
].join('\n'));
writeFileSync('gfx/patio_fixture.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  `<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="${fixtureWidth}" height="${fixtureHeight}" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">`,
  ' <tileset firstgid="1" source="patio.tsx"/>',
  ` <layer id="1" name="Terrain" width="${fixtureWidth}" height="${fixtureHeight}">`,
  '  <data encoding="csv">',
  fixture.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  '</map>',
  '',
].join('\n'));
writeFileSync('gfx/patio_fixture_review.png', encodePng(fixtureWidth * 8, fixtureHeight * 8, fixturePixels));
writeFileSync('build/patio_fixture.tilemap', Buffer.from(fixture.flat()));
writeFileSync('build/patio_collision.bin', Buffer.from(Array.from({ length: 128 }, (_, id) => id >= 1 && id <= 16 ? 1 : 0)));
