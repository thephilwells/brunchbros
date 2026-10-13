# Mob sprite budget exploration

This is a planning estimate, not an accepted VRAM allocation.

## Current pressure

The current convention originally left 50 OBJ tiles at indices 78–127. The
implemented four-frame horizontal WEINER cycle occupies 16 tiles at indices
76–91 and leaves 36. Its 16×16 arches genuinely occupy four hardware tiles per
frame; the earlier 18–24 tile estimate for all twelve review poses was too low.

Converting the entire review sheet directly produces 48 tiles. There are 43
unique exact tile patterns, or 42 when per-tile horizontal and vertical flips
are considered. Metadata and blank-tile reuse could recover a few slots, but
the accepted art should be budgeted at roughly 40–48 tiles if all horizontal,
vertical, internal-corner, and external-edge poses become resident.

The review sheet itself consumes no VRAM. Only converted poses loaded by the
game count against this budget.

## Roster estimate

These ranges assume animation reuse, hardware flipping, and tight crops. They
are deliberately provisional until each mob has a pose review.

| Mob | Estimated OBJ tiles |
|---|---:|
| WEINER | 40–48 |
| BURGER | 12–16 |
| PANCAKE | 6–10 |
| FRIED_EGG | 12–16 |
| DISCO_FRY and gravy | 8–12 |
| ICE_CUBE | 8–12 |
| BOSS_MAN | 24+ |

The ordinary roster is therefore likely to require 86–114 tiles before the
boss, pickups, hit effects, or projectiles. The current 36-tile lower reserve
cannot hold the whole finished roster at once.

## Available paths

The hardware still has capacity. OBJ indices 128–255 address `$8800–$8FFF`,
but the current project convention reserves that physical block for future
BG/Window IDs 128–255. If each biome remains within the implemented 128-tile
environment atlas, assigning this unused block to sprites would add 128 OBJ
tiles and leave 164 free after the current index 91. This would replace the
future background-expansion reservation and requires an explicit allocation
decision before implementation.

The other useful boundary is residency. Cartridge ROM may contain every mob's
art without keeping every frame in VRAM. A level can load only its selected
biome roster while the LCD is off, and later content can limit a generated
level to a subset of that biome's species. Runtime tile caching is unnecessary
until measured content proves otherwise.

OAM is a separate, likely earlier constraint: the DMG can display 40 sprites
total and 10 on one scanline. A 16×16 actor normally consumes four OAM entries,
so the number and horizontal overlap of active actors matters even when their
tile art fits in VRAM.

## Recommendation

Keep the motion sheet exploratory and admit only accepted WEINER frames. Before
adding a second animated mob, decide whether `$8800–$8FFF` remains background
expansion or becomes the upper OBJ pool. Continue tracking both unique tile
storage and worst-case OAM entries per scanline for every accepted mob.
