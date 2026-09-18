# Background tile manifest

Status: **IDs 0–24, 32–58, 64–75, and 80 implemented in the dining-room sheet**,
2026-09-18. Remaining assignments and art are proposed. Contract and VRAM addresses:
[background asset specification](background-assets.md).

## Sheet layout and counting

Each biome starts with 128 fixed 8×8 slots in a 128×64 PNG. IDs below are
local Tiled IDs and intended BG map bytes, not Tiled GIDs or sprite IDs.
Pixel origin for ID `i`: `x = (i % 16) * 8`, `y = floor(i / 16) * 8`.
One slot costs 16 bytes regardless of how often it appears in a room.

| IDs | Count | Allocation | Art commitment now |
|---|---:|---|---|
| 0–31 | 32 | Shared structural vocabulary | 25 authored, 7 reserved |
| 32–63 | 32 | Biome fixtures assembled from several tiles | 27 dining authored, 5 budgeted |
| 64–79 | 16 | Biome landmark/entrance artwork | 12 dining authored, 4 budgeted |
| 80–95 | 16 | Biome rear surfaces | 1 dining authored, 15 budgeted |
| 96–111 | 16 | Biome decorative details | Budget only |
| 112–127 | 16 | Unassigned within the initial sheet | Reserved |
| **0–127** | **128** | **2,048 bytes resident** | **65 authored, 40 budgeted, 23 reserved** |

These are caps, not a request to fill every slot. The common-material
pilot authors 17 tiles (0–16) and marks all other slots reserved in its
TSX. The dining sheet adds eight shared rear/trim tiles, 18 passable dining
fixture tiles, one one-way test tile, five dining-table tiles, three
dining-chair tiles, a 12-tile landmark, and one wallpaper motif. Its
unassigned slots remain reserved in the TSX.
All four biomes use the same structural meanings; matching pixels are
optional. Biome rows need an itemized footprint review before generation.

## Shared solid vocabulary: IDs 0–16

Tile 0, `empty`, is opaque white with `collision=empty`, `role=empty`.
Every other tile below has `collision=solid`, `role=structure`, and occupies
the full 8×8 cell. The four edges are N (top), E (right), S (bottom), W
(left). A neighbor bit means a solid neighbor, not an exposed edge:
N=1, E=2, S=4, W=8. `ID = 1 + neighbor_mask`.

| ID | Name | Mask | Connected neighbors | Exposed edges |
|---|---|---:|---|---|
| 1 | solid_isolated | 0 | None | N E S W |
| 2 | solid_n | 1 | N | E S W |
| 3 | solid_e | 2 | E | N S W |
| 4 | solid_ne | 3 | N E | S W |
| 5 | solid_s | 4 | S | N E W |
| 6 | solid_ns | 5 | N S | E W |
| 7 | solid_es | 6 | E S | N W |
| 8 | solid_nes | 7 | N E S | W |
| 9 | solid_w | 8 | W | N E S |
| 10 | solid_nw | 9 | N W | E S |
| 11 | solid_ew | 10 | E W | N S |
| 12 | solid_new | 11 | N E W | S |
| 13 | solid_sw | 12 | S W | N E |
| 14 | solid_nsw | 13 | N S W | E |
| 15 | solid_esw | 14 | E S W | N |
| 16 | solid_nesw | 15 | N E S W | None |

Examples, assuming surrounding cells are empty:

- Three-cell platform: IDs **3, 11, 9**, left to right.
- Three-cell pillar: IDs **5, 6, 2**, top to bottom.
- A 3×3 solid rectangle, in rows: **7,15,13 / 8,16,14 / 4,12,10**.
- A floor extending downward uses ID 15 along its top away from corners.
- The ceiling underside uses ID 12 away from corners.
- A single cell uses ID 1, so no separate floating-block asset is required.

The names describe connected neighbors and remain meaningful across all
biomes. A future procedural renderer can choose tiles from solidity using
this table. It does not provide a level generator or guarantee reachable
rooms. Outside-world solidity must be specified by that renderer; authored
fixture maps use empty outside cells unless an explicit border is present.

Art rules for every structural variant:

- Material continues across connected edges; texture phase is anchored to
  the 8×8 grid. No accidental outline where two solids meet.
- Exposed edges have a clear boundary at the cell perimeter. All solid
  variants must be visibly solid, including the fully surrounded filler.
- Draw orientation variants separately; no runtime/Tiled flips.
- Diagonal neighbors do not change this tile. Use simple square joins;
  diagonal-sensitive inner-corner shading is deferred pending pilot review.

## Shared rear surfaces and trim: IDs 17–31

All assigned tiles here have `collision=empty`. Rear surfaces describe
scenery behind the chef, whereas solid walls block movement.

| ID | Name | Role | Required behavior |
|---|---|---|---|
| 17 | rear_plain | rear | Quiet light-gray fill, repeats in both axes |
| 18 | rear_texture_a | rear | Sparse texture, repeats in both axes |
| 19 | rear_texture_b | rear | Alternate texture compatible with 18 on all edges |
| 20 | rear_recess | rear | Darker recess fill, repeats in both axes; test chef contrast |
| 21 | trim_h_left | trim | Left cap of a decorative horizontal band |
| 22 | trim_h_middle | trim | Horizontal band, repeats left/right |
| 23 | trim_h_right | trim | Right cap matching the middle |
| 24 | trim_h_single | trim | One-cell band with both ends finished |
| 25–31 | reserved_shared | reserved | Opaque white; not placeable |

Trim backgrounds must match rear_plain. They replace cells in the rendered
map, so placing the same trim over a different rear texture requires a
separate composite tile and budget review. Bands must read as wall trim,
not supporting platforms. Apply the same principle to future props.

## Passable dining-room groups: IDs 32–49, 64–75, 80

These are passable wall decorations on the single background layer. They
replace rear-fill cells rather than overlay them. Multi-tile component
parts are in row-major order; Tiled metadata records `component`, `part_x`,
and `part_y` for those parts.

| IDs | Component | Footprint | Placement and reuse |
|---|---|---:|---|
| 32–39 | `menu_board` | 4×2 tiles (32×16 px) | One framed board; place all eight parts together |
| 40–43 | `wall_mirror` | 2×2 tiles (16×16 px) | One framed mirror; place all four parts together |
| 44–47 | `wall_clock` | 2×2 tiles (16×16 px) | One round clock; place all four parts together |
| 48–49 | `wall_sconce` | 1×2 tiles (8×16 px) | One light fixture; place both parts together |
| 64–75 | `serving_hatch` | 4×3 tiles (32×24 px) | Decorative back-wall pass-through; no transition or collision |
| 80 | `dining_wallpaper_motif` | 1 tile (8×8 px) | Sparse accent in a field of `rear_plain` |

The dining-room fixture places a menu board at tile (3,4), mirror at
(24,4), clock at (8,4), sconce at (19,4), and serving hatch at (13,3).
Sparse wallpaper motifs appear on the left and right wall fields. A
four-tile-wide recess patch occupies rows 7–9 near the right edge, and
shared trim spans row 11. The solid platform/wall cells use IDs 1–16 from
the pilot without reskinning. A second gallery of the same five components
spans columns 1–17 and rows 21–23, with sparse wallpaper below, so the art
remains visible after the chef lands on the bottom floor. ID 24 also
appears once as an isolated trim sample. This map is a visual and
integration fixture, not a procedural room template.

These groups exhaust the current *passable wall-decoration* vocabulary,
not the tile budget. IDs 59–63, 76–79, 81–111 remain reserved in the
current atlas. Booth and counter art still need exact gameplay
footprints and tile budgets.

## One-way collision pilot: ID 50

`one_way_test_top` is a repeatable horizontal test strip with
`collision=one_way` and `role=platform_test`. Four copies sit at row 24,
columns 9–12, directly below the lower serving hatch. The drawn top edge
is the tile's upper boundary (world Y=192). The chef can jump through it
from the floor at Y=216 and land at Y=192. This is a collision/contrast
fixture, not final counter, booth, table, or chair art.
The initial spawn at X=88, Y=88 has a clear fall lane through columns
10–11, allowing a drop onto the strip from level-start height.

For all four furniture families, only the tile row containing the
designated top surface receives `one_way`; the other visual parts remain
`empty`. That surface must align with the tile row's upper edge. Chair and
booth seats are the landing planes, with backs passable.

## Dining table: IDs 51–55

The 4×2-tile (32×16 px) table uses top row `51, 52, 52, 53` and leg row
`54, 17, 17, 55`. ID 52 repeats to extend the tabletop; ID 17 is the
shared plain rear fill between its legs. IDs 51–53 have
`collision=one_way` at the tabletop's upper edge. IDs 54–55 and the rear
fill are passable, so the chef can approach from either side or jump
through the table. The fixture places it at columns 14–17, rows 25–26,
with the legs touching the solid floor at row 27. Its top is world Y=200,
16 px above floor height. Its one-way behavior was confirmed in SameBoy;
booths and counters remain unassigned.

## Dining chair: IDs 56–58

The 2×2-tile (16×16 px) left-facing chair uses upper row `17, 56` and
lower row `57, 58`. ID 56 is a passable chair back. IDs 57–58 form a
one-way seat whose upper edge is the landing plane. The seat tiles also
contain the chair's short legs; all non-seat pixels in those tiles share
the seat's one-way collision type because collision is per 8×8 cell.
The fixture places the chair at columns 19–20, rows 25–26, with its feet
touching the solid floor at row 27. The seat is world Y=208, eight pixels
below the table top and eight pixels above the floor. Its art and movement
await hands-on SameBoy review.

## Future biome vocabulary guide

| Biome | Structural material candidate | Fixture candidates | Landmark candidates | Rear/details candidates |
|---|---|---|---|---|
| Dining room | Floor/wall cross-section with diner trim | Booth, service counter, table, chair (one-way tops) | Entry/exit doorway (behavior undecided) | Further motifs only if room modules need them |
| Kitchen | Ceramic surface over solid masonry | Range, sink, cabinets | Vent hood or kitchen door | Tile wall, pipes, pans, utensils |
| Patio | Paving/deck over solid earth | Planter, outdoor table | Awning or patio exit | Fence, foliage, distant outdoor scenery |
| Deep freezer | Frosted insulated structure | Storage rack, frozen crates | Insulated doorway or cooling unit | Wall panels, pipes, frost |

Except for the passable dining-room groups above, candidates are a menu for
later reviews, not a commitment that all fit.
Count unique 8×8 component tiles, not named objects: a 32×32 fixture can
cost 16 slots before reuse. Repeated shelf middles may cost only one slot.
Allocate doors by actual opening dimensions before art production.

Biome fixtures in this first contract are passable scenery. Anything the
chef should stand on must use the solid vocabulary or receive an explicit
collision extension. Entrance artwork does not create a level transition.
Animated fans, damaging icicles, slippery ice, and other behavior-bearing
assets await their gameplay specifications.

## Reserved upper BG pool

| BG IDs | Count | Purpose |
|---|---:|---|
| 128–191 | 64 | Environment growth after the first sheet is proven |
| 192–223 | 32 | Future HUD glyphs/icons; not a full font commitment |
| 224–255 | 32 | Unassigned capacity |

These IDs are outside the initial PNG/TSX and must not appear in its maps.
They physically overlap sprite indices 128–255, which the proposed VRAM
ownership rules prohibit sprites from using.

## Group review order after contract approval

1. Empty + 16 structural variants in one material; test geometry and seams.
2. Four rear surfaces + four trim tiles; test readability with the chef.
3. One biome's small fixture group, with exact footprints and reuse counts.
4. Its landmark and decorative details, then a complete fixture room.
5. Repeat for other biomes using the proven vocabulary and budget.

Each group must pass the asset specification's relevant pixel, Tiled, and
conversion checks before expansion. Emulator acceptance additionally waits
for the explicit game integration steps; no visual output alone establishes
that the current ROM can consume it.
