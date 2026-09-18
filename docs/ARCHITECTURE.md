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
  loads the 128-slot dining-room atlas at `$9000` and all 11 chef
  animation frames at `$8010`, copies the 32×32 dining-room fixture into
  the background tile map, sets `BGP=$E4`/`OBP0=$E0`, zeroes `SCX`/`SCY`,
  clears OAM, sets the player's starting WRAM state, and turns the LCD
  back on with signed background addressing. Falls through into `MainLoop`.
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
  tile-map address, and returns whether the tile is structural (ID 1–16)
  in the zero flag.
- **Tile/map data** (`TileData`, `FixtureMap`, `ChefFrames`) — `INCBIN`s of
  the atlas `.2bpp`, fixture `.tilemap`, and chef frame `.2bpp` files.
  `tools/generate-structural-pilot.mjs` generates the base atlas and test
  map. `tools/generate-dining-room.mjs` extends that atlas with rear and
  dining tiles, then generates its TSX, fixture TMX, and raw tile map;
  `rgbgfx` converts the dining PNG to 2bpp.

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
sprite tile data (`$8000` up), and background tile data (`$9000` up).

The chef uses sprite tile indices 1–44 in `$8010–$82CF`. Signed background
addressing maps BG/Window IDs 0–127 to `$9000–$97FF`; the dining sheet loads all
128 slots there, with IDs 0–24 and 32–43 authored. Its static 32×32 map lives at
`$9800–$9BFF`. See `specs/background-assets.md` for the remaining VRAM
allocation and proposed future art groups.

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
- No procedural generation yet — the current map is a static dining-room
  fixture. Kitchen, patio, and deep-freezer art remain unstarted.
- No enemies, hazards, HUD, audio, or title/menu flow.
