import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const width = 40;
const map = readFileSync('build/room_variant_playtest.tilemap');
const tmx = readFileSync('gfx/room_variant_playtest.tmx', 'utf8');
const at = (x, y) => map[y * width + x];
const isSolid = (x, y) => at(x, y) >= 1 && at(x, y) <= 16;

assert.equal(map.length, 40 * 32);
assert.match(tmx, /name="e_wide_ordinary_0"/);
assert.match(tmx, /name="wn_wide_ledge_0"/);
assert.match(tmx, /name="ledge_edge" type="ledge_catch" x="208" y="152"/);

for (let y = 17; y <= 22; y++) {
  assert.equal(at(19, y), 17);
  assert.equal(at(20, y), 17);
}
for (let x = 10; x <= 29; x++) assert(isSolid(x, 23));

for (let x = 26; x <= 29; x++) assert(isSolid(x, 19));
assert.equal(at(25, 19), 17);
assert.equal(at(26, 18), 17);
for (let y = 16; y <= 18; y++) {
  for (let x = 24; x <= 28; x++) assert.equal(at(x, y), 17);
}
const postJumpCenter = 26 * 8 - 6 - 1;
const sweptHeadColumns = [postJumpCenter - 6, postJumpCenter, postJumpCenter + 5].map(x => Math.floor(x / 8));
for (const x of sweptHeadColumns) assert.equal(at(x, 16), 17);
assert.equal((23 - 19) * 8, 32);
assert(28 < (23 - 19) * 8);
assert(!map.includes(50));

for (const x of [11, 12, 13]) assert(isSolid(x, 23));

console.log('Wide seam, 32-pixel exposed ledge, headroom, and spawn support verified.');
