# Architecture — Brunch Bros

Status: **authoritative**. This describes the architecture of the code that
actually exists in `src/main.asm` — never speculative or planned
architecture. Update it as real structure changes, not before.

## Source layout

Everything lives in one file, `src/main.asm` — no banking, no additional
source files yet:

- **WRAM ("Player State" section, top of file)** — see Memory map below.
- **Entry point (`$100`)** — the fixed `jp Start` + header padding every GB
  ROM needs.
- **`Start`** — one-time boot setup: waits for VBlank, disables the LCD,
  loads background/wall tiles and all 11 chef animation frames into VRAM,
  clears and populates the 32×32 background tile map (checkerboard-free
  now — just the wall tile, tile index 45, arranged into three test blocks:
  two near the start for collision/head-bump testing, one far right as a
  camera-scroll landmark), sets `BGP`/`OBP0`, zeroes `SCX`/`SCY`, clears
  OAM, sets the player's starting WRAM state, and turns the LCD back on.
  Falls through into `MainLoop`.
- **`MainLoop`** — runs once per frame, synced to VBlank (two-phase wait).
  In order: reads the D-pad for animation state, drives idle/walk tile-swap
  animation, reads the A button (edge-detected) for jumping, applies
  horizontal movement with wall-collision checks, applies gravity (velocity
  update, capped while falling, with an overflow-safe tentative-Y +
  rising/falling collision check), clamps `PlayerX`/`PlayerY` to the world's
  bounds, picks a jump/ascent/crouch pose override when airborne or just
  landed, updates `SCX`/`SCY` to follow the player (clamped, both axes),
  then calls `UpdateSprites` and loops.
- **`UpdateSprites`** — projects `PlayerX`/`PlayerY` (world coordinates)
  into the 4 OAM entries that make up the 16×16 player, converting to
  screen coordinates by subtracting the current `SCX`/`SCY` (sprites don't
  scroll with the background on real hardware — this subtraction is what
  makes them track it anyway). Has a normal-facing block and a `.flipped`
  block (horizontal-flip attribute bit set, left/right tile quadrants
  swapped) selected by `FacingFlip`.
- **`IsWall`** — takes a pixel coordinate (`D`=Y, `E`=X), converts it to a
  tile-map address, and returns whether that tile is the wall tile (index
  45) in the zero flag.
- **Tile data** (`TileData`, `ChefFrames`, `WallTile`) — `INCBIN`s of the
  `.2bpp` files `rgbgfx` produces from `gfx/*.png`.

## Memory map

WRAM0, `SECTION "Player State"` — all single bytes, uninitialized at
power-on, set explicitly in `Start`:

| Symbol | Meaning |
|---|---|
| `PlayerY` / `PlayerX` | Authoritative player position, **world coordinates** (not screen-relative) |
| `PlayerTileBase` | Index of the current animation frame's first tile (idle/walk/jump/ascent/crouch all reuse this one mechanism) |
| `AnimTimer` | Frame counter gating animation speed, decoupled from the 60fps loop |
| `FacingFlip` | `0` or `$20` (the OAM horizontal-flip attribute bit), selects which `UpdateSprites` block runs |
| `PlayerVelY` | Signed (two's-complement) vertical velocity; gravity increments it, capped at 16 while falling |
| `PrevButtons` | Previous frame's A-button state, for edge-detecting the jump press |
| `LandTimer` | Frames remaining to hold the landing-squash pose after a hard enough landing |

Hardware registers in active use: `$FF40` (`LCDC`), `$FF42`/`$FF43`
(`SCY`/`SCX`), `$FF44` (`LY`), `$FF47`/`$FF48` (`BGP`/`OBP0`), `$FF00`
(joypad), OAM (`$FE00`–`$FE9F`), background tile map (`$9800`–`$9BFF`),
tile data (`$8000` up).

## World vs. screen coordinates

`PlayerX`/`PlayerY` and all wall-collision checks (`IsWall`) operate in
**world space** — the coordinate system of the full scrollable
background. `SCX`/`SCY` pick which 160×144 window of that world is
currently visible. Because OAM sprite coordinates are always screen-space
on real hardware, `UpdateSprites` is the only place world coordinates get
converted (`world − scroll`) before anything touches the screen. The world
is currently capped at 256×256px (one full 32×32 tile map — the hardware's
physical ceiling); worlds bigger than that need tile-map streaming, not
built yet (see `docs/ROADMAP.md`'s Camera / room traversal entry and
`docs/LEARNING.md`).

## Not yet in place

- No ROM banking (everything fits in `ROM0`/bank 0 so far).
- No tileset/level-data structure — walls are still hand-placed test
  blocks written directly into `Start`, not real level content.
- No enemies, hazards, HUD, audio, or title/menu flow.
