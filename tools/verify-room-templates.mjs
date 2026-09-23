import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  loadRoomTemplateSet,
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

console.log('All 15 room port masks and tile-level traversal contracts verified.');
