# Background assets — constrained specification

Status: **Structural pilot, shared descent exit, passable dining-room
vocabulary, dining table, chair, booth, and counter implemented** as of
2026-09-21. Exit visual review, other biome art, and upper-pool allocation
remain open. Companion:
[tile manifest](background-tile-manifest.md).

## Purpose and scope

Produce environment assets that can be opened directly in Tiled, converted
to Game Boy tile data without manual pixel repair, and integrated through
a documented loader/map conversion contract. Cover dining room, kitchen,
patio, and deep freezer with a shared structural vocabulary.

The implemented art groups have PNGs, Tiled tilesets and fixture maps, exact
conversion, and a matching ROM loader/collision check. Remaining groups
follow their own reviews. A PNG alone does not describe game behavior.

## Current baseline

Before pilot integration, inspected 2026-09-15:

- `src/main.asm:35`: background tile 0 loads at `$8000`.
- `src/main.asm:47`: placeholder wall tile 45 loads at `$82D0`.
- `src/main.asm:135`: chef tiles 1–44 load at `$8010` (704 bytes).
- `src/main.asm:168`: `LCDC=$93` selects unsigned BG addressing.
- `src/main.asm:114`: `BGP=$E0` maps indices 0 and 1 to white;
  the adjacent comment calling this an identity palette is stale.
- `src/main.asm:116`: `OBP0=$E0` preserves the chef's opaque-white art.
- `src/main.asm:692`: collision reads the displayed tile and recognizes
  only index 45 as solid.

## Hardware facts and proposed allocation

DMG tile storage has three 128-tile blocks, each tile occupying 16 bytes.
Sprites access `$8000–$8FFF`. With signed BG addressing (`LCDC.4=0`),
BG/Window indices 0–127 address `$9000–$97FF`, and 128–255 address
`$8800–$8FFF`. BG and Window share their tile pool. These are hardware
rules; the allocation below is our proposed convention.

Source: [Pan Docs tile data](https://github.com/gbdev/pandocs/blob/master/src/Tile_Data.md)
and [tile maps](https://github.com/gbdev/pandocs/blob/master/src/Tile_Maps.md).

| VRAM range | Owner | Slots | Bytes |
|---|---|---:|---:|
| `$8000–$800F` | Sprite index 0, reserved | 1 | 16 |
| `$8010–$830F` | Existing chef, sprite indices 1–48 | 48 | 768 |
| `$8310–$87FF` | Remaining sprite capacity, indices 49–127 | 79 | 1,264 |
| `$8800–$8BFF` | Environment expansion, BG IDs 128–191 | 64 | 1,024 |
| `$8C00–$8DFF` | Future HUD, BG/Window IDs 192–223 | 32 | 512 |
| `$8E00–$8FFF` | Unassigned BG/Window capacity, IDs 224–255 | 32 | 512 |
| `$9000–$91FF` | Shared vocabulary, BG IDs 0–31 | 32 | 512 |
| `$9200–$97FF` | Current biome allocation, BG IDs 32–127 | 96 | 1,536 |
| `$9800–$9BFF` | Current scrolling background map | — | 1,024 |
| `$9C00–$9FFF` | Second map, reserved for future Window use | — | 1,024 |
| **Total** | **384 tile slots plus two maps** | **384** | **8,192** |

Recommendation: adopt this ownership split, start with at most **128
environment slots resident**, and leave the upper BG ranges unused until
content needs them. The sprite reserve is tile storage, not a promise about
how many actors can be displayed at once. Sprites must not use indices
128–255 under this allocation: those physical slots belong to BG/Window.

Why change addressing now: it keeps all current chef indices intact and
separates the first 128 environment slots from sprite storage. Remaining
unsigned is possible, but growing backgrounds would compete directly with
sprite slots and leave `$9000–$97FF` unavailable to the current BG mode.

One biome is loaded at a time. Shared means matching IDs, meanings, and
connection rules; structural pixels may be reskinned per biome. Loading a
different biome may therefore replace all 128 environment tiles. Mixed-biome
rooms are outside this first contract.

VRAM is separate from cartridge ROM. A 128-tile sheet takes 2,048 bytes
uncompressed; four such sheets take 8,192 bytes before maps and code.
Future banked-ROM layout is a separate decision. Reserve slots in an atlas
need not become permanently duplicated data in a shipping cartridge.

## Pixel and presentation contract

- Side-on orthographic platformer art, sized against the existing 16×16 chef.
- One hardware tile is exactly 8×8 pixels. Props can span several tiles;
  their footprint must be an integer number of tiles. Room/module dimensions
  and any 16×16 metatile scheme remain separate decisions.
- Source PNG colors: exactly the allowed set `#FFFFFF`, `#AAAAAA`,
  `#555555`, `#000000`, with every pixel opaque. A tile can use a subset.
  No antialiasing, scaling artifacts, labels, gutters, margins, or grid lines.
- Convert using the established `rgbgfx -c dmg=E4` mapping. Proposed
  background palette: `BGP=$E4`, preserving all four shades. Retain the
  chef's `OBP0=$E0`; it serves a different purpose.
- Background index 0 is visible white, not transparency. Rear-wall graphics
  and scenery are passable drawing in the same background map.
- Solid contact edges must read clearly at native 160×144 resolution.
  Use dark boundaries for solid architecture; start rear surfaces with
  indices 0/1, sparse index 2 details, and no black contact-like outlines.
  Validate contrast with the chef before expanding the style.
- Default lighting comes from above-left, but connection correctness takes
  precedence over highlights. Mirrored pieces must be explicitly drawn.
- No reliance on per-tile BG flipping, rotation, or palettes: those BG
  attributes are unavailable on DMG. Tiled transformations are disallowed
  for this first asset contract.

Palette reference: [Pan Docs palettes](https://github.com/gbdev/pandocs/blob/master/src/Palettes.md).

## Structural and gameplay contract

The structural vocabulary has two collision meanings: **empty** and **full
solid 8×8 cell**. Floors, ceilings, walls, isolated blocks, pillars, and
narrow structural platforms are compositions of the same solid cells. A
structural platform is solid from below as well as above. The dining-room
furniture pilot adds a third meaning, **one-way top**: the chef passes
through it from below and from either side, but lands on its top while
falling. Ladders, slopes, destructibility, ice friction, and hazards still
require later gameplay decisions.

The chef's world-space `PlayerY` is his feet coordinate. On a fall, test
every tile-top boundary from the old feet position through the tentative
position, including the starting boundary when already standing on it.
At the first horizontally overlapping full-solid or one-way surface, snap
`PlayerY` to that boundary and stop the fall. Rising and horizontal checks
ignore one-way cells. Grounded/jump checks accept both surface types. The
seat line of a booth or chair is the landing plane; backs and legs are
passable art. Each landing plane aligns with the upper edge of an 8×8 tile;
table and counter tops follow the same rule. No drop-through input is
currently implemented. The accepted future rule is that Down+A suppresses
one-way support long enough for the chef to pass below the landing plane;
full-solid cells remain impassable.

For each solid cell, the four cardinal neighbors determine which edges are
exposed. There are 16 possible combinations, enumerated in the manifest.
This supports arbitrary arrangements of full solid cells. It deliberately
does not distinguish diagonal neighbors: no diagonal-sensitive concave
corner bevels in the first style. That visual limitation must be checked
in the initial concave-corner test, not discovered after four biomes exist.

Connected edges must join without seams. Exposed edges mark the true cell
boundary; rounding or inset drawings must not imply passable space inside
a solid cell. Decorative textures cannot change collision or create false
platform silhouettes. Generate/select collision layout before choosing art.

Room connectivity, jump reachability, and enemy/hazard placement are not
encoded by this tile vocabulary. They belong to the future room/generation
specification. Every tested traversable passage must accommodate the current
12×16 terrain hitbox (at least two tiles in both relevant dimensions on the
8×8 structural grid).

## Tiled and binary deliverables

For each biome, a PNG atlas and external TSX tileset using relative paths:

- Atlas: **128×64 pixels**, 16 columns × 8 rows, 128 fixed slots.
- TSX: tile width/height 8, tile count 128, columns 16, spacing/margin 0.
- Local ID is `row * 16 + column`. Reserved slots are opaque white,
  explicitly marked reserved, and prohibited in authored maps.
- Every assigned tile records `name` (string), `collision` (`empty`,
  `solid`, or `one_way` string), and `role` (string). Structural IDs 1–16
  additionally record `neighbor_mask` (integer 0–15). Reserved slots record
  `role=reserved`; they are not alternate empty tiles.
- First fixture map: finite orthogonal 32×32, one tile layer containing
  final rendered cells, one biome tileset. Decorative components replace
  cells in this layer; additional Tiled layers must not imply additional
  hardware scrolling layers or unbudgeted composites.
- No animation or tile transforms in the first TSX/map.

The retained structural pilot assigns only IDs 0–16. The dining-room sheet
adds shared IDs 17–30, passable dining IDs 32–49, 64–75, and 80, the
one-way test surface at ID 50, dining-table IDs 51–55, dining-chair
IDs 56–58, dining-booth IDs 59–63, and dining-counter IDs 112–115.
Both TSX files mark all other slots reserved,
even where the manifest budgets a later role.

Future map export resolves Tiled GIDs using `firstgid`, rather than copying
GIDs as Game Boy indices. GID 0 (an empty Tiled cell) exports as BG tile 0;
the explicitly painted local tile 0 also exports as BG tile 0. Reject
transforms and reserved/foreign IDs. Tiled properties are editor data and
must be exported/implemented explicitly before the ROM can use them.
See [Tiled global IDs](https://doc.mapeditor.org/en/stable/reference/global-tile-ids/).

Initial tile binary: exactly 2,048 bytes, tile order preserved, loaded at `$9000`.
Do not deduplicate, flip-deduplicate, or reorder tiles during conversion;
fixed IDs are part of the contract. If the atlas later expands to 256 slots,
IDs 128–255 load at `$8800`, not past `$97FF` into map memory. That extension
needs its own export/load review.

The dining generator also exports a 128-byte collision-type table in local
tile-ID order (`0=empty`, `1=solid`, `2=one_way`). It is cartridge ROM data,
not another VRAM tile block; its values match the TSX `collision` properties.
Exit IDs 25–30 remain empty in this table. Their `role=exit` and
`interaction=press_down` metadata define a future interaction trigger, not
physical collision or a transition in the current ROM.

## Integration requirements

1. **Done for pilot:** Load the environment tiles at `$9000` and select signed BG addressing
   together. Merely toggling the addressing bit breaks existing BG lookups.
2. **Done for pilot:** Set `BGP=$E4`, preserving `OBP0=$E0`.
3. **Done for pilot:** Replace wall index 45 and its loader with the manifest's structural IDs.
4. **Done for one-way pilot:** Collision checks read a generated type table.
   IDs 1–16 are full solid; IDs 50–53, 57–58, 63, and 112–114 are
   one-way; table legs, chair back, booth back, counter front, and
   decorative IDs are empty.
   Side/head checks use full solid, while grounded and downward swept checks
   accept both collidable types.
5. **Done for pilot and passable dining-room groups:** Add atlas conversion and map export/build wiring.
   Load the current static fixture with LCD disabled using the established boot setup pattern.
6. **Pending hands-on check:** Verify timing and collision during scrolling. A valid atlas does not
   prove frame timing or platform physics correct.

## Acceptance criteria

- Atlas dimensions, palette, opacity, slot order, and metadata match this
  spec; TSX opens in Tiled without repairs or missing images.
- Converted bytes decode to the exact PNG pixel indices in row-major order.
- All 16 structural masks exist; opposite orientations use real slots.
- Fixture includes an isolated block, a rectangle, horizontal and vertical
  one-cell strips, steps, an L-shaped solid, a one-cell hole, a T-junction,
  and a cross. Inspect joins and exposed edges at 1× and integer zoom.
- Mask choice uses the complete neighboring layout, including across room
  boundaries; verify seams between adjoining modules when those exist.
- Collision agrees with solid cells; decorations remain passable; chef
  stays legible over each rear-fill and structural family.
- One-way cells allow ascent and side entry; feet land on their top even
  across a 16-pixel fall, and jumping from the top works. Seat artwork
  receives the one-way type only on its designated surface tiles.
- SameBoy DMG rendering matches Tiled's intended four shades, preserves all
  chef poses, and shows no corrupted tiles while moving/scrolling.
- No reads of uninitialized/reserved tiles and no writes into another
  owner's VRAM range. Expansion/HUD allocation remains unconsumed.

## Adopted baseline and next review

The pilot uses signed BG addressing, 128 initial environment slots, 8×8
full-cell solids, 16 cardinal-neighbor variants, and four distinct BG
shades. One biome is resident at a time; each additional fixture group and
biome still needs its own footprint and visual review.

The first art checkpoint was tile 0 plus the 16 solid variants in a neutral
material. Shared rear/trim tiles and passable dining-room groups now use
that same structure. Review rear-surface and chef contrast in SameBoy before
adding collidable dining fixtures or other biomes.
