# Treasure

The first treasure container is a stationary 16×16 egg. Its uncracked and
cracked poses use four OBJ tiles each. A dropped heart reuses the HUD full-heart
tile.

The focused fixture contains two visually identical uncracked eggs. The left
egg is heart-bearing and the right egg is empty. The fixture starts Chef at two
hearts so the dropped heart's healing is visible.

Implemented fixture behavior:

- The first pan hit changes an uncracked egg to its cracked pose.
- The second pan hit starts the generic cloudburst immediately.
- A heart-bearing egg leaves one heart pickup; an empty egg leaves nothing.
- Walking over a heart restores one whole heart, capped at three hearts.
- A heart remains on the ground while Chef is at full health.

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
- Runtime placement and fixed-seed parity remain the next implementation step.
