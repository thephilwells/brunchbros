# Combat

Status: **WEINER horizontal animation and rightward crawl accepted**. The
pose-specific contact bounds and one-hit pan defeat were implemented for review
on 2026-10-14. Contact damage, knockback, invulnerability, death, and Game Over
are not implemented yet.

## Calibration fixture

The first enemy is a WEINER on the seed-0 spawn-room floor. Its
four 16×16 horizontal poses use OBJ tiles 76–91 and advance every eight frames.
The leading face remains planted at floor level while the body bunches behind
it. Its world position uses the same convention as the Chef: `WeinerX` is its
horizontal center and `WeinerY` is its feet line.

The contact box is 14 pixels wide:

- left: `WeinerX - 7`
- right: `WeinerX + 6`
- bottom: `WeinerY - 1`

Its top follows the active animation pose:

| Pose | Top | Height |
|---|---:|---:|
| flat | `WeinerY - 7` | 7 pixels |
| pull | `WeinerY - 10` | 10 pixels |
| arch | `WeinerY - 12` | 12 pixels |
| extend | `WeinerY - 10` | 10 pixels |

The horizontal inset keeps the transparent edge columns harmless. The changing
height follows the body mass without making the narrow crown of the tallest
arch damaging. The focused
`COMBAT_PLAYTEST` build starts the WEINER at world position `(280, 56)`, four
pixels beyond the Chef's initial visual edge. It advances one pixel when the
body extends and another when it pulls flat, for two pixels per 32-frame cycle.
It stops before full-solid walls and unsupported floor. Wall turns, edge turns,
and contact response are not implemented yet. Its four entries
are composed in shadow OAM and transferred with the complete sprite frame.

## Accepted initial rules

- A WEINER deals one half-heart of contact damage and dies to one pan hit.
- One half-heart is one damage unit and produces four pixels of horizontal
  knockback; one heart produces eight pixels. Calibration may change this.
- Knockback travels away from the damage source at one pixel per frame and
  respects full-solid terrain. The crouch frame serves as the initial hit pose;
  movement and attacking are suppressed only during knockback.
- Damage grants 60 frames of invulnerability. The Chef flickers every four
  frames, regaining control after knockback ends.
- Enemies are not solid terrain. Remaining overlapped cannot deal damage again
  until invulnerability ends.
- Pan damage resolves before contact damage. Killing an enemy on the contact
  frame prevents that enemy from damaging the Chef.
- Each enemy can take damage at most once per swing. Ordinary damage cancels an
  active attack or ledge grab.
- At zero health, gameplay and the camera freeze. The Chef uses frame `[0, 4]`
  from `gfx/ChefA1.png`, launches upward, ignores collision, then falls below
  the viewport. The resulting Game Over screen waits for Start and returns to
  the title screen for a new run.

## Pan hit bands

The wind-up checks the eight-pixel band directly above the Chef's 12×16 terrain
box. The strike checks a full-height eight-pixel band immediately in front of
that box. Recovery checks the lower eight pixels of the same forward band.
These world-space bands overlap the WEINER's pose-specific contact bounds; they
do not use center distance. A per-enemy swing latch prevents repeat hits. The
fixture WEINER has one health, stops updating when struck, and clears its four
shadow-OAM entries on the following composition pass.
