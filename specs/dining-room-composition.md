# Dining-room composition

Status: **furniture manifest and conservative host-side placement reservations
implemented; seeded furniture placement pending**.

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
4. Place passable rear-wall details.
5. Place floor-anchored furniture outside reservations.
6. Revalidate the finished tile map. Encounter and loot placement remain later
   passes and inherit the same reservations.

Furniture is optional traversal. Removing every furniture tile must leave the
structural route valid. Furniture may create shortcuts, extra landing choices,
or Down+A opportunities, but it cannot be the only connection between required
surfaces.

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
component. Furniture is never mirrored or clipped during placement; a future
authored orientation is a separate manifest component.

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

The host preview must render reservation overlays separately from terrain and
furniture so rejected placements can be reviewed in the gallery. Runtime
placement follows only after the host output is accepted across a multi-seed
gallery.

The first implementation reserves every cell in a critical-route room. This is
an intentional conservative superset of its exact landing and swept-space
requirements. Optional rooms reserve only standard port approaches and wide
seam envelopes; spawn, exit, and ledge-catch roles retain their dedicated
flags. Later tuning may reclaim unused critical-room floor only after the host
can identify exact required transitions without weakening the route proof.

The HTML gallery shows the reservation mask over each thumbnail. Generated TMX
files contain a hidden `Placement Reservations` object layer whose rectangles
can be toggled in Tiled. JSON exports retain both the per-cell bit mask and the
source rectangles.

| Bit | Reservation |
|---:|---|
| `$01` | Critical-route room |
| `$02` | Standard port approach |
| `$04` | Wide seam envelope |
| `$08` | Spawn envelope |
| `$10` | Exit envelope |
| `$20` | Ledge-catch room |

## Initial placement scope

The first host pass places at most one furniture group in an eligible room and
does not place furniture in ledge-catch rooms. Selection is deterministic from
the level seed. Density and component weights remain tuning data and are not
part of the first correctness pass.

Wall fixtures, rear motifs, encounters, loot eggs, and movable objects are out
of scope until floor-furniture reservations and gallery output are accepted.
