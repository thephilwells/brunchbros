# Dining-room composition

Status: **host/runtime floor furniture, background placement, and wallpaper
accepted; host-side WEINER population and gallery overlays provisionally
accepted on 2026-10-15**.

## Purpose

Turn the validated structural level into a recognizable dining room without
making required traversal depend on furniture, decoration, enemies, or loot.
This pass consumes the completed 40×32 structural map and cannot alter room
connectivity or the selected domino matching.

## Pass order

1. Generate room topology, structural templates, domino seams, traversal
   classes, and protected spawn/exit geometry.
2. Validate the undecorated critical route and every optional branch.
3. Mark placement reservations for ports, required landings, travel space,
   ledge-catch channels, wide seams, spawn, and exit.
4. Place passable rear-wall fixtures.
5. Place floor-anchored furniture outside reservations.
6. Place sparse wallpaper motifs in remaining plain rear cells.
7. Select encounter spawns from the remaining safe full-solid surfaces.
8. Revalidate the finished tile map. Loot placement remains a later pass.

Furniture is optional traversal. Removing every furniture tile must leave the
structural route valid. Furniture may create shortcuts, extra landing choices,
or Down+A opportunities, but it cannot be the only connection between required
surfaces.

## Background fixture manifest

`data/dining-room-background.json` defines the menu board, mirror, clock,
sconce, and serving hatch as passable multi-tile groups. Every fixture's bottom
edge sits two tiles above its visual chamber's floor. In a vertical domino this
is the lower room cell's floor, not the removed internal boundary. Every
referenced tile has `collision=empty`; these fixtures replace plain rear tiles
and never alter traversal.

Wide-seam pairs are treated as one visual chamber. The placement pass selects
one background composition across both halves, while an unmatched room is its
own chamber. A fixture stays inside one 10×8 room cell even when its visual
chamber is a domino. A sconce composition places a symmetric pair at the
one-third and two-thirds points of the usable chamber wall; if either exact
mounting point is obstructed, sconces are not eligible for that chamber.
Selection uses a chamber-local seed mix and does not advance the structural
PRNG.

Background fixtures may occupy cells reserved only because they belong to a
critical-route room. Port approaches, wide seams, spawn and exit envelopes,
and ledge-catch rooms remain protected for visual readability. Candidate
footprints must otherwise contain only plain rear tiles and retain a one-tile
horizontal margin from the room boundary.

## Wallpaper motifs

`data/dining-room-wallpaper.json` defines a final pass using the existing
passable tile 80. Candidate cells lie on a chamber-relative lattice beginning
two tiles from the left and one tile below the top, with four-tile horizontal
and three-tile vertical spacing. An ordinary chamber receives at most one motif;
a domino receives at most two. A chamber-local seed mix rotates the selected
positions through the valid candidates without advancing the structural PRNG.

Motifs replace only plain rear tile 17 after wall fixtures and furniture are
placed. Complete authored footprints are protected, including intentional rear-
tile holes inside chair and table groups. Port, seam, spawn, exit, and ledge-
catch reservations remain clear; critical-route reservation alone does not
block passable wallpaper. The host export records the pre-wallpaper map,
candidate counts, and selected cells for deterministic validation.

## Furniture manifest

`data/dining-room-furniture.json` is the machine-readable source for the four
accepted furniture groups. Tile IDs and collision remain owned by
`gfx/dining_room.tsx`; the manifest records composition, dimensions, landing
rows, and floor anchoring without duplicating tile properties.

| Component | Footprint | Landing plane | Floor relationship |
|---|---:|---:|---|
| Dining table | 4×2 | Top of row 0 | Bottom row immediately above floor |
| Dining chair | 2×2 | Top of row 1 | Bottom row immediately above floor |
| Dining booth | 4×3 | Top of row 2 | Bottom row immediately above floor |
| Dining counter | 4×2 | Top of row 0 | Bottom row immediately above floor |

Every declared landing row contains only `one_way` tiles. Other rows contain
only passable tiles. The plain rear tile may fill intentional holes inside a
component. Furniture is never clipped during placement. Chairs have authored
left- and right-facing layouts; their backs face the nearest full-solid wall
along the seat row, with ties facing left. This uses distinct mirrored tile art
because the DMG background map has no per-tile horizontal-flip attribute.

## Placement reservations

- Spawn support, its 3×6 clearance, and a one-tile outer halo remain empty of
  furniture and encounters.
- The exit doorway, approach apron, upper clearance, and one-tile outer halo
  remain empty.
- Standard ports reserve their opening, support surface, standing volume, and
  the room-local approach needed by the validated transition.
- Wide seams reserve the complete opening and the landing/departure space on
  both sides. Vertical domino catch channels reserve the two-column jump-away
  gap and three-row cubby headroom established by playtest.
- Required structural platforms reserve their landing surface and the swept
  space of the accepted incoming and outgoing transitions.
- A furniture footprint may replace only rear tiles, may not overlap another
  component, and must have a continuous full-solid floor directly below its
  complete width.
- Furniture stays inside one room cell unless an authored domino-scale layout
  explicitly owns both matched cells.

The host preview renders reservation overlays separately from terrain and
furniture so accepted placements can be reviewed in the gallery. The accepted
selection rules are now mirrored by the runtime generator.

The first implementation reserves every cell in a critical-route room. This is
an intentional conservative superset of its exact landing and swept-space
requirements. Optional rooms reserve only standard port approaches and wide
seam envelopes; spawn, exit, and ledge-catch roles retain their dedicated
flags. Later tuning may reclaim unused critical-room floor only after the host
can identify exact required transitions without weakening the route proof.

The HTML gallery shows the reservation mask and color-coded furniture
footprints over each thumbnail. Generated TMX files contain a hidden
`Placement Reservations` object layer and a visible `Furniture Placements`
object layer. JSON exports retain the per-cell bit mask, source rectangles,
structural tile snapshot, candidate counts, and selected placements.

| Bit | Reservation |
|---:|---|
| `$01` | Critical-route room |
| `$02` | Standard port approach |
| `$04` | Wide seam envelope |
| `$08` | Spawn envelope |
| `$10` | Exit envelope |
| `$20` | Ledge-catch room |

## Initial placement scope

The floor-furniture pass considers only optional, non-ledge-catch rooms. It finds
every floor-anchored position whose complete footprint is rear tile, outside
all reservations, and directly above a continuous full-solid floor. Every
room with at least one candidate receives one furniture group. Component and
position selection use a local seed/room mix and do not advance the structural
generator's PRNG. The pass places at most one group per room.

Validation compares the furnished map with its structural snapshot, rejects
reserved or unsupported footprints, verifies manifest tile composition, and
requires a placement in every eligible room. The exhaustive host check covers
all 65,536 16-bit seeds. Density and component weights remain tuning data and
are not part of this correctness pass.

The runtime derives its component tables from the same manifest. It evaluates
the equivalent optional-room floor candidates without allocating a second
1,280-byte reservation map, preserves the structural PRNG state, and writes the
selected component tiles after structural conversion and exit placement.
Background placement now runs before furniture in the runtime, using manifest
tables, the same chamber order, mounting lines, paired sconce positions, and
selection salts as the host. Fixed-seed SameBoy parity ROMs compare all 1,280
tiles against the complete decorated host export before entering gameplay;
seeds 0, 1, 77 (paired sconces), `$1234`, and `$FFFF` pass. The normal ROM keeps
its timing-derived seed and does not embed the parity oracle.

The runtime parity target includes wallpaper. A 160-byte footprint bitset keeps
transparent cells inside fixtures unavailable without duplicating the complete
tilemap. Fixed-seed parity covers seeds 0, 1, 77, `$1234`, and `$FFFF` across all
1,280 cells. Loot eggs and movable objects remain later composition passes.

## Initial encounter population

`data/dining-room-mobs.json` guarantees two instances of every mob eligible for
the biome. The current dining-room roster therefore produces two WEINERs and
two BURGERs. Additional weighted slots are independently tunable and currently
disabled; their future type selection will use the accepted frequency weights
of eight and four without weakening the per-type minimum.

WEINER candidates reserve a 2×2 empty structural envelope against a full-solid
floor or ceiling and record the matching crawl direction. BURGER
candidates reserve a 2×1 empty envelope above two supporting cells; both solid
and one-way support are valid. Both types require a full empty tile beside each
side of their body at spawn; WEINERs reach walls through ordinary crawling.
They cannot overlap furniture, standard-port approaches, wide seams, endpoint
envelopes, or ledge-catch reservations. Spawn and exit rooms and the selected
ledge-catch room are excluded entirely. The blanket critical-room flag remains
a furniture restriction; it does not by itself reject an encounter candidate.
This permits ordinary required-route rooms to contain enemies while preserving
their exact transition clearances.

BURGERs are placed before WEINERs because their legal support is scarcer.
Seed-local mixes independently select eligible rooms and anchors without
advancing the structural PRNG. Multiple mobs may occupy one room when their
footprints do not overlap. JSON records candidate counts, the target, and
placements; TMX adds a visible `Mob Spawns` layer; gallery thumbnails
distinguish WEINER and BURGER. Exhaustive host validation guarantees both
per-type minimums across all 65,536 seeds.
