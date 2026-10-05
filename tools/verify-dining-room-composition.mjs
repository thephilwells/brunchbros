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
const backgroundComponentCounts = new Map();
const componentCounts = new Map();
const chairOrientationCounts = new Map();
let furnishedExample;
let backgroundExample;
let chairExample;
let sconceExample;
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

const svg = levelToSvg(furnishedExample);
const tmx = levelToTmx(furnishedExample, 'dining_room.tsx');
assert.match(svg, /fill-opacity="\.34"/);
assert.match(svg, /fill-opacity="\.7"/);
assert.match(svg, /fill-opacity="\.82"/);
assert.match(tmx, /name="Placement Reservations" visible="0"/);
assert.match(tmx, /name="Background Placements"/);
assert.match(tmx, /type="background_placement"/);
assert.match(tmx, /name="instances"/);
assert.match(tmx, /name="Furniture Placements"/);
assert.match(tmx, /type="furniture_placement"/);
assert.match(tmx, /name="orientation"/);

const averagePlacements = (totalPlacements / seedCount).toFixed(2);
const averageBackgroundPlacements = (totalBackgroundPlacements / seedCount).toFixed(2);
console.log(`Dining-room composition verified across all 65,536 seeds; ${minimumReservedCells}–${maximumReservedCells} cells reserved; ${minimumBackgroundPlacements}–${maximumBackgroundPlacements} background fixtures (${averageBackgroundPlacements} average, ${levelsWithBackground} decorated levels); ${minimumPlacements}–${maximumPlacements} furniture placements (${averagePlacements} average, ${levelsWithFurniture} furnished levels).`);
