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

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if (y === 24 && ((x >= 5 && x <= 11) || (x >= 24 && x <= 30))) return 50;
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));
const exitX = 34;
const exitY = 26;
const exitTiles = [[25, 26], [27, 28], [29, 30]];
for (let y = 0; y < exitTiles.length; y++) {
  for (let x = 0; x < exitTiles[y].length; x++) tiles[exitY + y][exitX + x] = exitTiles[y][x];
}

writeFileSync('build/treasure_egg_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/treasure_egg_playtest.inc', [
  'DEF TREASURE_EGG_PLAYTEST_PLAYER_X EQU 48',
  'DEF TREASURE_EGG_PLAYTEST_PLAYER_Y EQU 232',
  'DEF TREASURE_EGG_PLAYTEST_HEART_X EQU 88',
  'DEF TREASURE_EGG_PLAYTEST_EMPTY_X EQU 128',
  'DEF TREASURE_EGG_PLAYTEST_KEY_X EQU 168',
  'DEF TREASURE_EGG_PLAYTEST_EGG_Y EQU 232',
  `DEF TREASURE_EGG_PLAYTEST_EXIT_X EQU ${exitX}`,
  `DEF TREASURE_EGG_PLAYTEST_EXIT_Y EQU ${exitY}`,
  '',
].join('\n'));
