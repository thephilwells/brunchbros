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

- A landing-based upward jump may require landing on a surface at most three
  tiles, or 24 pixels, above the departure surface.
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

## Ordinary and boundary-case transitions

The required route uses ordinary transitions by default. Boundary cases are
intentional tests near one accepted traversal limit, not additional random
variation.

| Property | Ordinary transition | Boundary case |
|---|---:|---:|
| Destination width | At least 3 tiles / 24 px | 2 tiles / 16 px |
| Same-height gap | At most 2 tiles / 16 px | 3 tiles / 24 px |
| Upward landing | At most 2 tiles / 16 px | 3 tiles / 24 px |
| Upward ledge catch | Not required | 4 tiles / 32 px |
| Downward drop | At most 4 tiles / 32 px | 5–8 tiles / 40–64 px |

- A required-route transition is a boundary case when any property enters the
  boundary column.
- A boundary transition starts from a standing surface at least three tiles
  wide. Its departure, travel space, and landing remain free of hazards,
  enemies, and placed objects.
- Two boundary transitions cannot be consecutive. At least one ordinary route
  transition separates them.
- A two-tile destination may be reached with ordinary gap, rise, or drop values
  or the tested three-tile upward landing. It cannot terminate a three-tile
  gap, a four-tile ledge catch, or a downward drop greater than four tiles.
- Three-tile gaps and four-tile rises require an exposed full-solid catch edge.
  The four-tile rise is successful only by ledge catch; the three-tile gap may
  use catch as recovery.
- A boundary drop must expose its complete landing surface before the Chef
  leaves the departure edge. Until look-down camera behavior is accepted, the
  eight-tile visibility cap is absolute.
- Optional branches may use the same baseline limits. Geometry outside them is
  allowed only when the branch is explicitly labeled with its required future
  ability or resource; it cannot reconnect as the sole required route.

## Spawn clearance

- The Chef spawns standing, centered on a full-solid platform at least three
  tiles wide. A one-way surface cannot support a spawn.
- The three columns centered on the spawn remain empty for six tile rows above
  the floor. This accommodates the 12×16 terrain hitbox and an unobstructed
  standing jump.
- The spawn platform and its clearance volume contain no hazards, enemies,
  furniture, movable objects, or exit footprint.
- The first required-route transition out of the spawn area is ordinary. The
  player is never required to begin with a boundary jump, catch, or long drop.

## Exit clearance

- The shared exit occupies a 2×3-tile empty, passable footprint. Its two bottom
  cells meet a full-solid floor; it cannot sit on a one-way surface.
- At least one side of the doorway has a two-tile-wide flat approach apron,
  producing a continuous four-tile floor across the apron and doorway. The
  three rows above that entire span remain free of structural collision.
- The doorway and approach apron contain no hazards, enemies, furniture, or
  movable objects. The object-placement pass also reserves a one-tile halo
  around their outer sides and top.
- The final required-route transition lands on the approach apron using
  ordinary tolerances. Reaching or entering the exit cannot depend on a
  boundary jump, ledge catch, long drop, later ability, or consumable resource.
- Exit activation remains a separate runtime interaction: overlap the doorway
  while grounded at its threshold and press Down. Generation validates only
  the structural footprint and safe approach.

## Required-route enforcement

- Generate a directed critical route from spawn to exit, then validate every
  transition against this file before dressing or encounter placement.
- An invalid required-route transition is rejected and regenerated. Map-edge
  handling may choose another in-bounds transition but cannot weaken a
  clearance or traversal limit.
- Structural layout, reachability validation, biome dressing, object
  placement, and encounter placement remain separate passes. Later passes may
  not occupy reserved route, spawn, or exit clearance cells.
- Macro topology and room-grid dimensions remain separate decisions. These
  guarantees apply whether the first generator uses room templates, a random
  walk, or another seeded layout strategy.

## Current measured bounds

- Standing jump: 28-pixel feet rise.
- Highest tested tile-aligned ledge top from a standing surface: 32 pixels
  above that surface. This is a boundary-case catch, not ordinary clearance.
- Same-height held-direction jump: 15 pixels of center travel before landing.

The dining-room fixture contains the accepted boundary tests: a 32-pixel
upward ledge catch, a 24-pixel ordinary jump onto a two-tile platform, and a
same-height three-tile gap. These remain regression geometry while procedural
generation is developed.
