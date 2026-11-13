import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { inflateSync } from 'node:zlib';

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
  const pixels = Buffer.alloc(width * height * 4);
  for (let y = 0; y < height; y++) {
    const rowOffset = y * (1 + width * 4);
    assert.equal(rows[rowOffset], 0);
    rows.copy(pixels, y * width * 4, rowOffset + 1, rowOffset + 1 + width * 4);
  }
  return { width, height, pixels };
}

function tile(png, id) {
  const result = Buffer.alloc(8 * 8 * 4);
  const tileX = (id % 16) * 8;
  const tileY = Math.floor(id / 16) * 8;
  for (let y = 0; y < 8; y++) {
    const source = ((tileY + y) * png.width + tileX) * 4;
    png.pixels.copy(result, y * 32, source, source + 32);
  }
  return result;
}

const patio = readPng('gfx/patio.png');
const dining = readPng('gfx/dining_room.png');
const review = readPng('gfx/patio_fixture_review.png');
const collision = readFileSync('build/patio_collision.bin');
const map = readFileSync('build/patio_fixture.tilemap');
const furnitureMap = readFileSync('build/patio_furniture_fixture.tilemap');
const tsx = readFileSync('gfx/patio.tsx', 'utf8');
const tiles = [...tsx.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)];
const usedShades = new Set();
const furnitureManifest = JSON.parse(readFileSync('data/patio-furniture.json', 'utf8'));
const backgroundManifest = JSON.parse(readFileSync('data/patio-background.json', 'utf8'));

assert.deepEqual([patio.width, patio.height], [128, 64]);
assert.deepEqual([review.width, review.height], [320, 256]);
assert.equal(collision.length, 128);
assert.equal(map.length, 1280);
assert.equal(furnitureMap.length, 720);
assert.equal(tiles.length, 128);
assert.match(readFileSync('gfx/patio_fixture.tmx', 'utf8'), /width="40" height="32"/);
assert.match(readFileSync('gfx/patio_furniture_fixture.tmx', 'utf8'), /width="40" height="18"/);

for (let offset = 0; offset < patio.pixels.length; offset += 4) {
  assert.equal(patio.pixels[offset], patio.pixels[offset + 1]);
  assert.equal(patio.pixels[offset], patio.pixels[offset + 2]);
  assert.equal(patio.pixels[offset + 3], 255);
  usedShades.add(patio.pixels[offset]);
}
assert.deepEqual([...usedShades].sort((a, b) => a - b), [0, 85, 170, 255]);

for (let id = 1; id <= 16; id++) {
  assert.equal(collision[id], 1);
  assert.match(tiles[id][2], new RegExp(`neighbor_mask" type="int" value="${id - 1}"`));
}
const oneWayIds = new Set(furnitureManifest.components.flatMap(component => {
  const layouts = component.orientations?.map(orientation => orientation.tiles) ?? [component.tiles];
  return layouts.flatMap(layout => component.oneWayRows.flatMap(row => layout[row]));
}));
for (let id = 17; id < 128; id++) assert.equal(collision[id], oneWayIds.has(id) ? 2 : 0);

const furnitureIds = new Set(furnitureManifest.components.flatMap(component => Object.keys(component.tileNames).map(Number)));
const backgroundIds = new Set(backgroundManifest.components.flatMap(component => Object.keys(component.tileNames).map(Number)));
assert.deepEqual([...furnitureIds].sort((a, b) => a - b), Array.from({ length: 20 }, (_, index) => 43 + index));
assert.deepEqual([...backgroundIds].sort((a, b) => a - b), [...Array.from({ length: 18 }, (_, index) => 63 + index), ...Array.from({ length: 12 }, (_, index) => 87 + index)]);
for (const id of [...furnitureIds, ...backgroundIds]) assert(!((id >= 81 && id <= 86) || id >= 116));
assert.equal(new Set([...furnitureIds, ...backgroundIds]).size, furnitureIds.size + backgroundIds.size);
for (const component of [...furnitureManifest.components, ...backgroundManifest.components]) {
  const layouts = component.orientations?.map(orientation => orientation.tiles) ?? [component.tiles];
  const usedIds = new Set();
  for (const layout of layouts) {
    assert.equal(layout.length, component.height);
    for (const row of layout) {
      assert.equal(row.length, component.width);
      for (const id of row) if (id !== 17) usedIds.add(id);
    }
  }
  assert.deepEqual([...usedIds].sort((a, b) => a - b), Object.keys(component.tileNames).map(Number).sort((a, b) => a - b));
}

function verifyPlacement(layout, x, y, oneWayRows) {
  for (let row = 0; row < layout.length; row++) for (let column = 0; column < layout[row].length; column++) {
    const id = furnitureMap[(y + row) * 40 + x + column];
    assert.equal(id, layout[row][column]);
    assert.equal(collision[id], oneWayRows.includes(row) && id !== 17 ? 2 : 0);
  }
}

verifyPlacement(furnitureManifest.components[0].tiles, 2, 14, furnitureManifest.components[0].oneWayRows);
verifyPlacement(furnitureManifest.components[1].orientations[0].tiles, 8, 14, furnitureManifest.components[1].oneWayRows);
verifyPlacement(furnitureManifest.components[1].orientations[1].tiles, 11, 14, furnitureManifest.components[1].oneWayRows);
verifyPlacement(furnitureManifest.components[2].tiles, 15, 14, furnitureManifest.components[2].oneWayRows);
verifyPlacement(furnitureManifest.components[3].tiles, 23, 14, furnitureManifest.components[3].oneWayRows);
for (let x = 0; x < 40; x++) {
  assert.equal(collision[furnitureMap[16 * 40 + x]], 1);
  assert.equal(collision[furnitureMap[17 * 40 + x]], 1);
}

for (const id of [...Array.from({ length: 6 }, (_, index) => 25 + index), ...Array.from({ length: 6 }, (_, index) => 81 + index), ...Array.from({ length: 12 }, (_, index) => 116 + index)]) {
  assert.deepEqual(tile(patio, id), tile(dining, id));
}

for (const id of [17, 18, 19, 20, 31, 34, 35, 36, 37, 39, 40, 41, 42]) assert(map.includes(id));
for (let id = 25; id <= 30; id++) assert(map.includes(id));
for (const [, id, properties] of tiles) {
  if (properties.includes('role" value="reserved"')) assert(!map.includes(Number(id)));
}

console.log('Patio atlas, shared tile contracts, collision data, and full-world fixture verified.');
