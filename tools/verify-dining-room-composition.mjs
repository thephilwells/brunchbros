import assert from 'node:assert/strict';
import {
  addDiningRoomPlacementReservations,
  validateDiningRoomPlacementReservations,
} from './lib/dining-room-composition.mjs';
import { generateLevel, levelToSvg, levelToTmx } from './lib/level-generation.mjs';

let levelsWithAvailableCells = 0;
let minimumReservedCells = 1280;
let maximumReservedCells = 0;

for (let seed = 0; seed < 4096; seed++) {
  const first = addDiningRoomPlacementReservations(generateLevel(seed));
  const second = addDiningRoomPlacementReservations(generateLevel(seed));
  assert.deepEqual(first.placementReservationMask, second.placementReservationMask);
  assert.deepEqual(first.placementReservationRegions, second.placementReservationRegions);
  assert.equal(first.compositionValidation.valid, true, `Seed ${seed}: ${first.compositionValidation.errors.join(', ')}`);
  const reservedCells = first.placementReservationMask.filter(Boolean).length;
  minimumReservedCells = Math.min(minimumReservedCells, reservedCells);
  maximumReservedCells = Math.max(maximumReservedCells, reservedCells);
  if (reservedCells < 1280) levelsWithAvailableCells++;
}

assert(levelsWithAvailableCells > 0);
assert(minimumReservedCells > 0);
assert.equal(maximumReservedCells, 1280);

const missingCell = addDiningRoomPlacementReservations(generateLevel(0));
missingCell.placementReservationMask[missingCell.placementReservationMask.findIndex(Boolean)] = 0;
assert.equal(validateDiningRoomPlacementReservations(missingCell).valid, false);

const preview = addDiningRoomPlacementReservations(generateLevel(0));
assert.match(levelToSvg(preview), /fill-opacity="\.34"/);
assert.match(levelToTmx(preview, 'dining_room.tsx'), /name="Placement Reservations" visible="0"/);

console.log(`Dining-room reservations verified across 4,096 seeds; ${minimumReservedCells}–${maximumReservedCells} cells reserved.`);
