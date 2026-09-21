# Hardware Constraints — Game Boy

Status: **skeleton**. Categories are listed because they're already known to
matter for this project; concrete numbers get filled in (and verified,
where practical) as we actually reach the point of needing them, rather
than front-loading a full hardware manual before it's relevant.

## Categories we know we'll need to track

- Display: 160×144 resolution
- Tile architecture: 8×8 tiles
- Sprite limits (total and per-scanline)
- VRAM restrictions
- WRAM / HRAM limits
- ROM banking
- CPU timing
- VBlank timing
- Audio channels

## Filled in so far

- **Display: 160×144px, background tile map is a fixed 32×32 tiles
  (256×256px).** `SCX`/`SCY` (`$FF43`/`$FF42`) pick which 160×144 window of
  that map is shown; the map wraps at its edges. This is a hardware
  requirement, not a convention — there is no mode that gives a bigger
  background map. A world bigger than 256×256px needs tile-map *streaming*
  (rewriting map rows/columns near the scroll edges), not built yet —
  deferred to pair with Level generation. See `docs/ARCHITECTURE.md`.
- **Tile data: 8×8 tiles, 2bpp planar** (16 bytes/tile: 2 bytes/row, low +
  high bit-plane as separate bytes, not interleaved per pixel). Tile data
  lives at `$8000`–`$97FF`; `LCDC` bit 4 picks unsigned (`$8000`-based) vs.
  signed (`$9000`-based) addressing for background/window tiles. **Sprite
  tiles always use unsigned `$8000` addressing**, regardless of that bit.
- **OAM (`$FE00`–`$FE9F`): 40 sprite slots, 4 bytes each** (`Y`, `X`, tile
  index, attributes). Not guaranteed zero at power-on — needs explicit
  clearing. CPU access is blocked during LCD modes 2 and 3, so direct OAM
  updates must complete during VBlank. Stored `Y`/`X` are offset (`Y = screen
  row + 16`, `X = screen column + 8`) so any position, including partially
  off-screen, is representable without negative numbers. **Sprite coordinates
  are always screen-space — sprites do not scroll with the background.** No
  native 16-pixel-wide sprite mode; a 16×16 character is 4 coordinated 8×8
  OAM entries. For sprites, color index 0 is unconditionally transparent
  regardless of palette, leaving exactly 3 opaque indices per tile.
- **Palettes: `BGP`/`OBP0`/`OBP1` (`$FF47`/`$FF48`/`$FF49`), 2 bits × 4
  entries each.** Sprites never read `BGP`. Only 4 physical gray shades
  exist on DMG hardware at all (not a software limit).
- **Joypad: `$FF00`/`P1`/`JOYP`, active-low and multiplexed.** `0` =
  pressed. Bit 5 selects the action group (A/B/Select/Start), bit 4 selects
  the direction group (Right/Left/Up/Down) — only one group readable at a
  time, and the register needs a settle read or two after switching which
  group is selected before it's trustworthy.
- **WRAM0: our own mutable state, uninitialized at power-on** — a bare `db`
  reserves a byte with no starting value; anything meaningful has to be set
  by code after boot. Currently just single-byte player state (see
  `docs/ARCHITECTURE.md`'s Memory map) — no bank switching or larger
  structures needed yet.
- **A generated 40×32-tile level fits in WRAM but not in one VRAM background
  map.** Its 1,280 one-byte tile IDs fit in the 4 KiB WRAM0 region alongside
  current state, leaving 2,804 bytes at the present 12-byte baseline. The
  32×32 VRAM map can hold the full height but only 32 of the 40 columns, so the
  renderer must replace eight wrapped columns as the camera moves. A second
  VRAM background map cannot extend the first one horizontally; `LCDC` selects
  one whole map at a time.
- **ROM banking, precise CPU/VBlank cycle timing, and audio channels: not
  yet touched.** Everything so far fits in `ROM0`; no cycle-critical code
  or sound has been written.
