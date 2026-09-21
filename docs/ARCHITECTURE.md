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
  loads the 128-slot dining-room atlas at `$9000` and all 12 chef
  animation frames at `$8010`, copies the 32×32 dining-room fixture into
  the background tile map, sets `BGP=$E4`/`OBP0=$E0`, zeroes `SCX`/`SCY`,
  clears OAM, sets the player's starting WRAM state, and turns the LCD
  back on with signed background addressing. Falls through into `MainLoop`.
- **`MainLoop`** — runs once per frame, synced to VBlank (two-phase wait).
  At the start of VBlank it commits the camera registers and all four player
  OAM entries together. It then reads the D-pad for animation state, drives
  idle/walk tile-swap animation, reads the A button (edge-detected) for
  jumping, applies horizontal movement with full-solid wall checks, applies
  gravity (velocity update, capped while falling, with tile-top swept landing
  checks and full-solid head-bump checks), clamps `PlayerX`/`PlayerY` to the
  world's bounds, picks a jump/ascent/crouch pose override when airborne or
  just landed, then loops. Gameplay changes become visible at the next VBlank.
- **Ledge catch** — while descending and holding toward a full-solid exposed
  upper corner, swept detection snaps the Chef into a hanging state. A jumps
  upward and away, while Down drops. One-way cells are never catchable.
- **`UpdateSprites`** — projects `PlayerX`/`PlayerY` (world coordinates)
  into the 4 OAM entries that make up the 16×16 player, converting to
  screen coordinates by subtracting the current `SCX`/`SCY` (sprites don't
  scroll with the background on real hardware — this subtraction is what
  makes them track it anyway). Has a normal-facing block and a `.flipped`
  block (horizontal-flip attribute bit set, left/right tile quadrants
  swapped) selected by `FacingFlip`.
- **`ReadBgTile` / `CollisionAt`** — map a world-space pixel (`D`=Y,
  `E`=X) to a BG tile ID, then use that ID to read its generated collision
  type. `IsWall` tests full solid only; `IsSupport` accepts full solid and
  one-way top surfaces. Rising and side movement use `IsWall`, while
  grounded and falling checks use `IsSupport`.
- **Player terrain hitbox** — 12×16 pixels centered on `PlayerX`, with
  `PlayerY` as its feet line. The 16×16 sprite extends two pixels beyond the
  hitbox on each side. Horizontal edges use top/middle/bottom probes and
  vertical edges use left/center/right probes so an isolated 8×8 solid tile
  cannot fall between corner-only samples.
- **Tile/map data** (`TileData`, `FixtureMap`, `CollisionTypes`,
  `ChefFrames`) — `INCBIN`s of the atlas `.2bpp`, fixture `.tilemap`,
  collision `.bin`, and chef frame `.2bpp` files.
  `tools/generate-structural-pilot.mjs` generates the base atlas and test
  map. `tools/generate-dining-room.mjs` extends that atlas with rear and
  dining tiles, then generates its TSX, fixture TMX, raw tile map, and
  128-byte collision-type table;
  `rgbgfx` converts the dining PNG to 2bpp.

## Memory map

WRAM0, `SECTION "Player State"` — all single bytes, uninitialized at
power-on, set explicitly in `Start`:

| Symbol | Meaning |
|---|---|
| `PlayerY` / `PlayerX` | Authoritative feet line and horizontal center of the 12×16 terrain hitbox, in **world coordinates** |
| `PlayerTileBase` | Index of the current animation frame's first tile (idle/walk/jump/ascent/crouch/ledge all reuse this one mechanism) |
| `AnimTimer` | Frame counter gating animation speed, decoupled from the 60fps loop |
| `FacingFlip` | `0` or `$20` (the OAM horizontal-flip attribute bit), selects which `UpdateSprites` block runs |
| `PlayerVelY` | Signed (two's-complement) vertical velocity; gravity increments it, capped at 16 while falling |
| `PrevButtons` | Previous frame's A-button state, for edge-detecting the jump press |
| `LandTimer` | Frames remaining to hold the landing-squash pose after a hard enough landing |
| `CurrentDpad` | Active-low directional input retained for ledge detection after physics reuses registers |
| `LedgeSide` | `0` when free, `1` while hanging from a wall on the right, `2` for a wall on the left |
| `LedgeTop` | Scratch world Y coordinate for the tile top currently considered by swept ledge detection |

Hardware registers in active use: `$FF40` (`LCDC`), `$FF42`/`$FF43`
(`SCY`/`SCX`), `$FF44` (`LY`), `$FF47`/`$FF48` (`BGP`/`OBP0`), `$FF00`
(joypad), OAM (`$FE00`–`$FE9F`), background tile map (`$9800`–`$9BFF`),
sprite tile data (`$8000` up), and background tile data (`$9000` up).

The chef uses sprite tile indices 1–48 in `$8010–$830F`. Signed background
addressing maps BG/Window IDs 0–127 to `$9000–$97FF`; the dining sheet loads
all 128 slots there, with IDs 0–30, 32–75, 80, and 112–115 authored. Its
static 32×32 map lives at `$9800–$9BFF`. IDs 25–30 draw the shared descent
exit, while IDs 50–63 and 112–115 provide one-way test/furniture surfaces.
The exit is metadata and art only; biome-transition runtime code does not
exist yet. See `specs/background-assets.md` for the remaining VRAM allocation.

## World vs. screen coordinates

`PlayerX`/`PlayerY` and all collision checks operate in
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
