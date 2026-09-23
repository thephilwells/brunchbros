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
- [x] Collision
- [x] Jumping
- [x] Camera / room traversal
- [x] Tileset backgrounds
- [ ] Player traversal baseline
- [ ] Level design rules
- [ ] Level generation
- [ ] Hazards
- [ ] Enemies
- [ ] Combat
- [ ] Loot and carried objects
- [ ] HUD
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
- **Player traversal baseline** — fixes the Chef's terrain hitbox and adds
  ledge catch/jump/drop before generated-room reachability is defined. It also
  covers crouch/look poses and camera look-ahead because those are best
  evaluated against authored vertical geometry, though they do not increase
  jump reach.
- **Level design rules** — records the legal geometry, spawn/exit clearance,
  baseline traversal envelope, optional skill-gated paths, and biome
  parameters before code assembles rooms from them. Boss arenas remain
  curated exceptions rather than ordinary generated rooms.
- **Combat** — introduces the frying-pan attack, hit detection, and required
  attack poses before enemies depend on it.
- **Loot and carried objects** — introduces breakable loot eggs plus lifting,
  carrying, throwing, and their Chef poses. Inventory consequences remain a
  separate decision.
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

## Polish backlog

No current items. Add feel/tuning observations here rather than relying on
conversation history.

## Immediate next milestone

**Player traversal baseline** — the 12×16 terrain hitbox is implemented and
accepted after SameBoy edge-overhang review. Ledge catch/jump/drop and its
new hanging pose are accepted after SameBoy review. Grounded crouching is also
accepted with the 12×16 terrain hitbox unchanged. The tested three-tile
same-height gap is now the authoritative hard maximum. Two-tile minimum
platforms and the 24/32/64-pixel vertical transition limits are also accepted.
Spawn/exit safety envelopes and ordinary versus isolated boundary-case
tolerances are now defined. The common 40×32-tile level size and pre-generated
WRAM map with horizontal VRAM streaming are also settled. The static fixture
now implements 16-bit horizontal coordinates and bidirectional column
streaming, accepted after seamless SameBoy traversal across the X=256 seam and
back. The row-monotone 4×4 critical-route representation, fixed room ports,
template contract, and offline gallery/validation format are now defined. The
host-side route generator exhaustively validates all 1,024 macro topologies and
connects every room through optional branch trees before exporting seeded
HTML/TMX/JSON connectivity galleries. The semantic template format and initial
W|E, N|S, and N|E rooms are composed into a static bidirectional ROM playtest.
Their ascent and Down+A return route are accepted in SameBoy. Next, add
tile-level reachability checks and complete the remaining port masks before porting the same
deterministic contract to assembly. Directional look poses and camera
look-ahead can ship in the same milestone but are not blockers for procedural
generation. See
`notes/2026-09-21-player-abilities-and-generation-prerequisites.md`.

## Completed

- **2026-09-21 — Tileset backgrounds (first-biome baseline).** Completed a
  128-tile dining-room atlas with structural connectivity variants, rear
  surfaces and trim, passable wall details, one-way table/chair/booth/counter
  furniture, and the shared descent doorway. PNG, TSX, TMX, raw tilemap,
  collision table, build wiring, and SameBoy review are all in place. The
  other biome tilesets remain under Additional areas; level generation can
  now use Dining Room as its first complete visual test vocabulary.

- **2026-08-27 — Camera / room traversal.** Explicit `SCX`/`SCY` init at
  boot (closing a long-standing "never set, happens to read 0" gap), then
  a `UpdateSprites` refactor to split world coordinates (`PlayerX`/
  `PlayerY`, used as-is for collision) from screen coordinates (derived as
  `world − scroll` right before writing OAM) — necessary because sprites
  don't scroll with the background on real hardware. Horizontal
  camera-follow shipped first (widened world, centered/clamped `SCX`, a
  far-right landmark block to confirm scrolling), then vertical
  camera-follow (`SCY`, same pattern) after a deliberate scope discussion:
  Spelunky's real world is ~4 screens per axis, far beyond the hardware's
  fixed 32×32-tile (256×256px) map ceiling, so true bigger-than-one-map
  worlds need tile-map *streaming* — explicitly deferred to pair with the
  future Level generation milestone, once there's real content to stream.
  Extending the world's height ahead of that also resurfaced a dormant
  8-bit overflow risk in long falls (`PlayerY + PlayerVelY` past 255),
  fixed with a falling-only velocity cap plus a carry-flag-based overflow
  check verified against `man 7 gbz80`'s per-instruction flag semantics.
  See `docs/LEARNING.md` for the new concepts.
- **2026-08-18 — Jumping.** Gravity (WRAM `PlayerVelY`, a signed
  two's-complement value, incremented every frame) plus an edge-detected
  A-button jump trigger, generalized to work from any grounded height (true
  ground *or* standing on a solid tile — not just the screen-bottom
  clamp). Vertical collision built symmetrically: `.checkRising` (head-bump,
  checking top-edge points) mirrors the existing falling/landing check
  (bottom-edge points), both converging on a shared `.applyFall`. Full
  squash/stretch/settle animation — jump/ascent/crouch poses reusing the
  same tile-swap mechanism as idle/walk, gated by velocity sign/magnitude
  and a landing timer. Two second platform test tiles added for verifying
  landing, head-bump, and platform-to-platform jumping together. Hit and
  fixed three real bugs along the way: two register-clobbering bugs (`B`
  holding the D-pad reading, `C` holding a tentative position, both
  clobbered by unaccounted-for `IsWall` calls), and a bug where the
  walk-cycle animation's range check didn't validate its upper bound,
  letting a leftover jump-pose value be misread as "continuing the walk
  cycle" and corrupted into the wall tile's own index. See
  `docs/LEARNING.md` for the new concepts.
- **2026-08-18 — Collision.** Two layers: screen-boundary clamping
  (`PlayerX`/`PlayerY` snapped to valid ranges after movement, so the
  player can no longer walk off any edge or wrap via 8-bit overflow), and
  real tile-based wall collision against a hand-authored placeholder wall
  tile (solid `$FF`, tile index 33) arranged as a 4×4 test block via a new
  `IsWall` subroutine — converts a pixel coordinate to a tile-map address
  (`SRL` ×3 for ÷8, `ADD HL,HL` ×5 for ×32) and compares against the wall
  tile index, returning its answer in the zero flag. Checked from two
  corners per direction (since the 16×16 sprite spans 2 tile rows/columns),
  wired into all four movement directions. **The 4×4 black test block is
  an arbitrary placeholder** — expect it to be removed or replaced once
  real level content exists; it did its job proving the collision
  mechanism works, nothing more. Hit a real linker error mid-step from an
  ambiguously-worded GUIDE instruction (two line numbers named in one
  sentence); see `docs/DECISIONS.md`. See `docs/LEARNING.md` for the new
  concepts.
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
