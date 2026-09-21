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

## Platform widths

- A required-route landing surface is at least two tiles, or 16 pixels, wide.
- Two tiles leave four pixels of total fit tolerance around the 12-pixel
  terrain hitbox and are confirmed easy to land on from either direction.
- A one-tile platform cannot contain the full terrain hitbox. It may appear as
  an optional precision foothold but never as a mandatory landing or spawn.

## Vertical transitions

- An ordinary upward jump may require landing on a surface at most three tiles,
  or 24 pixels, above the departure surface.
- A catch-assisted upward transition may reach an exposed full-solid ledge at
  most four tiles, or 32 pixels, above the departure surface. Four tiles is a
  hard boundary case and requires empty space above and beside the catch edge.
- One-way surfaces cannot terminate a four-tile upward transition because they
  cannot be ledge-caught.
- A required downward transition may drop at most eight tiles, or 64 pixels.
  At the normal camera offset, the complete first tile row of that landing
  remains visible at the bottom of the 144-pixel viewport before the drop.
- Downward landings follow the same two-tile minimum width. Deeper required
  drops remain prohibited until look-down camera behavior is implemented and
  reviewed.

## Current measured bounds

- Standing jump: 28-pixel feet rise.
- Highest tested tile-aligned ledge top from a standing surface: 32 pixels
  above that surface. This is a boundary-case catch, not ordinary clearance.
- Same-height held-direction jump: 15 pixels of center travel before landing.

The dining-room fixture contains the accepted boundary tests: a 32-pixel
upward ledge catch, a 24-pixel ordinary jump onto a two-tile platform, and a
same-height three-tile gap. These remain regression geometry while procedural
generation is developed.
