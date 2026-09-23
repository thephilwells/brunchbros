import { writeFileSync } from 'node:fs';
import { generateLevel, levelToTmx } from './lib/level-generation.mjs';

let seed = 0;
if (process.argv.length > 2) {
  if (process.argv[2] !== '--seed' || process.argv.length !== 4) throw new Error('Usage: node tools/generate-seeded-level.mjs [--seed 0..65535]');
  seed = Number(process.argv[3]);
}
if (!Number.isInteger(seed) || seed < 0 || seed > 0xffff) throw new Error('Seed must be an integer from 0 through 65535');

const level = generateLevel(seed);
if (!level.validation.valid) throw new Error(level.validation.errors.join('\n'));

writeFileSync('build/seeded_level.tilemap', Buffer.from(level.tiles));
writeFileSync('build/seeded_level.json', `${JSON.stringify(level, null, 2)}\n`);
writeFileSync('build/seeded_level.inc', [
  `DEF GENERATED_LEVEL_SEED EQU ${seed}`,
  `DEF GENERATED_PLAYER_X EQU ${level.spawnPosition.x}`,
  `DEF GENERATED_PLAYER_Y EQU ${level.spawnPosition.y}`,
  '',
].join('\n'));
writeFileSync('gfx/seeded_level.tmx', levelToTmx(level, 'dining_room.tsx'));

console.log(`Generated playable dining-room seed ${seed}.`);
