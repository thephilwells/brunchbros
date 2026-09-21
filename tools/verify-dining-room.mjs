import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const collision = readFileSync('build/dining_room_collision.bin');
const map = readFileSync('build/dining_room_fixture.tilemap');
const tsx = readFileSync('gfx/dining_room.tsx', 'utf8');
const tiles = [...tsx.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)];
const collisionKinds = { empty: 0, solid: 1, one_way: 2 };

assert.equal(collision.length, 128);
assert.equal(map.length, 1024);
assert.equal(tiles.length, 128);

for (const [index, [, id, properties]] of tiles.entries()) {
  assert.equal(Number(id), index);
  const kind = properties.match(/name="collision" value="([^"]+)"/)[1];
  const role = properties.match(/name="role" value="([^"]+)"/)[1];
  assert.equal(collision[index], collisionKinds[kind]);
  if (role === 'reserved') assert(!map.includes(index));
}

for (let x = 9; x <= 12; x++) {
  assert.equal(map[24 * 32 + x], 50);
  assert.equal(collision[map[23 * 32 + x]], 0);
  assert.equal(collision[map[25 * 32 + x]], 0);
  assert.equal(collision[map[27 * 32 + x]], 1);
}

for (let x = 15; x <= 16; x++) {
  assert.equal(map[17 * 32 + x], 50);
  assert.equal(collision[map[16 * 32 + x]], 0);
  assert.equal(collision[map[18 * 32 + x]], 0);
}

for (let y = 11; y < 24; y++) {
  for (const x of [10, 11]) assert.equal(collision[map[y * 32 + x]], 0);
}

for (let x = 1; x <= 8; x++) {
  assert.equal(collision[map[18 * 32 + x]], 0);
  assert.equal(collision[map[19 * 32 + x]], 0);
  assert.equal(collision[map[20 * 32 + x]], 1);
  assert.equal(collision[map[21 * 32 + x]], 0);
}
for (let x = 9; x <= 11; x++) assert.equal(collision[map[20 * 32 + x]], 0);
for (let x = 12; x <= 19; x++) {
  assert.equal(collision[map[19 * 32 + x]], 0);
  assert.equal(collision[map[20 * 32 + x]], 1);
  assert.equal(collision[map[21 * 32 + x]], 0);
}

for (const [x, id] of [[14, 51], [15, 52], [16, 52], [17, 53]]) {
  assert.equal(map[25 * 32 + x], id);
  assert.equal(collision[id], 2);
  assert.equal(collision[map[24 * 32 + x]], 0);
}
for (const [x, id] of [[14, 54], [15, 17], [16, 17], [17, 55]]) {
  assert.equal(map[26 * 32 + x], id);
  assert.equal(collision[id], 0);
  assert.equal(collision[map[27 * 32 + x]], 1);
}

assert.equal(map[25 * 32 + 19], 17);
assert.equal(map[25 * 32 + 20], 56);
assert.equal(collision[56], 0);
for (const [x, id] of [[19, 57], [20, 58]]) {
  assert.equal(map[26 * 32 + x], id);
  assert.equal(collision[id], 2);
  assert.equal(collision[map[27 * 32 + x]], 1);
}

for (const [x, id] of [[2, 59], [3, 60], [4, 60], [5, 61]]) {
  assert.equal(collision[map[23 * 32 + x]], 0);
  assert.equal(map[24 * 32 + x], id);
  assert.equal(collision[id], 0);
  assert.equal(map[25 * 32 + x], 62);
  assert.equal(collision[62], 0);
  assert.equal(map[26 * 32 + x], 63);
  assert.equal(collision[63], 2);
  assert.equal(collision[map[27 * 32 + x]], 1);
}

for (const [x, id] of [[21, 112], [22, 113], [23, 113], [24, 114]]) {
  assert.equal(collision[map[24 * 32 + x]], 0);
  assert.equal(map[25 * 32 + x], id);
  assert.equal(collision[id], 2);
  assert.equal(map[26 * 32 + x], 115);
  assert.equal(collision[115], 0);
  assert.equal(collision[map[27 * 32 + x]], 1);
}

for (let row = 0; row < 3; row++) {
  for (let column = 0; column < 2; column++) {
    const id = 25 + row * 2 + column;
    assert.equal(map[(24 + row) * 32 + 28 + column], id);
    assert.equal(collision[id], 0);
    const properties = tiles[id][2];
    assert.match(properties, /name="role" value="exit"/);
    assert.match(properties, /name="interaction" value="press_down"/);
  }
}
for (let x = 28; x <= 29; x++) assert.equal(collision[map[27 * 32 + x]], 1);

console.log('Dining-room tileset, exit, and one-way furniture fixture verified.');
