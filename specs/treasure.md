# Treasure

The first treasure container is a stationary 16×16 egg. Its uncracked and
cracked poses use four OBJ tiles each. A dropped heart reuses the HUD full-heart
tile, while the dropped key uses one dedicated OBJ tile.

The focused fixture contains three visually identical uncracked eggs. From
left to right they contain a heart, nothing, and a key. The fixture starts Chef
at two hearts so the dropped heart's healing is visible.

Implemented fixture behavior:

- The first pan hit changes an uncracked egg to its cracked pose.
- The second pan hit starts the generic cloudburst immediately.
- A heart-bearing egg leaves one heart pickup; an empty egg leaves nothing.
- A key-bearing egg leaves one key pickup.
- Walking over a heart restores one whole heart, capped at three hearts.
- A heart remains on the ground while Chef is at full health.
- Walking over the key removes its world pickup and sets the level-local key
  inventory flag.
- The fixture exit ignores Down until the key is collected. Starting the exit
  descent consumes the key.

Host generation behavior:

- Generated levels place two to four eggs. Candidate bodies occupy two empty
  tiles by two empty tiles above full-solid or one-way support and cannot
  overlap furniture, mobs, protected transitions, spawn, exit, or ledge-catch
  rooms.
- Selection prefers rooms farthest from the critical route, then unused rooms,
  with safe required-route rooms available when optional rooms cannot satisfy
  the population target.
- Generated eggs roll contents independently at 50 percent. If every result is
  empty, one deterministic result is promoted so every level contains at least
  one treasure-bearing egg.
- JSON records candidate counts, route distances, the population target, and
  contents. TMX and gallery overlays expose the same placements for review.
- Runtime placement mirrors the host selection and contents rules. Fixed-seed
  parity covers seeds 0, 1, 77, `$1234`, and `$FFFF`.
- Runtime rendering culls offscreen eggs and admits only complete four-entry
  composites that fit in the OAM capacity remaining after Chef, HUD, and mobs.

## Exit key requirement

Each generated level has exactly one key-bearing egg. The selected egg remains
visually identical to every other egg until its second pan hit completes the
cloudburst and leaves a key pickup. The key-bearing egg is selected
deterministically and is exposed in JSON, TMX, gallery overlays, and fixed-seed
runtime parity.

The remaining eggs retain the independent 50-percent heart-or-empty roll. The
existing guarantee of at least one heart-bearing egg applies in addition to the
key egg, so every level contains exactly one key and at least one heart pickup.

Walking over the key collects it, removes the world pickup, and sets the
level-local key inventory flag. The flag starts clear on a new run and after
every level load. A successful exit consumes the key before the next level is
generated. Death also clears it.
