import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const manifest = JSON.parse(readFileSync('data/dining-room-background.json', 'utf8'));
const runtimeTables = readFileSync('build/dining_room_background.inc', 'utf8');
const tileset = readFileSync('gfx/dining_room.tsx', 'utf8');
const tileProperties = new Map([...tileset.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)].map(match => {
  const properties = Object.fromEntries([...match[2].matchAll(/<property name="([^"]+)"(?: type="[^"]+")? value="([^"]*)"\/>/g)].map(property => [property[1], property[2]]));
  return [Number(match[1]), properties];
}));

assert.equal(manifest.version, 1);
assert.equal(manifest.biome, 'dining_room');
assert.equal(manifest.backgroundTile, 17);
assert.deepEqual(manifest.components.map(component => component.id), [
  'menu_board',
  'wall_mirror',
  'wall_clock',
  'wall_sconce',
  'serving_hatch',
]);

for (const component of manifest.components) {
  assert.equal(component.tiles.length, component.height, `${component.id} height mismatch`);
  assert.equal(component.floorClearance, 2, `${component.id} must sit two tiles above its chamber floor`);
  assert(component.height + component.floorClearance < 7, `${component.id} leaves the room interior`);
  if (component.id === 'wall_sconce') assert.equal(component.instances, 2);
  else assert.equal(component.instances, undefined);
  for (let y = 0; y < component.height; y++) {
    assert.equal(component.tiles[y].length, component.width, `${component.id} row ${y} width mismatch`);
    for (const tile of component.tiles[y]) {
      const properties = tileProperties.get(tile);
      assert(properties, `${component.id} references missing tile ${tile}`);
      assert.equal(properties.collision, 'empty', `${component.id} tile ${tile} is not passable`);
      assert.equal(properties.component, component.id, `${component.id} tile ${tile} belongs to ${properties.component}`);
    }
  }
}

for (const [label, values] of [
  ['Widths', manifest.components.map(component => component.width)],
  ['Heights', manifest.components.map(component => component.height)],
  ['TopRows', manifest.components.map(component => 7 - component.floorClearance - component.height)],
]) assert(runtimeTables.includes(`DiningBackground${label}: db ${values.join(', ')}`));
for (const [index, component] of manifest.components.entries()) {
  assert(runtimeTables.includes(`DiningBackgroundTiles${index}:\n\tdb ${component.tiles.flat().join(', ')}`));
}

console.log('Dining-room background fixture manifest verified against the TSX.');
