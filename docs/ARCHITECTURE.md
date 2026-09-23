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
  animation frames at `$8010`, copies the build-time-generated 40×32 seed into
  `LevelMap`, loads its first 32 columns into the background tile map, sets
  `BGP=$E4`/`OBP0=$E0`, zeroes the camera and streaming state, clears OAM,
  sets the player's starting WRAM state, and turns the LCD back on with
  signed background addressing. Falls through into `MainLoop`.
- **`MainLoop`** — runs once per frame, synced to VBlank (two-phase wait).
  At the start of VBlank it streams one newly exposed or restored background
  column when needed, then commits the camera registers and all four player
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
- **Crouch** — holding Down while grounded selects the existing crouch frame
  and suppresses horizontal movement. The terrain hitbox stays 12×16.
- **One-way drop-through** — pressing A while holding Down first checks the
  three support probes. If any probe is full-solid, ordinary jump handling
  remains in force. Otherwise, one-way support moves the Chef's feet one pixel
  below the landing plane and resumes gravity, preventing immediate re-landing
  on the same tile top.
- **`UpdateSprites`** — projects `PlayerX`/`PlayerY` (world coordinates)
  into the 4 OAM entries that make up the 16×16 player, converting to
  screen coordinates by subtracting the current `SCX`/`SCY` (sprites don't
  scroll with the background on real hardware — this subtraction is what
  makes them track it anyway). Has a normal-facing block and a `.flipped`
  block (horizontal-flip attribute bit set, left/right tile quadrants
  swapped) selected by `FacingFlip`.
- **`ReadLevelTile` / `CollisionAt`** — map a world-space pixel (`D`=Y,
  `C:E`=16-bit X) to the 40-wide WRAM level's tile ID, then use that ID to
  read its generated collision type. Collision never reads the wrapped VRAM
  view. `IsWall` tests full solid only; `IsSupport` accepts full solid and
  one-way top surfaces. Rising and side movement use `IsWall`, while grounded
  and falling checks use `IsSupport`.
- **`TryDropThrough`** — distinguishes collision type 2 from full-solid support
  across the complete terrain hitbox and reports a successful Down+A drop in
  the carry flag.
- **`UpdateStreaming` / `StreamColumn`** — treat `$9800–$9BFF` as a horizontal
  ring buffer. As `CameraX` passes eight-pixel boundaries, logical columns
  32–39 replace physical columns 0–7 after those columns leave the viewport;
  moving left restores logical columns 0–7 before they reappear.
- **Player terrain hitbox** — 12×16 pixels centered on `PlayerX`, with
  `PlayerY` as its feet line. The 16×16 sprite extends two pixels beyond the
  hitbox on each side. Horizontal edges use top/middle/bottom probes and
  vertical edges use left/center/right probes so an isolated 8×8 solid tile
  cannot fall between corner-only samples.
- **Tile/map data** (`TileData`, `GeneratedLevelMap`, `CollisionTypes`,
  `ChefFrames`) — `INCBIN`s of the atlas `.2bpp`, seeded `.tilemap`,
  collision `.bin`, and chef frame `.2bpp` files.
  `tools/generate-structural-pilot.mjs` generates the base atlas and test
  map. `tools/generate-dining-room.mjs` extends that atlas with rear and
  dining tiles, then generates its TSX, fixture TMX, raw tile map, and
  128-byte collision-type table. `tools/generate-room-template-playtest.mjs`
  retains the accepted three-room regression map.
  `tools/generate-seeded-level.mjs` selects all 16 room templates for seed 0
  and emits the raw map and player-start constants used by the ROM. `rgbgfx`
  converts the dining PNG to 2bpp.

## Memory map

WRAM0, `SECTION "Player State"` — uninitialized at power-on and set explicitly
in `Start`:

| Symbol | Meaning |
|---|---|
| `PlayerY` / `PlayerX` | Authoritative feet line and horizontal center of the 12×16 terrain hitbox, in **world coordinates**; X is 16-bit and Y is 8-bit |
| `CameraX` | 16-bit logical horizontal camera position; its low byte is committed to `SCX` |
| `StreamedColumns` | Number of wrapped columns currently representing logical columns 32–39 |
| `PlayerTileBase` | Index of the current animation frame's first tile (idle/walk/jump/ascent/crouch/ledge all reuse this one mechanism) |
| `AnimTimer` | Frame counter gating animation speed, decoupled from the 60fps loop |
| `FacingFlip` | `0` or `$20` (the OAM horizontal-flip attribute bit), selects which `UpdateSprites` block runs |
| `PlayerVelY` | Signed (two's-complement) vertical velocity; gravity increments it, capped at 16 while falling |
| `PrevButtons` | Previous frame's A-button state, for edge-detecting the jump press |
| `LandTimer` | Frames remaining to hold the landing-squash pose after a hard enough landing |
| `CurrentDpad` | Active-low directional input retained for ledge detection after physics reuses registers |
| `LedgeSide` | `0` when free, `1` while hanging from a wall on the right, `2` for a wall on the left |
| `LedgeTop` | Scratch world Y coordinate for the tile top currently considered by swept ledge detection |
| `PlayerGrounded` | `1` after support collision resolves a landing; cleared before airborne physics |
| `LevelMap` | Complete 40×32 logical tile map, 1,280 bytes in row-major order |

Hardware registers in active use: `$FF40` (`LCDC`), `$FF42`/`$FF43`
(`SCY`/`SCX`), `$FF44` (`LY`), `$FF47`/`$FF48` (`BGP`/`OBP0`), `$FF00`
(joypad), OAM (`$FE00`–`$FE9F`), background tile map (`$9800`–`$9BFF`),
sprite tile data (`$8000` up), and background tile data (`$9000` up).

The chef uses sprite tile indices 1–48 in `$8010–$830F`. Signed background
addressing maps BG/Window IDs 0–127 to `$9000–$97FF`; the dining sheet loads
all 128 slots there, with IDs 0–30, 32–75, 80, and 112–115 authored. The
build-time-generated seed 0 lives in `LevelMap`; `$9800–$9BFF` contains its
streamed 32-column view. Its templates use ID 50 for one-way steps and IDs
25–30 for the shared descent exit. Biome-transition runtime code does not exist
yet. See
`specs/background-assets.md` for the remaining VRAM allocation.

## World vs. screen coordinates

`PlayerX`/`PlayerY` and all collision checks operate in **world space** over
the 320×256px logical level. `SCX`/`SCY` pick the 160×144 hardware view;
horizontal streaming keeps its wrapped tile columns synchronized with the
logical map. Because OAM sprite coordinates are always screen-space on real
hardware, `UpdateSprites` derives the on-screen position every frame as
`world − camera` before writing OAM. The low-byte subtraction remains correct
across X=256 because the visible difference is always less than 256 pixels.

## Not yet in place

- No ROM banking (everything fits in `ROM0`/bank 0 so far).
- No procedural generation yet — the current map is a static dining-room
  fixture. Kitchen, patio, and deep-freezer art remain unstarted.
- No enemies, hazards, HUD, audio, or title/menu flow.
