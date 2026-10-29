import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 29; y < height; y++) {
  for (let x = 0; x < width; x++) solid[y][x] = true;
}
for (let y = 10; y < 29; y++) {
  solid[y][1] = true;
  solid[y][38] = true;
}
for (let y = 20; y < 29; y++) solid[y][20] = true;

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));

writeFileSync('build/disco_fry_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/disco_fry_playtest.inc', [
  'DEF DISCO_FRY_PLAYTEST_PLAYER_X EQU 48',
  'DEF DISCO_FRY_PLAYTEST_PLAYER_Y EQU 232',
  'DEF DISCO_FRY_PLAYTEST_FRY_X EQU 112',
  'DEF DISCO_FRY_PLAYTEST_FRY_Y EQU 192',
  '',
].join('\n'));
