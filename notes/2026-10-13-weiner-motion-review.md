# WEINER motion review

<img src="../gfx/weiner_motion_review.png" width="512" alt="Twelve WEINER motion poses arranged in three rows">

The source sheet is 64×96 pixels with twenty-four contiguous 16×16 review cells.
It is not converted or loaded by the game.

| Row | Poses from left to right |
|---|---|
| 1 | flat extension, rear bunch, peak arch, forward extension; moving right |
| 2 | separately drawn vertical-down equivalents of row 1 |
| 3–4 | two-frame inward turns in all four starting directions |
| 5–6 | two-frame exposed-edge wraps in all four starting directions |

The face remains a small mark at the leading endpoint while the body bunches
behind it. Horizontal and vertical flips can supply the other travel directions,
but Game Boy hardware cannot rotate a sprite 90 degrees, so accepted vertical
poses will require their own tile data.

The revised horizontal cycle, with its leading face planted on the floor, was
accepted on 2026-10-13. Vertical and corner poses are implemented in the
closed-loop combat fixture for hands-on review.
