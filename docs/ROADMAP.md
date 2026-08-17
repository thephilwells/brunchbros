# Roadmap — Brunch Bros

Milestones, roughly in order. This sequence is expected to evolve as we
learn — it's a guide, not a locked contract. Completed items are checked;
everything else is upcoming.

## Milestones

- [x] ROM builds
- [x] ROM boots
- [x] Visible background
- [x] Input
- [ ] Movable object
- [ ] Player sprite
- [ ] Movement
- [ ] Collision
- [ ] Jumping
- [ ] Camera / room traversal
- [ ] Hazards
- [ ] Enemies
- [ ] Level generation
- [ ] Gameplay systems
- [ ] Additional areas
- [ ] Audio
- [ ] Polish
- [ ] Complete game

## Immediate next milestone

**Movable object** — get something represented via a sprite (OAM), not just
background tiles. Not yet explained in detail — covered when we start on
it.

## Completed

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
