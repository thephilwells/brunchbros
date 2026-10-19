import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 29; y < height; y++) {
  for (let x = 0; x < width; x++) solid[y][x] = true;
}
for (let y = 15; y < 29; y++) {
  solid[y][1] = true;
  solid[y][38] = true;
}
for (let y = 23; y < 29; y++) solid[y][24] = true;

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (y === 26 && ((x >= 8 && x <= 14) || (x >= 28 && x <= 34))) return 50;
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));

writeFileSync('build/burger_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/burger_playtest.inc', [
  'DEF BURGER_PLAYTEST_PLAYER_X EQU 48',
  'DEF BURGER_PLAYTEST_PLAYER_Y EQU 232',
  'DEF BURGER_PLAYTEST_BURGER_X EQU 112',
  'DEF BURGER_PLAYTEST_BURGER_Y EQU 232',
  '',
].join('\n'));
