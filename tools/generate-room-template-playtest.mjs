import { writeFileSync } from 'node:fs';
import {
  loadRoomTemplateSet,
  semanticCellsToTileIds,
  validateRoomTemplateSet,
} from './lib/room-templates.mjs';

const width = 40;
const height = 32;
const source = 'data/room-templates/dining-room.json';
const set = loadRoomTemplateSet(source);
const errors = validateRoomTemplateSet(set);
if (errors.length) throw new Error(errors.join('\n'));

const cells = Array.from({ length: height }, () => Array(width).fill('.'));
for (let x = 0; x < width; x++) {
  cells[0][x] = '#';
  cells[height - 1][x] = '#';
}
for (let y = 0; y < height; y++) {
  cells[y][0] = '#';
  cells[y][width - 1] = '#';
}

function placeTemplate(id, originX, originY) {
  const template = set.templates.find(candidate => candidate.id === id);
  for (let y = 0; y < set.roomHeight; y++) {
    for (let x = 0; x < set.roomWidth; x++) cells[originY + y][originX + x] = template.rows[y][x];
  }
  return { template, originX, originY };
}

const placements = [
  placeTemplate('ns_ordinary_0', 10, 8),
  placeTemplate('ne_ordinary_0', 10, 16),
  placeTemplate('we_ordinary_0', 20, 16),
];

for (let x = 8; x <= 21; x++) cells[1][x] = '#';
for (let y = 1; y <= 8; y++) {
  cells[y][8] = '#';
  cells[y][21] = '#';
}
for (const x of [9, 20]) cells[8][x] = '#';
for (let x = 30; x < width; x++) cells[23][x] = '#';

const tiles = semanticCellsToTileIds(cells);
const objects = placements.map(({ template, originX, originY }, index) => [
  `  <object id="${index + 1}" name="${template.id}" type="room_template" x="${originX * 8}" y="${originY * 8}" width="${set.roomWidth * 8}" height="${set.roomHeight * 8}">`,
  `   <properties><property name="port_mask" type="int" value="${template.portMask}"/></properties>`,
  '  </object>',
].join('\n'));

writeFileSync('gfx/room_template_playtest.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  `<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="${width}" height="${height}" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">`,
  ' <properties><property name="source" value="../data/room-templates/dining-room.json"/></properties>',
  ' <tileset firstgid="1" source="dining_room.tsx"/>',
  ` <layer id="1" name="Playable Terrain" width="${width}" height="${height}">`,
  '  <data encoding="csv">',
  tiles.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  ' <objectgroup id="2" name="Playtest Metadata">',
  ...objects,
  '  <object id="4" name="chef_spawn" type="spawn" x="280" y="184"><point/></object>',
  ' </objectgroup>',
  '</map>',
  '',
].join('\n'));
writeFileSync('build/room_template_playtest.tilemap', Buffer.from(tiles.flat()));

console.log('Generated the 40×32 room-template playtest map.');
