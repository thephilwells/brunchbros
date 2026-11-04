import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 29; y < height; y++) {
  for (let x = 0; x < width; x++) solid[y][x] = true;
}
for (let y = 12; y < 29; y++) {
  solid[y][1] = true;
  solid[y][38] = true;
}
for (let x = 31; x <= 36; x++) solid[19][x] = true;

const oneWayRows = [16, 19, 22, 25];

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (oneWayRows.includes(y) && x >= 8 && x <= 28) return 50;
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));

writeFileSync('build/ice_cube_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/ice_cube_playtest.inc', [
  'DEF ICE_CUBE_PLAYTEST_PLAYER_X EQU 160',
  'DEF ICE_CUBE_PLAYTEST_PLAYER_Y EQU 232',
  'DEF ICE_CUBE_PLAYTEST_CUBE_X EQU 160',
  'DEF ICE_CUBE_PLAYTEST_CUBE_Y EQU 112',
  '',
].join('\n'));
