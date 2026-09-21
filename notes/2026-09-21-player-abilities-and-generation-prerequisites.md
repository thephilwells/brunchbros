# Player abilities and generation prerequisites

Status: **exploratory implementation plan**. The desired abilities are
authoritative in `docs/PROJECT.md`; exact mechanics below remain open until
their focused specifications and playtests.

## Accepted feature goals

- Down normally crouches with the existing landing/squat pose.
- Down at an exit takes priority over crouching and begins a diagonal
  stair-descent presentation.
- Holding Down or Up long enough shifts the camera in that direction;
  releasing returns it to the ordinary follow offset.
- Up needs a new upward-looking Chef pose.
- The Chef can catch an exposed upper corner of a full-solid structural cell
  while airborne, jump from the hanging position, or drop. He cannot cling
  along arbitrary wall faces or climb vertically.
- Deep Freezer floors have reduced horizontal stopping after landing and
  after Left/Right is released.
- Loot comes from large breakable eggs that can be lifted and thrown. Carry,
  lift, and throw poses are required.
- The Chef attacks with a large frying pan. Attack poses are required.

## What must precede generated-room reachability

1. Fix the Chef's terrain collision box. The current 16×16 visual bounds are
   also the collision bounds, while the roadmap already calls for a narrower
   box. Passage widths, edge support, and wall-contact coordinates must not
   be validated against a temporary hitbox.
2. Specify and implement upper-corner ledge catch/jump/drop. It materially
   changes the reachable ledge height and horizontal gap envelope.
3. Decide crouch collision semantics. Recommended initial rule: crouching
   lowers the future combat/hazard hurtbox but does not create a shorter
   terrain collision box or crouch-only tunnels. That preserves a two-tile
   minimum passage height and keeps crouch out of structural reachability.
4. Measure traversal from the implemented code rather than relying only on
   equations: maximum standing jump height, running jump span, one-way
   platform behavior, ledge-catch recovery distance, and safe landing widths.

## What can follow the first generator

- Directional camera look changes visibility, not reachability. It is useful
  for reviewing vertical rooms but does not block structural generation.
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

## Focused decisions for the next step

- Exact standing terrain hitbox dimensions and probe offsets.
- Whether ledge catch is automatic in its catch window or requires holding
  toward the ledge; how Down/release drops; and the ledge-jump launch vector.
- Whether crouch affects only animation now or also the later hazard hurtbox.
- The minimum safe platform width and clearance around spawn and exit.
- Initial world dimensions and whether tile-map streaming belongs in the
  first generation implementation or a following expansion.
