import { mkdirSync, writeFileSync } from 'node:fs';
import { relative, resolve } from 'node:path';
import {
  generateLevel,
  levelToSvg,
  levelToTmx,
  topologySignature,
} from './lib/level-generation.mjs';

function readArguments(args) {
  const options = { biome: 'dining_room', seed: 0, count: 256, out: 'build/level-gallery' };
  for (let index = 0; index < args.length; index += 2) {
    const name = args[index];
    const value = args[index + 1];
    if (value === undefined) throw new Error(`Missing value for ${name}`);
    if (name === '--biome') options.biome = value;
    else if (name === '--seed') options.seed = Number(value);
    else if (name === '--count') options.count = Number(value);
    else if (name === '--out') options.out = value;
    else throw new Error(`Unknown argument ${name}`);
  }
  if (options.biome !== 'dining_room') throw new Error('Only dining_room is available');
  if (!Number.isInteger(options.seed) || options.seed < 0 || options.seed > 0xffff) throw new Error('Seed must be an integer from 0 through 65535');
  if (!Number.isInteger(options.count) || options.count < 1 || options.count > 0x10000) throw new Error('Count must be an integer from 1 through 65536');
  return options;
}

function histogram(levels, value) {
  const result = {};
  for (const level of levels) {
    const key = String(value(level));
    result[key] = (result[key] ?? 0) + 1;
  }
  return result;
}

function renderGallery(levels, summary) {
  const cards = levels.map(level => {
    const name = String(level.seed).padStart(5, '0');
    const status = level.validation.valid ? 'valid' : 'invalid';
    const boundaryRooms = level.roomTraversalClasses.filter(value => value !== 'ordinary').length;
    return `<article class="card ${status}"><header><strong>Seed ${level.seed}</strong><span>${status} · ${level.criticalRouteLength} critical</span></header>${levelToSvg(level)}<p>columns ${level.columns.join(' → ')} · 1 wide seam · ${boundaryRooms} boundary</p><footer><a href="levels/${name}.tmx">TMX</a><a href="levels/${name}.json">JSON</a></footer></article>`;
  }).join('\n');
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Brunch Bros level gallery</title><style>
:root{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;color:#172018;background:#e8edd8}body{margin:20px}h1{margin-bottom:4px}.summary{margin:0}.legend{margin:4px 0 20px;color:#536052}.gallery{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:14px}.card{background:#fff;border:2px solid #536b49;border-radius:8px;padding:10px;box-shadow:0 2px 5px #0002}.card.invalid{border-color:#b52626}.card header,.card footer{display:flex;justify-content:space-between;gap:10px}.card header span,.card p{color:#536052;font-size:12px}.card svg{display:block;width:100%;margin:8px 0;image-rendering:pixelated}.card footer{justify-content:flex-start}.card a{color:#234c86}</style></head><body>
<h1>Brunch Bros level gallery</h1><p class="summary">${summary.count} seeds from ${summary.firstSeed}; ${summary.validCount} valid; ${summary.uniqueTopologyCount} unique macro topologies.</p><p class="legend">All 16 rooms are connected. Red is the guaranteed route; ○ is spawn; ■ is exit.</p><main class="gallery">${cards}</main></body></html>
`;
}

const options = readArguments(process.argv.slice(2));
const outputDirectory = resolve(options.out);
const levelsDirectory = resolve(outputDirectory, 'levels');
mkdirSync(levelsDirectory, { recursive: true });
const tilesetSource = relative(levelsDirectory, resolve('gfx/dining_room.tsx')).replaceAll('\\', '/');

const levels = [];
for (let offset = 0; offset < options.count; offset++) {
  const seed = (options.seed + offset) & 0xffff;
  const level = generateLevel(seed);
  levels.push(level);
  const name = String(seed).padStart(5, '0');
  writeFileSync(resolve(levelsDirectory, `${name}.tmx`), levelToTmx(level, tilesetSource));
  writeFileSync(resolve(levelsDirectory, `${name}.json`), `${JSON.stringify(level, null, 2)}\n`);
}

const failures = levels.filter(level => !level.validation.valid).map(level => ({ seed: level.seed, errors: level.validation.errors }));
const portEntries = levels.flatMap(level => level.roomPorts);
const summary = {
  version: 2,
  biome: options.biome,
  firstSeed: options.seed,
  count: options.count,
  validCount: levels.length - failures.length,
  failures,
  uniqueTopologyCount: new Set(levels.map(topologySignature)).size,
  routeLengths: histogram(levels, level => level.criticalRouteLength),
  spawnColumns: histogram(levels, level => level.columns[0]),
  exitColumns: histogram(levels, level => level.columns[4]),
  roomPortMasks: histogram(portEntries, value => value),
  wideSeams: levels.reduce((total, level) => total + level.roomWidePorts.filter(ports => ports & 2).length, 0),
  traversalClasses: histogram(levels.flatMap(level => level.roomTraversalClasses), value => value),
};

writeFileSync(resolve(outputDirectory, 'summary.json'), `${JSON.stringify(summary, null, 2)}\n`);
writeFileSync(resolve(outputDirectory, 'index.html'), renderGallery(levels, summary));

console.log(`Generated ${options.count} levels in ${options.out}; ${summary.uniqueTopologyCount} unique topologies; ${failures.length} failures.`);
if (failures.length) process.exitCode = 1;
