import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const width = 40;
const map = readFileSync('build/room_template_playtest.tilemap');

function at(x, y) {
  return map[y * width + x];
}

function isSolid(x, y) {
  return at(x, y) >= 1 && at(x, y) <= 16;
}

assert.equal(map.length, 40 * 32);
assert.match(readFileSync('gfx/room_template_playtest.tmx', 'utf8'), /width="40" height="32"/);

for (const y of [21, 22]) {
  assert.equal(at(19, y), 17);
  assert.equal(at(20, y), 17);
}
for (const y of [15, 16]) {
  for (let x = 14; x <= 16; x++) assert.equal(at(x, y), 17);
}

for (const [y, startX] of [[9, 14], [12, 11], [14, 14], [17, 14], [20, 12], [21, 15]]) {
  for (let x = startX; x < startX + 3; x++) assert.equal(at(x, y), 50);
}

const ascentSurfaces = [23, 21, 20, 17, 14, 12, 9];
for (let index = 1; index < ascentSurfaces.length; index++) {
  assert((ascentSurfaces[index - 1] - ascentSurfaces[index]) * 8 <= 24);
}

for (const x of [34, 35]) assert(isSolid(x, 23));
for (let x = 14; x <= 16; x++) assert.equal(at(x, 8), 17);

console.log('Room-template playtest seams, platforms, spawn floor, and ascent limits verified.');
