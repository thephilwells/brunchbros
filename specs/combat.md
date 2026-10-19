# Combat

Status: **WEINER horizontal animation, crawl, contact bounds, one-hit pan
defeat, contact damage, knockback, and invulnerability accepted**. Death and
Game Over were implemented for review on 2026-10-14. Surface-relative wall,
ceiling, concave-corner, and convex-corner locomotion is implemented in the
focused fixture. A generic three-frame enemy cloudburst is implemented.
BURGER's accepted idle, leap, wall-bounce, platform-landing, two-hit, and
contact-damage rules run in both its focused fixture and seeded production
levels.

## Calibration fixture

The combat-only map is a compact closed chamber with a solid protrusion rising
from its floor and a one-tile-thick shelf attached to its left wall. Its
continuous inner boundary exercises floor and ceiling crawling, both wall
orientations, inward corners, exposed-edge wraps, and consecutive wraps around
a thin ledge. The Chef starts on the chamber floor near the WEINER so contact
and pan attacks remain testable.

The WEINER's four 16×16 horizontal poses use OBJ tiles 76–91 and advance every eight frames.
The leading face remains planted at floor level while the body bunches behind
it. `WeinerX` and `WeinerY` identify the composite's top-left world pixel.

The surface-crawl fixture uses a 14×14 contact box inset one pixel from every
edge of the 16×16 composite. The orientation-independent box keeps contact and
pan-hit behavior stable while the body rotates. Pose-specific rotated bounds
can be restored after hands-on corner review if the uniform box feels too
generous around the arch crown. The focused
`COMBAT_PLAYTEST` build starts the WEINER at top-left world position `(80, 216)`.
It advances one pixel when the
body extends and another when it pulls flat, for two pixels per 32-frame cycle.
Full-solid probes keep the surface on its right: a blocked forward edge starts
an inward turn, while missing forward support starts an exposed-edge wrap.
Sixteen generated turn poses cover both turn classes in every orientation.
An exposed-edge wrap holds two poses across eight frames, measures the
remaining supported depth from one through 16 pixels, then re-anchors once on
the adjacent face. This keeps one-tile-thick ledges from leaving the crawler
detached between two consecutive wraps.
The fixture sheet therefore contains 24 poses and 96 OBJ tiles. It does not
follow one-way platforms. Its four entries are composed in shadow OAM and
transferred with the complete sprite frame.

The BURGER fixture is a separate chamber with full-solid side walls and divider
plus two one-way shelves. Its 16×8 composite uses two OAM entries and four
two-tile poses: idle, wind-up, shared twitch/airborne, and landing. It rests for
120 frames, shows its airborne pose on every fourth eight-frame idle beat,
winds up for 20 frames, then launches toward the Chef at one horizontal pixel
per frame with an initial vertical velocity of −8. Only full-solid side contact
reverses its airborne horizontal direction. Downward motion lands on both solid
and one-way surfaces; upward motion ignores one-way surfaces. The first pan hit
briefly flickers the BURGER, and the second starts the shared cloudburst.

Production levels retain the accepted two-through-four encounter budget.
Each selected room independently chooses WEINER or BURGER with frequency
weights eight and four. Both types share a conservative 2×2 reserved envelope;
BURGER occupies its lower row. The four-enemy total cap lets every actor reserve
four shadow-OAM entries, including its cloudburst.

## Accepted initial rules

- A WEINER deals one half-heart of contact damage and dies to one pan hit.
- One half-heart is one damage unit and produces four pixels of horizontal
  knockback; one heart produces eight pixels. Calibration may change this.
- Knockback travels away from the damage source at one pixel per frame and
  respects full-solid terrain. The crouch frame serves as the initial hit pose;
  movement and attacking are suppressed only during knockback.
- Damage grants 60 frames of invulnerability. The Chef flickers every four
  frames, regaining control after knockback ends.
- Enemies are not solid terrain. Remaining overlapped with an enemy cannot deal
  damage again until invulnerability ends.
- Pan damage resolves before contact damage. Killing an enemy on the contact
  frame prevents that enemy from damaging the Chef.
- A lethal hit immediately disables enemy movement, contact damage, and further
  pan hits. It starts the destruction cloud without a pre-destruction pause.
- Each enemy can take damage at most once per swing. Ordinary damage cancels an
  active attack or ledge grab.
- At zero health, gameplay and the camera freeze. The Chef uses the wide-eyed
  frame at sheet cell `[0, 4]`, source pixel `(64, 0)`, in `gfx/ChefA1.png`,
  launches upward, ignores collision, then falls below the viewport. The
  resulting Game Over screen waits for Start and returns to the title screen
  for a new run.

## Pan hit bands

The wind-up checks the eight-pixel band directly above the Chef's 12×16 terrain
box. The strike checks a full-height eight-pixel band immediately in front of
that box. Recovery checks the lower eight pixels of the same forward band.
These world-space bands overlap the WEINER's pose-specific contact bounds; they
do not use center distance. A per-enemy swing latch prevents repeat hits. The
fixture WEINER has one health. A strike immediately replaces it with a
three-frame 16×16 cloudburst for 12 frames, reusing its four shadow-OAM entries,
then clears those entries.

## Chef damage response

An active WEINER overlapping the Chef's 12×16 terrain box removes one
half-heart. Pan damage resolves first, so a WEINER defeated by the current
swing cannot deal contact damage on that frame. Damage cancels an attack or
ledge grab and selects the crouch frame as the initial hit pose.

The next four frames move the Chef one pixel per frame away from the WEINER.
Each step uses the standing hitbox's three wall probes and is shortened if
full-solid terrain blocks it. Player movement, jumping, and attack startup are
suppressed during those four frames; gravity continues normally.

The hit frame begins a 60-frame invulnerability window. While it is nonzero,
further overlap cannot deal damage. The Chef and pan alternate between visible
and hidden in four-frame blocks while the HUD remains visible.

## Death and Game Over

Fatal damage bypasses ordinary knockback and enters a dedicated death state.
The camera, WEINER, input, collision, and ordinary animation stop. The Chef uses
the wide-eyed frame at sheet cell `[0, 4]`, source pixel `(64, 0)`, in
`gfx/ChefA1.png` and holds it for 60 frames. The Chef then launches at −6 pixels
per frame, accelerates downward by one pixel per frame, and caps at eight pixels
per frame. Screen-space 16-bit Y allows the sprite to travel above and below
the viewport without wrapping at the world's 8-bit vertical boundary.

Once the Chef falls below the viewport, the level is replaced by a `GAME OVER`
screen. Start returns to the title screen; starting there creates a new seed and
restores all three hearts. The death frame occupies OBJ indices 172–175.
