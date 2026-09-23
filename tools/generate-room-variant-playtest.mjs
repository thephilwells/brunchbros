import { readFileSync, writeFileSync } from 'node:fs';
import { semanticCellsToTileIds } from './lib/room-templates.mjs';

const width = 40;
const height = 32;
const source = 'data/room-templates/dining-room-prototypes.json';
const set = JSON.parse(readFileSync(source, 'utf8'));
if (set.version !== 1 || set.roomWidth !== 10 || set.roomHeight !== 8 || set.templates.length !== 2) throw new Error('Prototype set must contain two 10×8 templates');

const [left, right] = set.templates;
if (left.seams.east !== 'wide' || right.seams.west !== 'wide') throw new Error('Prototype pair must declare matching wide seams');
if (right.traversalClass !== 'ledge_catch') throw new Error('Right prototype must require ledge catch');
for (const template of set.templates) {
  if (template.rows.length !== set.roomHeight || template.rows.some(row => row.length !== set.roomWidth || [...row].some(cell => !'.#='.includes(cell)))) {
    throw new Error(`${template.id} must contain an 8×10 semantic grid`);
  }
}
for (let y = 1; y <= 6; y++) {
  if (left.rows[y][9] !== '.' || right.rows[y][0] !== '.') throw new Error(`Wide seam is closed at row ${y}`);
}
if ((right.ledge.departureSurfaceRow - right.ledge.targetSurfaceRow) * 8 !== 32) throw new Error('Ledge-catch rise must be 32 pixels');

const cells = Array.from({ length: height }, () => Array(width).fill('.'));
for (let x = 0; x < width; x++) {
  cells[0][x] = '#';
  cells[height - 1][x] = '#';
}
for (let y = 0; y < height; y++) {
  cells[y][0] = '#';
  cells[y][width - 1] = '#';
}

function place(template, originX, originY) {
  for (let y = 0; y < set.roomHeight; y++) {
    for (let x = 0; x < set.roomWidth; x++) cells[originY + y][originX + x] = template.rows[y][x];
  }
  return { template, originX, originY };
}

const placements = [place(left, 10, 16), place(right, 20, 16)];
for (let x = 20; x <= 29; x++) cells[8][x] = '#';
for (let y = 8; y <= 15; y++) {
  cells[y][20] = '#';
  cells[y][29] = '#';
}
for (let x = 20; x <= 23; x++) cells[15][x] = '#';
cells[15][29] = '#';

const tiles = semanticCellsToTileIds(cells);
const objects = placements.map(({ template, originX, originY }, index) => [
  `  <object id="${index + 1}" name="${template.id}" type="room_template" x="${originX * 8}" y="${originY * 8}" width="${set.roomWidth * 8}" height="${set.roomHeight * 8}">`,
  `   <properties><property name="traversal_class" value="${template.traversalClass}"/><property name="seams" value='${JSON.stringify(template.seams)}'/></properties>`,
  '  </object>',
].join('\n'));

writeFileSync('gfx/room_variant_playtest.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  `<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="${width}" height="${height}" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">`,
  ' <properties><property name="source" value="../data/room-templates/dining-room-prototypes.json"/></properties>',
  ' <tileset firstgid="1" source="dining_room.tsx"/>',
  ` <layer id="1" name="Wide Seam and Ledge Catch" width="${width}" height="${height}">`,
  '  <data encoding="csv">',
  tiles.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  ' <objectgroup id="2" name="Playtest Metadata">',
  ...objects,
  '  <object id="3" name="chef_spawn" type="spawn" x="100" y="184"><point/></object>',
  '  <object id="4" name="ledge_edge" type="ledge_catch" x="208" y="152"><point/></object>',
  ' </objectgroup>',
  '</map>',
  '',
].join('\n'));
writeFileSync('build/room_variant_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/room_variant_playtest.inc', [
  'DEF PLAYTEST_PLAYER_X EQU 100',
  'DEF PLAYTEST_PLAYER_Y EQU 184',
  '',
].join('\n'));

console.log('Generated the wide-seam and ledge-catch playtest map.');
