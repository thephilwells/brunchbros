import { writeFileSync } from 'node:fs';
import {
  loadRoomTemplateSet,
  templateSetToFixture,
  validateRoomTemplateSet,
} from './lib/room-templates.mjs';

const source = 'data/room-templates/dining-room.json';
const set = loadRoomTemplateSet(source);
const errors = validateRoomTemplateSet(set);
if (errors.length) throw new Error(errors.join('\n'));

const fixture = templateSetToFixture(set);
const objects = fixture.placements.map(({ template, originX, originY }, index) => [
  `  <object id="${index + 1}" name="${template.id}" type="room_template" x="${originX * 8}" y="${originY * 8}" width="${set.roomWidth * 8}" height="${set.roomHeight * 8}">`,
  `   <properties><property name="port_mask" type="int" value="${template.portMask}"/></properties>`,
  '  </object>',
].join('\n'));

writeFileSync('gfx/room_template_fixture.tmx', [
  '<?xml version="1.0" encoding="UTF-8"?>',
  `<map version="1.10" tiledversion="1.12.2" orientation="orthogonal" renderorder="right-down" width="${fixture.width}" height="${fixture.height}" tilewidth="8" tileheight="8" infinite="0" backgroundcolor="#ffffff">`,
  ' <properties><property name="source" value="../data/room-templates/dining-room.json"/></properties>',
  ' <tileset firstgid="1" source="dining_room.tsx"/>',
  ` <layer id="1" name="Semantic Terrain" width="${fixture.width}" height="${fixture.height}">`,
  '  <data encoding="csv">',
  fixture.tiles.map(row => row.map(id => id + 1).join(',')).join(',\n'),
  '  </data>',
  ' </layer>',
  ' <objectgroup id="2" name="Template Bounds">',
  ...objects,
  ' </objectgroup>',
  '</map>',
  '',
].join('\n'));

console.log(`Generated ${set.templates.length} room templates in gfx/room_template_fixture.tmx.`);
