import { readFileSync, writeFileSync } from 'node:fs';
import { generateLevel, levelToTmx } from './lib/level-generation.mjs';
import { composeDiningRoom } from './lib/dining-room-composition.mjs';

let seed = 0;
let levelKind = 'dining_room_1';
for (let index = 2; index < process.argv.length; index += 2) {
  const name = process.argv[index];
  const value = process.argv[index + 1];
  if (value === undefined) throw new Error(`Missing value for ${name}`);
  if (name === '--seed') seed = Number(value);
  else if (name === '--level-kind') levelKind = value;
  else throw new Error(`Unknown argument ${name}`);
}
if (!Number.isInteger(seed) || seed < 0 || seed > 0xffff) throw new Error('Seed must be an integer from 0 through 65535');
const mobManifest = JSON.parse(readFileSync('data/dining-room-mobs.json', 'utf8'));
const levelKindIndex = mobManifest.levelKinds.findIndex(candidate => candidate.id === levelKind);
if (levelKindIndex < 0) throw new Error(`Unknown Dining Room level kind ${levelKind}`);

const generatedLevel = generateLevel(seed);
const level = composeDiningRoom(generatedLevel, levelKind);
if (!level.validation.valid || !level.compositionValidation.valid) throw new Error([...level.validation.errors, ...level.compositionValidation.errors].join('\n'));
const templateSet = JSON.parse(readFileSync('data/room-templates/dining-room.json', 'utf8'));
if (templateSet.templates.some((template, index) => template.portMask !== index + 1)) throw new Error('Runtime room templates must remain ordered by port mask');
const semanticValues = { '.': 0, '#': 1, '=': 2 };
const runtimeTemplates = templateSet.templates.flatMap(template => template.rows.flatMap(row => [...row].map(cell => semanticValues[cell])));

writeFileSync('build/seeded_level.tilemap', Buffer.from(level.tiles));
writeFileSync('build/runtime_level_parity.tilemap', Buffer.from(level.tiles));
const weiners = level.mobPlacements.filter(placement => placement.mob === 'weiner');
const burgers = level.mobPlacements.filter(placement => placement.mob === 'burger');
const pancakes = level.mobPlacements.filter(placement => placement.mob === 'pancake');
const friedEggs = level.mobPlacements.filter(placement => placement.mob === 'fried_egg');
const directions = { right: 0, down: 1, left: 2, up: 3 };
const mobParity = [weiners.length];
for (const placement of weiners) {
  const x = placement.x * 8;
  mobParity.push(placement.y * 8, x & 0xff, x >> 8, directions[placement.direction]);
}
mobParity.push(burgers.length);
for (const placement of burgers) {
  const x = placement.x * 8;
  mobParity.push((placement.y + 1) * 8, x & 0xff, x >> 8);
}
mobParity.push(pancakes.length);
for (const placement of pancakes) {
  const x = placement.x * 8;
  mobParity.push(placement.y * 8, x & 0xff, x >> 8);
}
mobParity.push(friedEggs.length);
for (const placement of friedEggs) {
  const x = placement.x * 8;
  mobParity.push((placement.y + 2) * 8, x & 0xff, x >> 8);
}
writeFileSync('build/runtime_mob_parity.bin', Buffer.from(mobParity));
const treasureParity = [level.treasurePlacements.length];
for (const placement of level.treasurePlacements) {
  const x = placement.x * 8;
  treasureParity.push((placement.y + placement.height) * 8, x & 0xff, x >> 8, placement.contents === 'heart' ? 1 : 0);
}
writeFileSync('build/runtime_treasure_parity.bin', Buffer.from(treasureParity));
writeFileSync('build/room_templates.bin', Buffer.from(runtimeTemplates));
writeFileSync('build/seeded_level.json', `${JSON.stringify(level, null, 2)}\n`);
writeFileSync('build/seeded_level.inc', [
  `DEF GENERATED_LEVEL_SEED EQU ${seed}`,
  `DEF GENERATED_LEVEL_KIND EQU ${levelKindIndex}`,
  `DEF GENERATED_PLAYER_X EQU ${level.spawnPosition.x}`,
  `DEF GENERATED_PLAYER_Y EQU ${level.spawnPosition.y}`,
  '',
].join('\n'));
writeFileSync('gfx/seeded_level.tmx', levelToTmx(level, 'dining_room.tsx'));

console.log(`Generated playable ${levelKind} seed ${seed}.`);
