import assert from 'node:assert/strict';
import {
  addDiningRoomPlacementReservations,
  composeDiningRoom,
  validateDiningRoomComposition,
  validateDiningRoomPlacementReservations,
} from './lib/dining-room-composition.mjs';
import { generateLevel, levelToSvg, levelToTmx } from './lib/level-generation.mjs';

let levelsWithAvailableCells = 0;
let levelsWithFurniture = 0;
let minimumReservedCells = 1280;
let maximumReservedCells = 0;
let minimumPlacements = 16;
let maximumPlacements = 0;
let totalPlacements = 0;
const componentCounts = new Map();
let furnishedExample;
const seedCount = 0x10000;

for (let seed = 0; seed < seedCount; seed++) {
  const generated = generateLevel(seed);
  const first = composeDiningRoom(generated);
  const second = composeDiningRoom(generateLevel(seed));
  assert.equal(first.validation.valid, true, `Seed ${seed}: ${first.validation.errors.join(', ')}`);
  assert.deepEqual(first.placementReservationMask, second.placementReservationMask);
  assert.deepEqual(first.placementReservationRegions, second.placementReservationRegions);
  assert.deepEqual(first.roomFurnitureCandidateCounts, second.roomFurnitureCandidateCounts);
  assert.deepEqual(first.furniturePlacements, second.furniturePlacements);
  assert.deepEqual(first.tiles, second.tiles);
  assert.deepEqual(first.structuralTiles, generated.tiles);
  assert.equal(first.compositionValidation.valid, true, `Seed ${seed}: ${first.compositionValidation.errors.join(', ')}`);

  const reservedCells = first.placementReservationMask.filter(Boolean).length;
  minimumReservedCells = Math.min(minimumReservedCells, reservedCells);
  maximumReservedCells = Math.max(maximumReservedCells, reservedCells);
  if (reservedCells < 1280) levelsWithAvailableCells++;

  const placements = first.furniturePlacements.length;
  minimumPlacements = Math.min(minimumPlacements, placements);
  maximumPlacements = Math.max(maximumPlacements, placements);
  totalPlacements += placements;
  if (placements) {
    levelsWithFurniture++;
    furnishedExample ??= first;
  }
  for (const placed of first.furniturePlacements) componentCounts.set(placed.component, (componentCounts.get(placed.component) ?? 0) + 1);
}

assert(levelsWithAvailableCells > 0);
assert(levelsWithFurniture > 0);
assert(minimumReservedCells > 0);
assert.equal(maximumReservedCells, 1280);
assert.deepEqual([...componentCounts.keys()].sort(), ['dining_booth', 'dining_chair', 'dining_counter', 'dining_table']);

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

const svg = levelToSvg(furnishedExample);
const tmx = levelToTmx(furnishedExample, 'dining_room.tsx');
assert.match(svg, /fill-opacity="\.34"/);
assert.match(svg, /fill-opacity="\.82"/);
assert.match(tmx, /name="Placement Reservations" visible="0"/);
assert.match(tmx, /name="Furniture Placements"/);
assert.match(tmx, /type="furniture_placement"/);

const averagePlacements = (totalPlacements / seedCount).toFixed(2);
console.log(`Dining-room composition verified across all 65,536 seeds; ${minimumReservedCells}–${maximumReservedCells} cells reserved; ${minimumPlacements}–${maximumPlacements} furniture placements (${averagePlacements} average, ${levelsWithFurniture} furnished levels).`);
