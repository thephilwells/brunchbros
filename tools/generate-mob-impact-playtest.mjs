import { writeFileSync } from 'node:fs';

const width = 40;
const height = 32;
const solid = Array.from({ length: height }, () => Array(width).fill(false));

for (let y = 29; y < height; y++) {
  for (let x = 0; x < width; x++) solid[y][x] = true;
}
for (let y = 4; y < 29; y++) {
  solid[y][0] = true;
  solid[y][39] = true;
}

const tiles = solid.map((row, y) => row.map((occupied, x) => {
  if (occupied) return 1 +
    (y > 0 && solid[y - 1][x] ? 1 : 0) +
    (x < width - 1 && solid[y][x + 1] ? 2 : 0) +
    (y < height - 1 && solid[y + 1][x] ? 4 : 0) +
    (x > 0 && solid[y][x - 1] ? 8 : 0);
  if ((y === 23 && x >= 22 && x <= 33) ||
      (y === 17 && x >= 18 && x <= 24) ||
      (y === 12 && x >= 25 && x <= 31)) return 50;
  if ((x * 3 + y * 5) % 29 === 0) return 18;
  return 17;
}));

writeFileSync('build/mob_impact_playtest.tilemap', Buffer.from(tiles.flat()));
writeFileSync('build/mob_impact_playtest.inc', [
  'DEF MOB_IMPACT_PLAYTEST_PLAYER_X EQU 32',
  'DEF MOB_IMPACT_PLAYTEST_PLAYER_Y EQU 232',
  'DEF MOB_IMPACT_PLAYTEST_EGG0_X EQU 56',
  'DEF MOB_IMPACT_PLAYTEST_EGG1_X EQU 80',
  'DEF MOB_IMPACT_PLAYTEST_EGG2_X EQU 104',
  'DEF MOB_IMPACT_PLAYTEST_EGG3_X EQU 128',
  'DEF MOB_IMPACT_PLAYTEST_EGG_Y EQU 232',
  'DEF MOB_IMPACT_PLAYTEST_WEINER_X EQU 160',
  'DEF MOB_IMPACT_PLAYTEST_WEINER_Y EQU 216',
  'DEF MOB_IMPACT_PLAYTEST_BURGER_X EQU 200',
  'DEF MOB_IMPACT_PLAYTEST_BURGER_Y EQU 184',
  'DEF MOB_IMPACT_PLAYTEST_PANCAKE_X EQU 184',
  'DEF MOB_IMPACT_PLAYTEST_PANCAKE_Y EQU 136',
  'DEF MOB_IMPACT_PLAYTEST_FRIED_EGG_X EQU 248',
  'DEF MOB_IMPACT_PLAYTEST_FRIED_EGG_Y EQU 184',
  'DEF MOB_IMPACT_PLAYTEST_DISCO_FRY_X EQU 224',
  'DEF MOB_IMPACT_PLAYTEST_DISCO_FRY_Y EQU 96',
  'DEF MOB_IMPACT_PLAYTEST_ICE_CUBE_X EQU 288',
  'DEF MOB_IMPACT_PLAYTEST_ICE_CUBE_Y EQU 80',
  '',
].join('\n'));
