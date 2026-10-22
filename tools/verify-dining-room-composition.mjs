import assert from 'node:assert/strict';
import {
  addDiningRoomPlacementReservations,
  composeDiningRoom,
  validateDiningRoomComposition,
  validateDiningRoomPlacementReservations,
} from './lib/dining-room-composition.mjs';
import { generateLevel, levelToSvg, levelToTmx } from './lib/level-generation.mjs';

let levelsWithAvailableCells = 0;
let levelsWithBackground = 0;
let levelsWithFurniture = 0;
let minimumReservedCells = 1280;
let maximumReservedCells = 0;
let minimumPlacements = 16;
let maximumPlacements = 0;
let totalPlacements = 0;
let minimumBackgroundPlacements = 16;
let maximumBackgroundPlacements = 0;
let totalBackgroundPlacements = 0;
let levelsWithWallpaper = 0;
let minimumWallpaperPlacements = 32;
let maximumWallpaperPlacements = 0;
let totalWallpaperPlacements = 0;
let levelsWithMobs = 0;
let minimumMobPlacements = 16;
let maximumMobPlacements = 0;
let totalMobPlacements = 0;
const minimumMobTypeCounts = new Map([['weiner', 16], ['burger', 16], ['pancake', 16], ['fried_egg', 16]]);
const maximumMobTypeCounts = new Map([['weiner', 0], ['burger', 0], ['pancake', 0], ['fried_egg', 0]]);
const backgroundComponentCounts = new Map();
const componentCounts = new Map();
const chairOrientationCounts = new Map();
let furnishedExample;
let backgroundExample;
let chairExample;
let sconceExample;
let wallpaperExample;
let mobExample;
const seedCount = 0x10000;

for (let seed = 0; seed < seedCount; seed++) {
  const generated = generateLevel(seed);
  const first = composeDiningRoom(generated);
  const second = composeDiningRoom(generateLevel(seed));
  assert.equal(first.validation.valid, true, `Seed ${seed}: ${first.validation.errors.join(', ')}`);
  assert.deepEqual(first.placementReservationMask, second.placementReservationMask);
  assert.deepEqual(first.placementReservationRegions, second.placementReservationRegions);
  assert.deepEqual(first.roomBackgroundCandidateCounts, second.roomBackgroundCandidateCounts);
  assert.deepEqual(first.backgroundPlacements, second.backgroundPlacements);
  assert.deepEqual(first.roomFurnitureCandidateCounts, second.roomFurnitureCandidateCounts);
  assert.deepEqual(first.furniturePlacements, second.furniturePlacements);
  assert.deepEqual(first.wallpaperSourceTiles, second.wallpaperSourceTiles);
  assert.deepEqual(first.roomWallpaperCandidateCounts, second.roomWallpaperCandidateCounts);
  assert.deepEqual(first.wallpaperPlacements, second.wallpaperPlacements);
  assert.deepEqual(first.roomMobCandidateCounts, second.roomMobCandidateCounts);
  assert.deepEqual(first.mobPlacements, second.mobPlacements);
  assert.equal(first.mobPopulationTarget, second.mobPopulationTarget);
  assert.deepEqual(first.tiles, second.tiles);
  assert.deepEqual(first.structuralTiles, generated.tiles);
  assert.equal(first.compositionValidation.valid, true, `Seed ${seed}: ${first.compositionValidation.errors.join(', ')}`);

  const reservedCells = first.placementReservationMask.filter(Boolean).length;
  minimumReservedCells = Math.min(minimumReservedCells, reservedCells);
  maximumReservedCells = Math.max(maximumReservedCells, reservedCells);
  if (reservedCells < 1280) levelsWithAvailableCells++;

  const backgroundPlacements = first.backgroundPlacements.length;
  minimumBackgroundPlacements = Math.min(minimumBackgroundPlacements, backgroundPlacements);
  maximumBackgroundPlacements = Math.max(maximumBackgroundPlacements, backgroundPlacements);
  totalBackgroundPlacements += backgroundPlacements;
  if (backgroundPlacements) {
    levelsWithBackground++;
    backgroundExample ??= first;
  }
  for (const placed of first.backgroundPlacements) {
    backgroundComponentCounts.set(placed.component, (backgroundComponentCounts.get(placed.component) ?? 0) + 1);
    if (placed.component === 'wall_sconce') sconceExample ??= first;
  }

  const wallpaperPlacements = first.wallpaperPlacements.length;
  minimumWallpaperPlacements = Math.min(minimumWallpaperPlacements, wallpaperPlacements);
  maximumWallpaperPlacements = Math.max(maximumWallpaperPlacements, wallpaperPlacements);
  totalWallpaperPlacements += wallpaperPlacements;
  if (wallpaperPlacements) {
    levelsWithWallpaper++;
    wallpaperExample ??= first;
  }

  const mobPlacements = first.mobPlacements.length;
  minimumMobPlacements = Math.min(minimumMobPlacements, mobPlacements);
  maximumMobPlacements = Math.max(maximumMobPlacements, mobPlacements);
  totalMobPlacements += mobPlacements;
  if (mobPlacements) {
    levelsWithMobs++;
    mobExample ??= first;
  }
  for (const mobType of minimumMobTypeCounts.keys()) {
    const count = first.mobPlacements.filter(placement => placement.mob === mobType).length;
    minimumMobTypeCounts.set(mobType, Math.min(minimumMobTypeCounts.get(mobType), count));
    maximumMobTypeCounts.set(mobType, Math.max(maximumMobTypeCounts.get(mobType), count));
  }

  const placements = first.furniturePlacements.length;
  minimumPlacements = Math.min(minimumPlacements, placements);
  maximumPlacements = Math.max(maximumPlacements, placements);
  totalPlacements += placements;
  if (placements) {
    levelsWithFurniture++;
    furnishedExample ??= first;
  }
  for (const placed of first.furniturePlacements) {
    componentCounts.set(placed.component, (componentCounts.get(placed.component) ?? 0) + 1);
    if (placed.component === 'dining_chair') {
      chairOrientationCounts.set(placed.orientation, (chairOrientationCounts.get(placed.orientation) ?? 0) + 1);
      chairExample ??= first;
    }
  }
}

assert(levelsWithAvailableCells > 0);
assert(levelsWithBackground > seedCount * .99);
assert(levelsWithFurniture > 0);
assert(levelsWithWallpaper > seedCount * .99);
assert(levelsWithMobs > seedCount * .99);
assert.deepEqual(Object.fromEntries(minimumMobTypeCounts), { weiner: 2, burger: 2, pancake: 2, fried_egg: 0 });
assert.deepEqual(Object.fromEntries(maximumMobTypeCounts), { weiner: 2, burger: 2, pancake: 2, fried_egg: 2 });
assert(minimumReservedCells > 0);
assert.equal(maximumReservedCells, 1280);
assert.deepEqual([...backgroundComponentCounts.keys()].sort(), ['menu_board', 'serving_hatch', 'wall_clock', 'wall_mirror', 'wall_sconce']);
assert.deepEqual([...componentCounts.keys()].sort(), ['dining_booth', 'dining_chair', 'dining_counter', 'dining_table']);
assert.deepEqual([...chairOrientationCounts.keys()].sort(), ['back_left', 'back_right']);

const missingCell = addDiningRoomPlacementReservations(generateLevel(0));
missingCell.placementReservationMask[missingCell.placementReservationMask.findIndex(Boolean)] = 0;
assert.equal(validateDiningRoomPlacementReservations(missingCell).valid, false);

const wrongTile = structuredClone(furnishedExample);
const placement = wrongTile.furniturePlacements[0];
wrongTile.tiles[placement.y * 40 + placement.x] = 255;
assert.equal(validateDiningRoomComposition(wrongTile).valid, false);

const reservedFurniture = structuredClone(furnishedExample);
reservedFurniture.placementReservationMask[placement.y * 40 + placement.x] = 1;
assert.equal(validateDiningRoomComposition(reservedFurniture).valid, false);

const missingFurniture = structuredClone(furnishedExample);
missingFurniture.furniturePlacements.shift();
assert.equal(validateDiningRoomComposition(missingFurniture).valid, false);

const wrongBackgroundTile = structuredClone(backgroundExample);
const backgroundPlacement = wrongBackgroundTile.backgroundPlacements[0];
wrongBackgroundTile.tiles[backgroundPlacement.y * 40 + backgroundPlacement.x] = 255;
assert.equal(validateDiningRoomComposition(wrongBackgroundTile).valid, false);

const protectedBackground = structuredClone(backgroundExample);
protectedBackground.placementReservationMask[backgroundPlacement.y * 40 + backgroundPlacement.x] |= 2;
assert.equal(validateDiningRoomComposition(protectedBackground).valid, false);

const missingBackground = structuredClone(backgroundExample);
missingBackground.backgroundPlacements.shift();
assert.equal(validateDiningRoomComposition(missingBackground).valid, false);

const wrongWallpaperTile = structuredClone(wallpaperExample);
const wallpaperPlacement = wrongWallpaperTile.wallpaperPlacements[0];
wrongWallpaperTile.tiles[wallpaperPlacement.y * 40 + wallpaperPlacement.x] = 17;
assert.equal(validateDiningRoomComposition(wrongWallpaperTile).valid, false);

const protectedWallpaper = structuredClone(wallpaperExample);
protectedWallpaper.placementReservationMask[wallpaperPlacement.y * 40 + wallpaperPlacement.x] |= 2;
assert.equal(validateDiningRoomComposition(protectedWallpaper).valid, false);

const missingWallpaper = structuredClone(wallpaperExample);
missingWallpaper.wallpaperPlacements.shift();
assert.equal(validateDiningRoomComposition(missingWallpaper).valid, false);

const sconcePair = sconceExample.backgroundPlacements.filter(placement => placement.chamber === sconceExample.backgroundPlacements.find(candidate => candidate.component === 'wall_sconce').chamber);
assert.equal(sconcePair.length, 2);
assert.equal(sconcePair[0].y, sconcePair[1].y);
const unevenSconces = structuredClone(sconceExample);
const movedSconce = unevenSconces.backgroundPlacements.find(placement => placement.component === 'wall_sconce');
movedSconce.x++;
const unevenSconceValidation = validateDiningRoomComposition(unevenSconces);
assert.equal(unevenSconceValidation.valid, false);
assert(unevenSconceValidation.errors.some(error => error.includes('not evenly spaced')));

const wrongChairOrientation = structuredClone(chairExample);
const chair = wrongChairOrientation.furniturePlacements.find(candidate => candidate.component === 'dining_chair');
chair.orientation = chair.orientation === 'back_left' ? 'back_right' : 'back_left';
assert.equal(validateDiningRoomComposition(wrongChairOrientation).valid, false);

const missingMob = structuredClone(mobExample);
missingMob.mobPlacements.shift();
assert.equal(validateDiningRoomComposition(missingMob).valid, false);

const protectedMob = structuredClone(mobExample);
const mob = protectedMob.mobPlacements[0];
protectedMob.placementReservationMask[mob.y * 40 + mob.x] |= 2;
assert.equal(validateDiningRoomComposition(protectedMob).valid, false);

const svg = levelToSvg(furnishedExample);
const tmx = levelToTmx(furnishedExample, 'dining_room.tsx');
assert.match(svg, /fill-opacity="\.34"/);
assert.match(svg, /fill-opacity="\.7"/);
assert.match(svg, /fill-opacity="\.82"/);
assert.match(svg, /r="\.25"/);
assert.match(svg, /#ef7048/);
assert.match(tmx, /name="Placement Reservations" visible="0"/);
assert.match(tmx, /name="Background Placements"/);
assert.match(tmx, /type="background_placement"/);
assert.match(tmx, /name="instances"/);
assert.match(tmx, /name="Furniture Placements"/);
assert.match(tmx, /type="furniture_placement"/);
assert.match(tmx, /name="orientation"/);
assert.match(tmx, /name="Wallpaper Placements"/);
assert.match(tmx, /type="wallpaper_placement"/);
assert.match(tmx, /name="Mob Spawns"/);
assert.match(tmx, /type="mob_spawn"/);

const averagePlacements = (totalPlacements / seedCount).toFixed(2);
const averageBackgroundPlacements = (totalBackgroundPlacements / seedCount).toFixed(2);
const averageWallpaperPlacements = (totalWallpaperPlacements / seedCount).toFixed(2);
const averageMobPlacements = (totalMobPlacements / seedCount).toFixed(2);
console.log(`Dining-room composition verified across all 65,536 seeds; ${minimumReservedCells}–${maximumReservedCells} cells reserved; ${minimumBackgroundPlacements}–${maximumBackgroundPlacements} background fixtures (${averageBackgroundPlacements} average, ${levelsWithBackground} decorated levels); ${minimumPlacements}–${maximumPlacements} furniture placements (${averagePlacements} average, ${levelsWithFurniture} furnished levels); ${minimumWallpaperPlacements}–${maximumWallpaperPlacements} wallpaper motifs (${averageWallpaperPlacements} average, ${levelsWithWallpaper} patterned levels); ${minimumMobPlacements}–${maximumMobPlacements} mob spawns (${averageMobPlacements} average, ${levelsWithMobs} populated levels; two WEINERs, two BURGERs, two PANCAKEs, and two FRIED_EGGs per level).`);
