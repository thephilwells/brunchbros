# Roadmap — Brunch Bros

Milestones, roughly in order. This sequence is expected to evolve as we
learn — it's a guide, not a locked contract. Completed items are checked;
everything else is upcoming.

## Milestones

- [x] ROM builds
- [x] ROM boots
- [ ] Visible background
- [ ] Input
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

**Visible background** — get something we control onto the screen. Will
need VRAM layout, tiles vs. the background tile map, and the `LCDC`
register (the LCD generally has to be off before writing VRAM outside of
VBlank). Not yet explained in detail — covered when we start on it.

## Completed

- **2026-08-17 — ROM builds, ROM boots.** Hand-wrote the smallest possible
  ROM (`src/main.asm`): fixed-address entry-point jump at `$100`, header
  padding via `ds`/`@`, and an infinite loop at `$150`. Assembled, linked,
  and fixed with `rgbasm`/`rgblink`/`rgbfix -v -p 0xFF`. Confirmed booting
  in SameBoy: logo/chime plays, then holds a stable frame — expected, since
  the PPU keeps redrawing whatever's in VRAM and our loop never touches it.
  See `docs/LEARNING.md` for the `rgbfix` padding gotcha hit along the way.
