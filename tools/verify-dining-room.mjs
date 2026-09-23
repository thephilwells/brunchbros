import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const collision = readFileSync('build/dining_room_collision.bin');
const map = readFileSync('build/dining_room_fixture.tilemap');
const tsx = readFileSync('gfx/dining_room.tsx', 'utf8');
const tiles = [...tsx.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)];
const collisionKinds = { empty: 0, solid: 1, one_way: 2 };
const mapWidth = 40;

function at(x, y) {
  return map[y * mapWidth + x];
}

assert.equal(collision.length, 128);
assert.equal(map.length, 1280);
assert.equal(tiles.length, 128);
assert.match(readFileSync('gfx/dining_room_fixture.tmx', 'utf8'), /width="40" height="32"/);

for (const [index, [, id, properties]] of tiles.entries()) {
  assert.equal(Number(id), index);
  const kind = properties.match(/name="collision" value="([^"]+)"/)[1];
  const role = properties.match(/name="role" value="([^"]+)"/)[1];
  assert.equal(collision[index], collisionKinds[kind]);
  if (role === 'reserved') assert(!map.includes(index));
}

for (let x = 9; x <= 12; x++) {
  assert.equal(at(x, 24), 50);
  assert.equal(collision[at(x, 23)], 0);
  assert.equal(collision[at(x, 25)], 0);
  assert.equal(collision[at(x, 27)], 1);
}

for (let x = 15; x <= 16; x++) {
  assert.equal(at(x, 17), 50);
  assert.equal(collision[at(x, 16)], 0);
  assert.equal(collision[at(x, 18)], 0);
}

for (let y = 11; y < 24; y++) {
  for (const x of [10, 11]) assert.equal(collision[at(x, y)], 0);
}

for (let x = 1; x <= 8; x++) {
  assert.equal(collision[at(x, 18)], 0);
  assert.equal(collision[at(x, 19)], 0);
  assert.equal(collision[at(x, 20)], 1);
  assert.equal(collision[at(x, 21)], 0);
}
for (let x = 9; x <= 11; x++) assert.equal(collision[at(x, 20)], 0);
for (let x = 12; x <= 19; x++) {
  assert.equal(collision[at(x, 19)], 0);
  assert.equal(collision[at(x, 20)], 1);
  assert.equal(collision[at(x, 21)], 0);
}

for (const [x, id] of [[14, 51], [15, 52], [16, 52], [17, 53]]) {
  assert.equal(at(x, 25), id);
  assert.equal(collision[id], 2);
  assert.equal(collision[at(x, 24)], 0);
}
for (const [x, id] of [[14, 54], [15, 17], [16, 17], [17, 55]]) {
  assert.equal(at(x, 26), id);
  assert.equal(collision[id], 0);
  assert.equal(collision[at(x, 27)], 1);
}

assert.equal(at(19, 25), 17);
assert.equal(at(20, 25), 56);
assert.equal(collision[56], 0);
for (const [x, id] of [[19, 57], [20, 58]]) {
  assert.equal(at(x, 26), id);
  assert.equal(collision[id], 2);
  assert.equal(collision[at(x, 27)], 1);
}

for (const [x, id] of [[2, 59], [3, 60], [4, 60], [5, 61]]) {
  assert.equal(collision[at(x, 23)], 0);
  assert.equal(at(x, 24), id);
  assert.equal(collision[id], 0);
  assert.equal(at(x, 25), 62);
  assert.equal(collision[62], 0);
  assert.equal(at(x, 26), 63);
  assert.equal(collision[63], 2);
  assert.equal(collision[at(x, 27)], 1);
}

for (const [x, id] of [[21, 112], [22, 113], [23, 113], [24, 114]]) {
  assert.equal(collision[at(x, 24)], 0);
  assert.equal(at(x, 25), id);
  assert.equal(collision[id], 2);
  assert.equal(at(x, 26), 115);
  assert.equal(collision[115], 0);
  assert.equal(collision[at(x, 27)], 1);
}

for (let row = 0; row < 3; row++) {
  for (let column = 0; column < 2; column++) {
    const id = 25 + row * 2 + column;
    assert.equal(at(36 + column, 24 + row), id);
    assert.equal(collision[id], 0);
    const properties = tiles[id][2];
    assert.match(properties, /name="role" value="exit"/);
    assert.match(properties, /name="interaction" value="press_down"/);
  }
}
for (let x = 36; x <= 37; x++) assert.equal(collision[at(x, 27)], 1);

for (let x = 32; x < mapWidth; x++) assert.equal(collision[at(x, 27)], 1);
for (let x = 32; x <= 34; x++) assert.equal(collision[at(x, 24)], 1);
for (let y = 25; y <= 26; y++) assert.equal(collision[at(25, y)], 0);

console.log('Dining-room tileset, exit, and one-way furniture fixture verified.');
