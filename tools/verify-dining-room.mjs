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

console.log('Dining-room collision table and one-way fixture verified.');
