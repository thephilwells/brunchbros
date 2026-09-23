import assert from 'node:assert/strict';
import {
  generateLevel,
  routeFromColumns,
  topologySignature,
  validateLevel,
} from './lib/level-generation.mjs';

const topologies = new Set();
const firstBatchTopologies = new Set();
const seededTopologies = new Set();
let minimumLength = 16;
let maximumLength = 0;
let levelsWithLedgeCatch = 0;

for (let spawn = 0; spawn < 4; spawn++) {
  for (let firstDescent = 0; firstDescent < 4; firstDescent++) {
    for (let secondDescent = 0; secondDescent < 4; secondDescent++) {
      for (let thirdDescent = 0; thirdDescent < 4; thirdDescent++) {
        for (let exit = 0; exit < 4; exit++) {
          const level = routeFromColumns([spawn, firstDescent, secondDescent, thirdDescent, exit]);
          assert.equal(level.validation.valid, true, level.validation.errors.join('\n'));
          topologies.add(topologySignature(level));
          minimumLength = Math.min(minimumLength, level.criticalRouteLength);
          maximumLength = Math.max(maximumLength, level.criticalRouteLength);
        }
      }
    }
  }
}

assert.equal(topologies.size, 1024);
assert.equal(minimumLength, 4);
assert.equal(maximumLength, 16);

for (let seed = 0; seed < 4096; seed++) {
  const first = generateLevel(seed);
  const second = generateLevel(seed);
  assert.deepEqual(first, second);
  assert.equal(first.validation.valid, true, `Seed ${seed}: ${first.validation.errors.join(', ')}`);
  if (first.roomTraversalClasses.includes('ledge_catch')) levelsWithLedgeCatch++;
  seededTopologies.add(topologySignature(first));
  if (seed < 256) firstBatchTopologies.add(topologySignature(first));
}

assert.equal(firstBatchTopologies.size, 256);
assert.equal(seededTopologies.size, 1024);
assert(levelsWithLedgeCatch > 0);

const mismatchedSeam = structuredClone(generateLevel(0));
mismatchedSeam.roomWidePorts[5] = 0;
assert(validateLevel(mismatchedSeam).errors.some(error => error.includes('wide seam is mismatched')));

const consecutiveBoundaries = structuredClone(generateLevel(0));
consecutiveBoundaries.roomTraversalClasses[consecutiveBoundaries.criticalRoute[0]] = 'ledge_catch';
consecutiveBoundaries.roomTraversalClasses[consecutiveBoundaries.criticalRoute[1]] = 'ledge_catch';
assert(validateLevel(consecutiveBoundaries).errors.some(error => error.includes('consecutive boundary traversals')));

console.log('All 1,024 route topologies and 4,096 deterministic seeds verified.');
