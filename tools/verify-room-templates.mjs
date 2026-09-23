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

assert.deepEqual(set.templates.map(template => template.portMask).sort((a, b) => a - b), [3, 6, 12]);

const fixture = readFileSync('gfx/room_template_fixture.tmx', 'utf8');
assert.match(fixture, /width="36" height="10"/);
for (const template of set.templates) {
  assert.match(fixture, new RegExp(`name="${template.id}"`));
  assert.match(fixture, new RegExp(`name="port_mask" type="int" value="${template.portMask}"`));
}

console.log('W|E, N|S, and N|E room template contracts verified.');
