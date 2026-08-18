# Roadmap — Brunch Bros

Milestones, roughly in order. This sequence is expected to evolve as we
learn — it's a guide, not a locked contract. Completed items are checked;
everything else is upcoming.

## Milestones

- [x] ROM builds
- [x] ROM boots
- [x] Visible background
- [x] Input
- [x] Movable object
- [x] Player sprite
- [x] Movement
- [x] Player animation
- [ ] Collision
- [ ] Jumping
- [ ] Camera / room traversal
- [ ] Tileset backgrounds
- [ ] Hazards
- [ ] Enemies
- [ ] HUD
- [ ] Level generation
- [ ] Gameplay systems
- [ ] Inventory
- [ ] Additional areas
- [ ] Audio
- [ ] Title / menu / game-over flow
- [ ] Polish
- [ ] Complete game

## Milestone additions (2026-08-18)

Expanded from the original list — the back half was too coarse, leaving
several substantial, technically-distinct pieces buried inside vague
buckets. None of these are explained in detail yet; each gets covered when
we actually start on it.

- **Player animation** — right after Movement, since it only depends on
  movement existing, not on physics. General animation-timer mechanism,
  proven with the walk cycle (`gfx/ChefA1.png`, already on hand). Jump-
  specific animation frames get folded into the Jumping milestone itself
  rather than needing their own line.
- **Tileset backgrounds** — right before Level generation. Rolls up into
  "Visible background" only in that the tile/tilemap *mechanism* is already
  proven with the checkerboard; real diner art (via Tiled) is separate,
  substantial work, and its payoff is much bigger once Level generation
  actually needs tile variety to assemble rooms from.
- **HUD** — after Hazards/Enemies, once there's an actual value (health)
  worth displaying. Needs the **Window layer** (`LCDC` bit 5, `WY`/`WX`) —
  hardware we haven't touched at all yet.
- **Inventory** — right after Gameplay systems, where "items or
  interactable objects" (see `docs/PROJECT.md`) already conceptually lives,
  but substantial enough to name explicitly rather than leave buried.
- **Title / menu / game-over flow** — closes a real gap: `docs/PROJECT.md`
  names this in the original vision, but it had no roadmap line at all.
  Placed late, near Polish, since it's most meaningful once there's an
  actual win/lose condition to bookend. Open question, not yet decided:
  title/game-over screens usually imply *some* game-state machine
  (title → playing → game-over), and the code is currently one linear
  `MainLoop` — whether to bake in minimal state-switching early or retrofit
  it once Hazards/Enemies give us a real "you died" condition is worth
  deciding deliberately when we get closer, not assumed now.

See `notes/2026-08-18-spelunky-design-principles.md` for design-research
notes (not yet authoritative) that informed some of this shape, particularly
around Hazards/Enemies/Additional areas content design later.

## Immediate next milestone

**Collision** — stop the player from walking through solid tiles. Not yet
explained in detail — covered when we start on it.

## Completed

- **2026-08-18 — Player animation.** Full idle/walk animation, built in four
  stages: bulk-loaded all 8 frames (`gfx/ChefA1.png`, cropped to individual
  frames) into VRAM in one combined `INCBIN`+nested-loop pass; added a
  WRAM frame-timer to alternate the 2-frame idle "bop" (decoupling
  animation speed from the 60fps loop); switched to the 6-frame walk cycle
  while any direction is held, with explicit transition-snapping between
  the idle/walk tile ranges; added horizontal flip (`OAM` attribute bit 5)
  for left-facing movement, which required swapping *which* quadrant each
  tile renders in, not just setting the flip bit. `UpdateSprites` now reads
  a dynamic `PlayerTileBase` instead of hardcoded literals. Hit a real `jr`
  range-limit error as `MainLoop` grew (fixed with `jp`), and a missed
  `ld a, 1` that left `PlayerTileBase` briefly wrong at boot (self-masked
  by the transition logic, but fixed properly anyway). See
  `docs/LEARNING.md` for the new concepts.
- **2026-08-18 — Player sprite, Movement.** Replaced the reused checkerboard
  placeholder with a real 16×16 chef, composed of 4 hardware sprites (8×8
  each, since the Game Boy has no native 16×16 sprite mode) driven by one
  WRAM-backed authoritative position (`PlayerY`/`PlayerX`) and a shared
  `UpdateSprites` subroutine (first use of `CALL`/`RET` and the stack).
  Built a real asset pipeline: Aseprite → grayscale/no-alpha PNG →
  `rgbgfx -c dmg=E4` → `INCBIN`, replacing hand-typed tile bytes. D-pad
  movement is direct 1px/frame WRAM increment/decrement — checking all 4
  direction bits independently, so diagonals work as a side effect of the
  design, not extra code. **This is not final movement or a final look**:
  no animation yet (a walk-cycle spritesheet, `gfx/ChefA1.png`, is already
  on hand for later), and no platformer physics — jumping, falling/gravity,
  climbing, ducking, punching are all still ahead, most immediately under
  the "Jumping" milestone below. See `docs/LEARNING.md` for the new
  concepts (WRAM, `CALL`/`RET`, the DMG-transparency-vs-alpha gotcha, the
  multi-sprite composite pattern).
- **2026-08-17 — Movable object.** Cleared all 40 OAM slots (`$FE00`–`$FE9F`)
  before writing one sprite's 4 bytes, to avoid stray garbage sprites from
  undefined power-on OAM contents. Set `LCDC` bit 1 (object display) and
  gave the sprite its own palette (`OBP0`, deliberately different from
  `BGP`, since sprites don't use the background palette — a fact made very
  visible by two back-to-back rendering surprises, see `docs/LEARNING.md`).
  Read the D-pad each frame and adjusted the sprite's OAM `Y`/`X` bytes
  directly (no separate WRAM copy needed yet). Hit two real bugs: an `h1`
  typo for the `hl` register, and — more instructively — a GUIDE step that
  said "insert between X and Y" where X appeared twice in the file, landing
  the movement code in one-time setup instead of the per-frame loop. That
  one produced a new working agreement: GUIDE steps anchor with line
  numbers now, see `AGENTS.md` and `docs/DECISIONS.md`.
- **2026-08-17 — Input.** Restructured `Start:`'s dead-end hang loop into a
  real `MainLoop:` that synchronizes to VBlank once per frame (a two-phase
  wait — waiting out any current VBlank before waiting for the next one —
  since a single-phase check would fall through immediately on a repeat
  visit). Reads the joypad (`$FF00`) and inverts `BGP` while A is held.
  Hit two real bugs along the way: a `jr nc`/`jr c` mixup that broke the
  frame-pacing wait, and a joypad select-bit transposition that made "A"
  actually respond to "Right." Both found and fixed by reasoning through
  the logic, not just by the assembler. See `docs/LEARNING.md`.
- **2026-08-17 — Visible background.** Extended `src/main.asm`'s `Start:`
  routine: wrote a checkerboard tile into VRAM tile data (`$8000`), cleared
  and filled the whole 32×32 background tile map (`$9800`) with that tile's
  index, set `BGP` (`$FF47`) to the standard identity palette (`$E4`), and
  re-enabled the LCD via `LCDC` (`$FF40`) with the matching tile-data/tile-map
  addressing bits set. Confirmed in SameBoy: full-screen checkerboard,
  verified both by hand-decoding the built ROM's bytes against the linker
  map and by visual confirmation. See `docs/LEARNING.md` for the new
  concepts (tile format, `LCDC`/`BGP`, 16-bit vs. 8-bit `inc`/`dec`).
- **2026-08-17 — ROM builds, ROM boots.** Hand-wrote the smallest possible
  ROM (`src/main.asm`): fixed-address entry-point jump at `$100`, header
  padding via `ds`/`@`, and an infinite loop at `$150`. Assembled, linked,
  and fixed with `rgbasm`/`rgblink`/`rgbfix -v -p 0xFF`. Confirmed booting
  in SameBoy: logo/chime plays, then holds a stable frame — expected, since
  the PPU keeps redrawing whatever's in VRAM and our loop never touches it.
  See `docs/LEARNING.md` for the `rgbfix` padding gotcha hit along the way.
