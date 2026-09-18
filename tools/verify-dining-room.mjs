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

for (let y = 11; y < 24; y++) {
  for (const x of [10, 11]) assert.equal(collision[map[y * 32 + x]], 0);
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

console.log('Dining-room collision table and one-way furniture fixture verified.');
