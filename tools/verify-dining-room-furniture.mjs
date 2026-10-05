import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const manifest = JSON.parse(readFileSync('data/dining-room-furniture.json', 'utf8'));
const tileset = readFileSync('gfx/dining_room.tsx', 'utf8');
const runtimeTables = readFileSync('build/dining_room_furniture.inc', 'utf8');
const tileProperties = new Map([...tileset.matchAll(/<tile id="(\d+)"><properties>(.*?)<\/properties><\/tile>/g)].map(match => {
  const properties = Object.fromEntries([...match[2].matchAll(/<property name="([^"]+)"(?: type="[^"]+")? value="([^"]*)"\/>/g)].map(property => [property[1], property[2]]));
  return [Number(match[1]), properties];
}));

assert.equal(manifest.version, 1);
assert.equal(manifest.biome, 'dining_room');
assert.equal(tileProperties.get(manifest.backgroundTile).collision, 'empty');
assert.equal(tileProperties.get(manifest.backgroundTile).role, 'rear');
assert.deepEqual(manifest.components.map(component => component.id), [
  'dining_table',
  'dining_chair',
  'dining_booth',
  'dining_counter',
]);

for (const component of manifest.components) {
  assert.equal(component.floorAnchored, true, `${component.id} must be floor-anchored`);
  assert(component.oneWayRows.length > 0, `${component.id} has no landing row`);
  for (const row of component.oneWayRows) assert(row >= 0 && row < component.height, `${component.id} has an invalid landing row`);
  const layouts = component.orientations ?? [{ id: 'default', tiles: component.tiles }];
  for (const layout of layouts) {
    assert.equal(layout.tiles.length, component.height, `${component.id} ${layout.id} height mismatch`);
    for (let y = 0; y < component.height; y++) {
      assert.equal(layout.tiles[y].length, component.width, `${component.id} ${layout.id} row ${y} width mismatch`);
      for (const tile of layout.tiles[y]) {
        const properties = tileProperties.get(tile);
        assert(properties, `${component.id} references missing tile ${tile}`);
        assert.equal(properties.collision, component.oneWayRows.includes(y) ? 'one_way' : 'empty', `${component.id} tile ${tile} has the wrong collision`);
        if (tile !== manifest.backgroundTile) assert.equal(properties.component, component.id, `${component.id} tile ${tile} belongs to ${properties.component}`);
      }
    }
  }
}

assert.match(runtimeTables, new RegExp(`DiningFurnitureWidths: db ${manifest.components.map(component => component.width).join(', ')}`));
assert.match(runtimeTables, new RegExp(`DiningFurnitureHeights: db ${manifest.components.map(component => component.height).join(', ')}`));
for (const [index, component] of manifest.components.entries()) {
  const layouts = component.orientations ?? [{ id: 'default', tiles: component.tiles }];
  for (const [layoutIndex, layout] of layouts.entries()) {
    assert.match(runtimeTables, new RegExp(`DiningFurnitureTiles${index}${layoutIndex ? 'Alternate' : ''}:\\n\\tdb ${layout.tiles.flat().join(', ')}`));
  }
}

console.log('Dining-room table, chair, booth, and counter manifests verified against the TSX.');
