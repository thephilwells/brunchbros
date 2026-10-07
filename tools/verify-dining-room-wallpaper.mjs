import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const manifest = JSON.parse(readFileSync('data/dining-room-wallpaper.json', 'utf8'));
const tileset = readFileSync('gfx/dining_room.tsx', 'utf8');
const runtimeTables = readFileSync('build/dining_room_wallpaper.inc', 'utf8');
const tileMatch = tileset.match(new RegExp(`<tile id="${manifest.motifTile}"><properties>(.*?)</properties></tile>`));

assert.equal(manifest.version, 1);
assert.equal(manifest.biome, 'dining_room');
assert.equal(manifest.backgroundTile, 17);
assert.equal(manifest.motifTile, 80);
assert.equal(manifest.xOffset, 2);
assert.equal(manifest.xStride, 4);
assert.equal(manifest.yOffset, 1);
assert.equal(manifest.yStride, 3);
assert.equal(manifest.maxPerRoomCell, 1);
assert.equal(manifest.selectionSalt, 7499);
assert(tileMatch, `missing wallpaper motif tile ${manifest.motifTile}`);
assert.match(tileMatch[1], /name="collision" value="empty"/);
assert.match(tileMatch[1], /name="role" value="rear"/);
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_BACKGROUND_TILE EQU ${manifest.backgroundTile}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_MOTIF_TILE EQU ${manifest.motifTile}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_X_OFFSET EQU ${manifest.xOffset}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_X_STRIDE EQU ${manifest.xStride}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_Y_OFFSET EQU ${manifest.yOffset}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_Y_STRIDE EQU ${manifest.yStride}`));
assert.match(runtimeTables, new RegExp(`DINING_WALLPAPER_SELECTION_SALT EQU \\$${manifest.selectionSalt.toString(16).padStart(4, '0')}`));

console.log('Dining-room wallpaper manifest verified against the TSX.');
