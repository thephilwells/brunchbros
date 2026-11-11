import { readFileSync, writeFileSync } from 'node:fs';

const manifest = JSON.parse(readFileSync('data/biomes.json', 'utf8'));
const levelKinds = manifest.biomes.flatMap((biome, biomeIndex) => biome.levelKinds.map(levelKind => ({ ...levelKind, biome: biome.id, biomeIndex })));
const levelKindById = new Map(levelKinds.map(levelKind => [levelKind.id, levelKind]));

if (levelKindById.size !== levelKinds.length) throw new Error('Biome level-kind IDs must be unique');
if (manifest.runSequence.length !== levelKinds.length || new Set(manifest.runSequence).size !== levelKinds.length) throw new Error('Run sequence must contain every level kind exactly once');
for (const levelKind of manifest.runSequence) if (!levelKindById.has(levelKind)) throw new Error(`Unknown run-sequence level kind ${levelKind}`);
for (const biome of manifest.biomes) {
  if (!manifest.generationProfiles[biome.profiles.generation]) throw new Error(`Unknown generation profile ${biome.profiles.generation}`);
}

const symbol = value => value.toUpperCase().replaceAll('-', '_');
const orderedLevelKinds = manifest.runSequence.map(id => levelKindById.get(id));
writeFileSync('build/biome_profiles.inc', [
  ...manifest.biomes.map((biome, index) => `DEF BIOME_${symbol(biome.id)} EQU ${index}`),
  ...orderedLevelKinds.map((levelKind, index) => `DEF LEVEL_KIND_${symbol(levelKind.id)} EQU ${index}`),
  `DEF LEVEL_KIND_COUNT EQU ${orderedLevelKinds.length}`,
  'MACRO EMIT_LEVEL_PROGRESSION',
  `\tdb ${orderedLevelKinds.map(levelKind => `LEVEL_KIND_${symbol(levelKind.id)}`).join(', ')}`,
  'ENDM',
  'MACRO EMIT_LEVEL_KIND_BIOMES',
  `\tdb ${orderedLevelKinds.map(levelKind => `BIOME_${symbol(levelKind.biome)}`).join(', ')}`,
  'ENDM',
  '',
].join('\n'));
