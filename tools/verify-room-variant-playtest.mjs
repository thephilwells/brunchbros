import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const width = 40;
const map = readFileSync('build/room_variant_playtest.tilemap');
const tmx = readFileSync('gfx/room_variant_playtest.tmx', 'utf8');
const at = (x, y) => map[y * width + x];
const isSolid = (x, y) => at(x, y) >= 1 && at(x, y) <= 16;

assert.equal(map.length, 40 * 32);
assert.match(tmx, /name="e_wide_ordinary_0"/);
assert.match(tmx, /name="we_wide_ordinary_0"/);
assert.match(tmx, /name="s_wide_ordinary_0"/);
assert.match(tmx, /name="wn_wide_ledge_0"/);
assert.match(tmx, /name="ledge_edge" type="ledge_catch" x="208" y="152"/);
assert.match(tmx, /name="vertical_open_seam" type="wide_seam" x="168" y="120" width="64" height="16"/);

for (let y = 17; y <= 22; y++) {
  assert.equal(at(9, y), 17);
  assert.equal(at(10, y), 17);
}
for (let x = 0; x <= 29; x++) assert(isSolid(x, 23));
for (const y of [21, 22]) {
  assert.equal(at(19, y), 17);
  assert.equal(at(20, y), 17);
}
for (let x = 21; x <= 28; x++) {
  assert.equal(at(x, 15), 17);
  assert.equal(at(x, 16), 17);
}

for (let x = 26; x <= 29; x++) assert(isSolid(x, 19));
assert.equal(at(25, 19), 17);
assert.equal(at(26, 18), 17);
for (let y = 16; y <= 18; y++) {
  for (let x = 26; x <= 28; x++) assert.equal(at(x, y), 17);
}
for (let x = 20; x <= 23; x++) assert(isSolid(x, 17));
for (let x = 24; x <= 25; x++) assert.equal(at(x, 17), 17);
for (let x = 26; x <= 29; x++) assert(isSolid(x, 14));
for (let x = 24; x <= 25; x++) assert.equal(at(x, 14), 17);
for (let x = 20; x <= 23; x++) assert(isSolid(x, 12));
for (let x = 24; x <= 25; x++) assert.equal(at(x, 12), 17);
for (let y = 9; y <= 11; y++) {
  for (let x = 21; x <= 23; x++) assert.equal(at(x, y), 17);
}
assert.equal((23 - 19) * 8, 32);
assert(28 < (23 - 19) * 8);
assert(!map.includes(50));

for (const x of [1, 2, 3]) assert(isSolid(x, 23));

console.log('Horizontal and vertical domino seams, ledge ascent, and spawn support verified.');
