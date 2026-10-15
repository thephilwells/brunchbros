import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 14; y < height; y++) {
  for (let x = 0; x < width; x++) {
    if (y <= 15 || y >= 29 || x <= 2 || (x >= 19 && x <= 20)) solid[y][x] = true;
  }
}
for (let y = 24; y <= 28; y++) {
  for (let x = 12; x <= 15; x++) solid[y][x] = true;
}
for (let x = 3; x <= 8; x++) solid[22][x] = true;

const tiles = solid.flatMap((row, y) => row.map((occupied, x) => {
  if (!occupied) return 17;
  return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
}));

writeFileSync('build/combat_playtest.tilemap', Buffer.from(tiles));
writeFileSync('build/combat_playtest.inc', [
  'DEF COMBAT_PLAYTEST_PLAYER_X EQU 48',
  'DEF COMBAT_PLAYTEST_PLAYER_Y EQU 232',
  'DEF COMBAT_PLAYTEST_WEINER_X EQU 80',
  'DEF COMBAT_PLAYTEST_WEINER_Y EQU 216',
  '',
].join('\n'));
