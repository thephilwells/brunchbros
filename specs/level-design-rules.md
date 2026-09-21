# Level design rules

Status: **authoritative baseline**, expanded as traversal measurements are
accepted in SameBoy.

## Coordinate grid

- Structural geometry uses 8×8-pixel cells.
- The standing terrain hitbox is 12×16 pixels. Crouching does not change it.
- Passages used by the required route are at least two tiles wide and two
  tiles high.

## Horizontal gaps

- A same-height gap on the required route may contain at most three empty tile
  columns: 24 pixels between platform edges.
- Three tiles is a hard maximum, not the default. The Chef reaches it with
  only two pixels of landing overlap after a 15-pixel same-height jump.
- A three-tile gap must end at an exposed upper corner of a full-solid tile so
  a short landing can recover into ledge catch.
- A one-way surface cannot be the recovery edge for a three-tile required-route
  gap because one-way cells are not ledge-catchable.
- The generator must never require a gap wider than three tiles without a
  later traversal ability and an explicit capability-gated route rule.

## Current measured bounds

- Standing jump: 28-pixel feet rise.
- Highest tested tile-aligned ledge top from a standing surface: 32 pixels
  above that surface. This is a boundary-case catch, not ordinary clearance.
- Same-height held-direction jump: 15 pixels of center travel before landing.

The dining-room fixture contains the accepted boundary tests: a 32-pixel
upward ledge catch and a same-height three-tile gap. These remain regression
geometry while procedural generation is developed.
