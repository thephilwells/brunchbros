import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { generateLevel } from './lib/level-generation.mjs';

const generated = JSON.parse(readFileSync('build/seeded_level.json', 'utf8'));
const expected = generateLevel(generated.seed);
const tilemap = readFileSync('build/seeded_level.tilemap');
const include = readFileSync('build/seeded_level.inc', 'utf8');
const tmx = readFileSync('gfx/seeded_level.tmx', 'utf8');

assert.deepEqual(generated, expected);
assert.deepEqual([...tilemap], expected.tiles);
assert.equal(tilemap.length, 40 * 32);
assert.match(include, new RegExp(`GENERATED_LEVEL_SEED EQU ${expected.seed}`));
assert.match(include, new RegExp(`GENERATED_PLAYER_X EQU ${expected.spawnPosition.x}`));
assert.match(include, new RegExp(`GENERATED_PLAYER_Y EQU ${expected.spawnPosition.y}`));
assert.match(tmx, /name="Seeded Terrain"/);
assert.match(tmx, /name="chef_spawn" type="spawn"/);
assert.match(tmx, /name="descent_exit" type="exit"/);
for (const name of expected.roomTemplateNames) assert.match(tmx, new RegExp(`name="${name}" type="room_template"`));

const wideEastRooms = expected.roomWidePorts.flatMap((ports, room) => ports & 2 ? [room] : []);
assert.equal(wideEastRooms.length, 1);
for (const room of wideEastRooms) assert(expected.roomWidePorts[room + 1] & 1);
for (let index = 1; index < expected.criticalRoute.length; index++) {
  const previous = expected.roomTraversalClasses[expected.criticalRoute[index - 1]];
  const current = expected.roomTraversalClasses[expected.criticalRoute[index]];
  assert(previous === 'ordinary' || current === 'ordinary');
}
assert.equal(expected.roomTraversalClasses.filter(value => value === 'ledge_catch').length, 1);
assert.match(tmx, /name="wide_ports" type="int" value="[12]"/);
assert.match(tmx, /name="traversal_class" value="ledge_catch"/);

const at = (x, y) => expected.tiles[y * 40 + x];
const spawnFloorY = expected.spawnPosition.y / 8;
const spawnCenterX = Math.floor(expected.spawnPosition.x / 8);
for (let x = spawnCenterX - 1; x <= spawnCenterX + 1; x++) {
  assert(at(x, spawnFloorY) >= 1 && at(x, spawnFloorY) <= 16);
  for (let y = spawnFloorY - 6; y < spawnFloorY; y++) assert.equal(at(x, y), 17);
}

for (let row = 0; row < 3; row++) {
  for (let column = 0; column < 2; column++) assert.equal(at(expected.exitDoor.x + column, expected.exitDoor.y + row), 25 + row * 2 + column);
  for (let column = 2; column < 4; column++) assert.equal(at(expected.exitDoor.x + column, expected.exitDoor.y + row), 17);
}
for (let x = expected.exitDoor.x; x < expected.exitDoor.x + 4; x++) {
  assert(at(x, expected.exitDoor.y + 3) >= 1 && at(x, expected.exitDoor.y + 3) <= 16);
  for (let y = expected.exitDoor.y - 3; y < expected.exitDoor.y; y++) assert.equal(at(x, y), 17);
}

console.log(`Playable seed ${expected.seed} tilemap, metadata, and TMX verified.`);
