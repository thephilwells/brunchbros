import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  loadRoomTemplateSet,
  PORT_NORTH,
  PORT_SOUTH,
  PORT_WEST,
  validateRoomTemplatePassage,
  validateRoomTemplateSet,
} from './lib/room-templates.mjs';

const source = 'data/room-templates/dining-room.json';
const set = loadRoomTemplateSet(source);
const errors = validateRoomTemplateSet(set);
assert.deepEqual(errors, []);

assert.deepEqual(set.templates.map(template => template.portMask).sort((a, b) => a - b), Array.from({ length: 15 }, (_, index) => index + 1));

const fixture = readFileSync('gfx/room_template_fixture.tmx', 'utf8');
assert.match(fixture, /width="180" height="10"/);
for (const template of set.templates) {
  assert.match(fixture, new RegExp(`name="${template.id}"`));
  assert.match(fixture, new RegExp(`name="port_mask" type="int" value="${template.portMask}"`));
}

const northSouth = set.templates.find(template => template.portMask === (PORT_NORTH | PORT_SOUTH));
assert.deepEqual(validateRoomTemplatePassage(northSouth, PORT_NORTH, PORT_SOUTH, 'ordinary'), []);
assert(validateRoomTemplatePassage(northSouth, PORT_SOUTH, PORT_NORTH, 'ordinary').some(error => error.includes('lacks ordinary traversal')));

const ledgeCatch = {
  portMask: PORT_WEST | PORT_NORTH,
  traversalClass: 'ledge_catch',
  rows: [
    '####...###',
    '....===..#',
    '.........#',
    '......####',
    '.........#',
    '.........#',
    '.........#',
    '##########',
  ],
};
assert.deepEqual(validateRoomTemplatePassage(ledgeCatch, PORT_NORTH, PORT_WEST, 'ledge_catch'), []);
assert(validateRoomTemplatePassage(ledgeCatch, PORT_WEST, PORT_NORTH, 'ordinary').some(error => error.includes('lacks ordinary traversal')));

console.log('All 15 room port masks and tile-level traversal contracts verified.');
