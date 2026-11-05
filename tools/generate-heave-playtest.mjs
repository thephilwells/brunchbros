import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 29; y < height; y++) {
  for (let x = 0; x < width; x++) solid[y][x] = true;
}
for (let y = 15; y < 29; y++) {
  solid[y][38] = true;
}
for (let x = 13; x <= 19; x++) solid[24][x] = true;

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (y === 26 && ((x >= 3 && x <= 9) || (x >= 24 && x <= 31))) return 50;
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));

writeFileSync('build/heave_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/heave_playtest.inc', [
  'DEF HEAVE_PLAYTEST_PLAYER_X EQU 48',
  'DEF HEAVE_PLAYTEST_PLAYER_Y EQU 232',
  'DEF HEAVE_PLAYTEST_UNCRACKED_EMPTY_X EQU 80',
  'DEF HEAVE_PLAYTEST_CRACKED_EMPTY_X EQU 128',
  'DEF HEAVE_PLAYTEST_CRACKED_HEART_X EQU 184',
  'DEF HEAVE_PLAYTEST_CRACKED_KEY_X EQU 240',
  'DEF HEAVE_PLAYTEST_EGG_Y EQU 232',
  '',
].join('\n'));
