# Mob sprite budget exploration

This began as a planning estimate. The focused combat fixture now measures the
complete WEINER surface-crawl vocabulary directly.

## Current pressure

The implemented 24-pose WEINER sheet occupies 96 OBJ tiles at indices 76–171.
It contains four horizontal poses, four vertical poses, and sixteen two-frame
corner poses covering two turn classes in four orientations. Its 16×16 arches
genuinely occupy four hardware tiles per frame.

This direct fixture allocation favors animation review over compression. It is
not the production roster budget: production can remove duplicate flipped
poses or load a biome-specific subset after the motion is accepted.

## Roster estimate

These ranges assume animation reuse, hardware flipping, and tight crops. They
are deliberately provisional until each mob has a pose review.

| Mob | Estimated OBJ tiles |
|---|---:|
| WEINER | 96 fixture tiles before deduplication |
| BURGER | 12–16 |
| PANCAKE | 6–10 |
| FRIED_EGG | 12–16 |
| DISCO_FRY and gravy | 8–12 |
| ICE_CUBE | 8–12 |
| BOSS_MAN | 24+ |

The ordinary roster cannot remain resident alongside the uncompressed fixture
sheet before the boss, pickups, hit effects, or projectiles are considered.

## Available paths

The hardware still has capacity. OBJ indices 128–255 address `$8800–$8FFF`,
but the current project convention originally reserved that physical block for
future BG/Window IDs 128–255. The combat fixture now uses part of this block to
review all WEINER poses. Production still needs an explicit allocation and
deduplication decision before a second animated mob is added.

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

Accept and tune the motion in the fixture, then deduplicate the production
sheet before adding a second animated mob. Decide whether `$8800–$8FFF` remains
background expansion or becomes the upper OBJ pool. Continue tracking both
unique tile storage and worst-case OAM entries per scanline for every accepted
mob.
