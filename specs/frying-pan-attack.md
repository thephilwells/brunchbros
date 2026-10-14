# Frying-pan attack

Status: **animation prototype implemented and accepted** as of 2026-10-12.
World-space hit detection against the focused WEINER fixture was implemented
for review on 2026-10-14. Sound and impact effects are not implemented.

## Input and state

- A fresh B press starts one attack. Holding B does not repeat it.
- An attack lasts 18 frames: six overhead-opening, six forward-slash, and six
  waist-recovery frames.
- The Chef can begin and continue an attack while grounded or airborne.
  Existing movement and gravity continue throughout the animation.
- Down prevents a new attack so crouch, exit descent, and Down+A retain their
  established meanings. Ledge catch and exit descent cancel an active attack.
- Facing is sampled continuously. The same authored right-facing art is
  horizontally mirrored when facing left.

## Sprite contract

Each phase uses one 16×16 Chef body frame and one separate 16×16 pan frame.
Each composite occupies four 8×8 OBJ tiles and four OAM entries. An attacking
Chef therefore uses eight OAM entries, below the DMG limit of ten sprites on
one scanline when no other actor overlaps him.

The body remains anchored to the existing player sprite and terrain hitbox.
The pan composite begins directly over the Chef and overlaps the one-tile-above
attack band. Its handle descends behind the opaque hat and body to the Chef's
hand instead of visibly pivoting at his ear. It moves down and toward the
facing side for the forward slash, then keeps the same horizontal orientation
and translates four pixels down so its handle finishes at hand height. The
Chef's rear arm remains hidden behind his body throughout the swing; only the
pan communicates its arc. Neither the pan nor its hit bands extend more than
one tile beyond the Chef's visual top or facing edge. OBJ color 0 supplies
transparent space; source PNGs remain opaque four-shade images converted by
`rgbgfx -c dmg=E4`.

The pan owns shadow-OAM slots 4–7. An inactive attack sets their Y bytes to
zero; an active attack composes its current pose before VBlank. The complete
shadow buffer transfers atomically with the rest of the sprite frame.

Damage checks follow the swing while retaining the one-tile limit. The
opening can hit an enemy overlapping the 8-pixel band immediately above the
Chef's terrain hitbox; the slash and waist finish use the corresponding band
immediately in front. The attack cannot bridge a larger empty gap.
Enemy-center distance is not the test because enemy widths may differ.

Tile ownership:

| OBJ indices | Frames |
|---:|---|
| 49–52 | Chef wind-up |
| 53–56 | Chef strike |
| 57–60 | Chef recovery |
| 61–64 | Pan wind-up |
| 65–68 | Pan strike |
| 69–72 | Pan recovery |

`tools/generate-chef-attack.mjs` is the reproducible pixel source for all six
PNGs. The focused `brunchbros-attack-animation.gb` build skips the title and
uses the fixed seed-0 dining room for manual animation review.
