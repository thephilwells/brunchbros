import { readFileSync, writeFileSync } from 'node:fs';
import { semanticCellsToTileIds } from './lib/room-templates.mjs';

const width = 40;
const height = 32;
const source = 'data/room-templates/dining-room-prototypes.json';
const set = JSON.parse(readFileSync(source, 'utf8'));
if (set.version !== 1 || set.roomWidth !== 10 || set.roomHeight !== 8 || set.templates.length !== 4) throw new Error('Prototype set must contain four 10×8 templates');

const [left, right, upper, lower] = set.templates;
if (left.seams.east !== 'wide' || right.seams.west !== 'wide') throw new Error('Horizontal pair must declare matching wide seams');
if (upper.seams.south !== 'wide' || lower.seams.north !== 'wide') throw new Error('Vertical pair must declare matching wide seams');
if (right.seams.east !== 'standard' || lower.seams.west !== 'standard') throw new Error('Domino pairs must declare their matching standard connection');
if (lower.traversalClass !== 'ledge_catch') throw new Error('Lower vertical prototype must require ledge catch');
for (const template of set.templates) {
  if (template.rows.length !== set.roomHeight || template.rows.some(row => row.length !== set.roomWidth || [...row].some(cell => !'.#='.includes(cell)))) {
    throw new Error(`${template.id} must contain an 8×10 semantic grid`);
  }
}
for (let y = 1; y <= 6; y++) {
  if (left.rows[y][9] !== '.' || right.rows[y][0] !== '.') throw new Error(`Wide seam is closed at row ${y}`);
}
for (let x = 1; x <= 8; x++) {
  if (upper.rows[7][x] !== '.' || lower.rows[0][x] !== '.') throw new Error(`Vertical wide seam is closed at column ${x}`);
}
for (let y = 5; y <= 6; y++) {
  if (right.rows[y][9] !== '.' || lower.rows[y][0] !== '.') throw new Error(`Standard connection is closed at row ${y}`);
}
if ((lower.ledge.departureSurfaceRow - lower.ledge.targetSurfaceRow) * 8 !== 32) throw new Error('Ledge-catch rise must be 32 pixels');

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

const placements = [
  place(left, 0, 16),
  place(right, 10, 16),
  place(upper, 20, 8),
  place(lower, 20, 16),
];

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
  ` <layer id="1" name="Horizontal and Vertical Dominoes" width="${width}" height="${height}">`,
  '  <data encoding="csv">',
  tiles.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  ' <objectgroup id="2" name="Playtest Metadata">',
  ...objects,
  '  <object id="5" name="chef_spawn" type="spawn" x="20" y="184"><point/></object>',
  '  <object id="6" name="ledge_edge" type="ledge_catch" x="208" y="152"><point/></object>',
  '  <object id="7" name="vertical_open_seam" type="wide_seam" x="168" y="120" width="64" height="16"/>',
  ' </objectgroup>',
  '</map>',
  '',
].join('\n'));
writeFileSync('build/room_variant_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/room_variant_playtest.inc', [
  'DEF PLAYTEST_PLAYER_X EQU 20',
  'DEF PLAYTEST_PLAYER_Y EQU 184',
  '',
].join('\n'));

console.log('Generated horizontal and vertical domino playtest map.');
