# Player abilities and generation prerequisites

Status: **exploratory implementation plan**. The desired abilities are
authoritative in `docs/PROJECT.md`; exact mechanics below remain open until
their focused specifications and playtests.

## Accepted feature goals

- Down normally crouches with the existing landing/squat pose.
- Down at an exit takes priority over crouching and begins a diagonal
  stair-descent presentation.
- Down+A while supported by a one-way surface drops the Chef through it. It
  has no effect on full-solid structural tiles. This is not yet implemented.
- Holding Down or Up long enough shifts the camera in that direction;
  releasing returns it to the ordinary follow offset.
- Up needs a new upward-looking Chef pose.
- The Chef can catch an exposed upper corner of a full-solid structural cell
  while descending and holding toward it. The catch persists after direction
  is released; A jumps upward and away, and Down drops. He cannot catch
  one-way surfaces, cling along arbitrary wall faces, or climb vertically.
- Deep Freezer floors have reduced horizontal stopping after landing and
  after Left/Right is released.
- Loot comes from large breakable eggs that can be lifted and thrown. Carry,
  lift, and throw poses are required.
- The Chef attacks with a large frying pan. Attack poses are required.

## What must precede generated-room reachability

1. The implemented 12×16 terrain hitbox has passed SameBoy edge-overhang
   review. The 16×16 visual sprite extends two pixels beyond it on each side,
   while full standing height is preserved. Passage widths, edge support, and
   wall-contact coordinates can use it.
2. Upper-corner ledge catch/jump/drop behavior and the revised hanging pose
   have passed SameBoy review.
3. Verify grounded crouching in SameBoy. Its implemented 12×16 terrain box
   does not create crouch-only tunnels or change structural reachability. A
   shorter future combat/hazard hurtbox remains an option for those systems.
4. Measure traversal from the implemented code rather than relying only on
   equations: maximum standing jump height, running jump span, one-way
   platform behavior, ledge-catch recovery distance, and safe landing widths.

## Measured traversal baseline

- With the current `-8` jump impulse and gravity applied before vertical
  movement, the rising displacement sequence is 7, 6, 5, 4, 3, 2, and 1
  pixels: a 28-pixel feet rise.
- From the serving-window strip at world Y=192, the Chef's feet reach Y=164
  and the top of the 16-pixel sprite reaches Y=148. SameBoy visual review
  agrees with this apex.
- The ledge grab line is eight pixels above the feet, reaching Y=156 at the
  apex. Because catches occur while descending at tile-aligned boundaries,
  world Y=160 is the highest 8-pixel-grid ledge top reachable from that strip.
- The dining fixture's upper-left platform now uses that exact Y=160 limit as
  an opposite-side “just made it” catch test. Treat it as a boundary case,
  not the default procedural-generation clearance, until playtesting supplies
  a forgiving margin.
- Holding a horizontal direction moves the Chef one pixel on each of the 15
  frames through a same-height jump, for 15 pixels of center travel. A launch
  may begin with the center five pixels beyond the departure edge, and landing
  may use the hitbox's five-pixel leading probe, making 25 pixels the
  theoretical gap limit. The largest tile-aligned candidate is therefore a
  three-tile (24-pixel) gap, with only two pixels of overlap on landing.
- The dining fixture places two row-20 platforms around a three-tile gap for
  SameBoy validation. Review confirmed that the Chef just clears it and that
  ledge catch provides useful recovery. Three tiles is now the hard
  same-height required-route maximum in `specs/level-design-rules.md`, not the
  default gap width.
- A one-tile platform is 8 pixels wide and cannot fully contain the 12-pixel
  terrain hitbox, so it is not a safe required-route landing candidate. Two
  tiles provide 16 pixels of support and four pixels of total fit tolerance.
  The fixture now includes a two-tile one-way target at world Y=136, 24 pixels
  above the wide row-20 platform. SameBoy review accepted two tiles as the
  required-route minimum and confirmed that three tiles is the ordinary upward
  transition limit.
- Required upward transitions now cap at three tiles for an ordinary landing
  and four tiles for an exposed full-solid ledge catch. Required downward
  transitions cap at eight tiles so the full first tile row of the landing
  remains visible at the normal camera offset. These authoritative limits live
  in `specs/level-design-rules.md`.

## What can follow the first generator

- Directional camera look changes visibility, not reachability. It is useful
  for reviewing vertical rooms but does not block structural generation.
- Down+A drop-through changes navigation through one-way furniture but does
  not change the guaranteed structural route; it may follow the first
  generator.
- The exit descent animation and biome-state transition can follow once two
  biome maps exist. Generated rooms only need to reserve a reachable 2×3
  doorway footprint and safe interaction space.
- Freezer sliding belongs to the freezer biome profile. Its later traversal
  measurements may tighten freezer-specific room rules without changing the
  shared generator architecture.
- Eggs, carrying/throwing, loot, and frying-pan combat affect object and
  encounter placement rather than the initial structural route.

## Generation direction after the traversal baseline

- Use one deterministic, seeded generator with biome parameter sets rather
  than four unrelated generators.
- Guarantee a main route from spawn to exit using only the baseline abilities
  available at that point in the run.
- Treat ledge catch as a baseline ability. The main route may contain
  intentional “just made it” gaps where the Chef cannot land upright but can
  catch the destination's exposed upper corner. Such gaps need measured
  tolerance and may not depend on frame-perfect or pixel-perfect input.
- Label optional branches with capability requirements. A required route may
  never depend on an ability the player might not have acquired.
- Keep boss arenas and other authored set pieces as curated modules selected
  by the generator, not layouts synthesized under normal room rules.
- Separate structural layout, reachability validation, biome dressing,
  furniture/object placement, and encounter placement so later systems can
  change without invalidating the core route algorithm.
- Decide deliberately whether the first generator fills the current 32×32
  hardware tile map or introduces tile-map streaming for larger levels. The
  current camera cannot address a larger world without streaming map data as
  the view moves.

The authoritative generation envelope is now recorded in
`specs/level-design-rules.md`. Ordinary route edges stay comfortably inside
the measured traversal limits; isolated boundary cases may use one hard limit
when surrounded by ordinary rest geometry. Spawn and exit have protected
structural and encounter-free envelopes that later placement passes cannot
occupy.

## Focused decisions for the next step

- Whether crouch later shortens the combat/hazard hurtbox.
- The first generator's macro topology and critical-route representation.
- Conversion from eight-bit to 16-bit horizontal world coordinates.
- A bidirectional horizontal VRAM column-streaming test before procedural room
  assembly depends on it.
