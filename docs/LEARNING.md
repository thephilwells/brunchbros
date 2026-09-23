# Learning Map — Game Boy / RGBDS Concepts

Status: **living document**, updated as concepts actually come up. Not a
textbook — nothing gets added here speculatively, only after we've actually
covered it.

## How to read this

Each entry: concept name, one-line summary of what Phil now understands
about it, and a pointer to where it was introduced (spec, decision, or
milestone) if useful.

## Concepts covered so far

- **`rgbfix` only fixes what you explicitly ask it to.** It does not infer
  or cross-check anything on its own. `-v` (`--validate`, = `-f lhg`) only
  patches the Nintendo logo and the two checksums — it does *not* touch the
  ROM-size byte (`$148`) or resize the file. `rgblink` produced a 16 KiB
  file for our first ROM, but with no `-p` the size byte was left at
  whatever was already there (`$00`, meaning "32 KiB") — a real,
  undetected mismatch between the header's claimed size and the actual
  file size. `-p <pad_value>` (e.g. `-p 0xFF`) is what pads the file to the
  next valid size (32 KiB, 64 KiB, ...) *and* updates `$148` to match.
  First hit while producing the smallest bootable ROM — see
  `docs/ROADMAP.md`.

- **Tile data is 2bpp planar, not packed.** Each 8×8 tile is 16 bytes: 2
  bytes per row, a "low bit-plane" and a "high bit-plane." A pixel's 2-bit
  color index is `(high-plane bit << 1) | low-plane bit` — the two planes
  are stored as whole separate bytes per row, not interleaved per pixel.
  Tile data lives in VRAM at `$8000`–`$97FF`; `LCDC` bit 4 picks the
  addressing mode (`1` = unsigned, tile 0 at `$8000`; `0` = signed, tile 0
  at `$9000`). The background tile map (`$9800`–`$9BFF` or `$9C00`–`$9FFF`,
  chosen by `LCDC` bit 3) is a separate 32×32 grid of tile *indices* — not
  pixel data itself.

- **`BGP` (`$FF47`) packs 4 palette entries into one byte,** 2 bits each:
  bits `1:0` = shade for color index 0, `3:2` = index 1, `5:4` = index 2,
  `7:6` = index 3. `$E4` (`%11100100`) is the near-universal "identity"
  value (index N → shade N) used at startup by almost every commercial GB
  game.

- **16-bit `inc`/`dec` set no flags at all; 8-bit `inc`/`dec` do.** So a
  16-bit register (e.g. `bc`) can't be used directly as a `jr nz`-driven
  loop counter — only 8-bit registers can. To loop more than 255 times,
  nest two 8-bit counters (e.g. an outer count of 4, inner starting at `0`
  so `dec` wraps through all 256 values before hitting zero — `4 × 256 =
  1024`, used to clear the background tile map).

- **`P1`/`JOYP` (`$FF00`) is active-low and multiplexed.** `0` means
  *pressed*, `1` means released — backwards from the obvious guess. Only 4
  of the 8 buttons are readable at once: bit 5 selects the **action**
  group (A/B/Select/Start), bit 4 selects the **direction** group
  (Right/Left/Up/Down), both also active-low (`0` = select that group).
  **Easy to transpose which bit is which** — that exact mixup (writing
  `%00100000`, which selects direction and deselects buttons, while
  believing it selected buttons) made "A" actually read as "Right," since
  bit 0 means A in one group and Right in the other. Correct value to
  select only the action group: `%00010000`. Also: right after switching
  the select bits, the hardware needs a moment to settle — read the
  register a couple of times and discard the early read(s) before trusting
  it.

- **`BIT n, r` sets the zero flag to the *complement* of that bit** — `Z=1`
  means the bit was `0`. Convenient for active-low input: `Z=1` directly
  means "pressed," no inversion needed.

- **OAM (`$FE00`–`$FE9F`) is a separate memory region from background
  tiles/tile map** — 40 slots, 4 bytes each: `Y`, `X`, tile index,
  attributes. A sprite can sit at any pixel, not locked to the 8×8 grid.
  The stored `Y`/`X` are offset from the actual screen position — `Y =
  screen row + 16`, `X = screen column + 8` — so a sprite can be given
  byte values that place it fully off any edge of the screen without
  needing negative numbers. OAM's contents aren't guaranteed zero at
  power-on, so all 40 slots need clearing before use, or leftover slots
  can render as stray garbage sprites.

- **Sprite tiles always use unsigned `$8000` addressing**, regardless of
  `LCDC` bit 4 (that bit only affects background/window tiles). And for
  sprites specifically, color index `0` is *always* transparent, no matter
  the palette — only indices 1–3 actually draw.

- **Sprites use their own palette registers, `OBP0`/`OBP1` (`$FF48`/`$FF49`)
  — never `BGP`.** This produced two back-to-back, fully-explainable visual
  surprises: with `OBP0` left uninitialized (whatever it powered on with),
  a sprite reusing the background's tile and sitting exactly tile-aligned
  rendered identically to the background under it (invisible) normally,
  then turned into a solid block once an unrelated `BGP`-only palette
  change happened to make the background's colors match the sprite's
  fixed, untouched `OBP0` rendering. Once `OBP0` was deliberately set to a
  *different* value than `BGP`, the same mechanism ran in reverse: whenever
  the two registers happened to hold the same value, the sprite blended
  in and "vanished" — not because anything moved, but because `OBP0` and
  `BGP` were numerically identical at that instant.

- **`WRAM0` sections hold our own mutable state, and can't be pre-initialized.**
  `SECTION "...", WRAM0` declares space in Work RAM; a bare `db` (no
  arguments) there reserves 1 uninitialized byte, same as `ds 1` — unlike
  ROM, there's no way to give a RAM byte a starting value in its
  declaration. Values have to be set explicitly by code after boot. First
  used for `PlayerY`/`PlayerX`, the authoritative position that gets
  projected into OAM every frame.

- **`CALL`/`RET` use the stack** — `CALL label` pushes the address of the
  next instruction, then jumps; `RET` pops that address and returns to it.
  This is what makes a reusable subroutine possible, as opposed to `jp`/`jr`
  which never come back. The boot ROM already initializes `SP` to `$FFFE`
  before handing off control, so `ld sp, $fffe` at the start of `Start` isn't
  strictly required — but doing it explicitly is standard practice in real
  GB games, and costs one line.

- **Editor alpha transparency and DMG sprite transparency are unrelated.**
  Aseprite's alpha channel is an editor-only concept; the hardware has no
  alpha at all. Sprite transparency is entirely about color index `0`, which
  is always see-through no matter what shade it maps to. Exporting art with
  any actually-transparent (alpha `0`) pixels breaks `rgbgfx`'s DMG palette
  mode (`-c dmg=...`), which requires "all colors in shades of gray, without
  any transparent colors." Fix: fill "empty" areas with solid, opaque white
  (the shade that maps to index 0 under `dmg=E4`) instead of leaving them
  transparent.

- **A 16×16 character is 4 coordinated 8×8 sprites, not one bigger sprite.**
  The Game Boy has no native 16-pixel-wide sprite mode — only 8×8 or 8×16
  *tall* (`LCDC` bit 2). A square 16×16 look means a 2×2 grid of independent
  OAM entries (4 of the 40 slots), all repositioned together from one
  authoritative WRAM position — the `UpdateSprites` pattern, reusable for
  every future character/enemy. `rgbgfx`'s default (row-major, no `-u`/`-m`)
  tile-slicing order for a multi-tile image is confirmed: left-to-right,
  top-to-bottom — top-left, top-right, bottom-left, bottom-right.

- **`OBP0`/`OBP1` are fully arbitrary mappings — nothing requires distinct
  shades per index, and index 0's transparency can't be recovered.** Only 4
  physical gray shades exist on DMG hardware at all (a fixed 2-bit-per-pixel
  LCD, not a software limit), and for sprites index 0 is unconditionally
  transparent no matter what's in the palette register — so it's permanently
  unusable for any opaque content. That leaves exactly 3 free indices (1–3)
  for a sprite's *entire* visible appearance. Hit this rebuilding the chef:
  parts of the art that were meant to be an opaque *white* (a jacket) can't
  be drawn as literal white in the source PNG, since that value maps to
  index 0 and would be see-through. Fix (the "Kirby trick" — real GB sprites
  like Kirby rely on exactly this): draw that content using a different gray
  value in the editor (e.g. light gray, landing on index 1), then set that
  index's `OBP0` field to shade 0 anyway. The editor shows a visibly
  different (gray) color; in-game it renders identically to true white,
  while staying opaque. Corollary: wanting 4+ distinct *opaque* tones on one
  sprite isn't achievable — something has to merge, unless different OAM
  entries are deliberately split across `OBP0` vs `OBP1` for more variety
  across a multi-sprite composite (still capped at 3 within any single tile).

- **Animation speed has to be decoupled from the game loop's 60fps.**
  Changing the displayed frame every `MainLoop` iteration would blur past
  too fast to see. Standard fix: a WRAM counter incremented every frame,
  only acting once it crosses a threshold (then resetting to 0) — the
  threshold *is* the animation speed, a single tunable number.

- **`XOR A, n` toggles between two values that differ by exactly one bit.**
  The idle animation's two tile bases (`1` and `5`) differ only in bit 2
  (value `4`), so `xor a, 4` alternates between them with one instruction —
  no separate "which frame" flag needed, since the tile-base value itself
  encodes the state.

- **Detecting a state transition vs. continuing the current state** is a
  recurring shape: check whether the current value already belongs to the
  *desired* mode's range; if not, snap directly to that mode's starting
  value (and reset any per-mode timer) instead of blindly continuing
  arithmetic that assumed the old mode. Needed once idle (`1`/`5`) and walk
  (`9,13,17,21,25,29`) became different, non-adjacent ranges — naively
  incrementing/toggling across a mode switch produced nonsense values.

- **`JR`'s target is a signed 8-bit relative offset — max ±127 bytes.**
  Unlike `JP` (full 16-bit absolute address, one byte bigger), `JR` can run
  out of reach if the code between it and its label grows too much.
  `rgbasm` errors rather than silently miscompiling it. Hit this when
  `MainLoop` grew past `jr MainLoop`'s reach; fixed by switching to `jp
  MainLoop`. Any loop that keeps growing can eventually outgrow `jr`.

- **Flipping a multi-tile sprite needs the attribute bit *and* a position
  swap.** `OAM` attribute bit 5 (`$20`) mirrors one tile's pixels
  horizontally, but for a 2×2 composite that's not enough on its own — the
  quadrant that was top-left also has to start rendering at the top-right
  screen position (and vice versa for each pair), or the flip only mirrors
  each tile in place rather than the whole character. Both pieces (bit +
  swapped tile-offset assignment) are required together.

- **Pixel → tile coordinate is `SRL` ×3 (÷8); tile-map address needs
  `ADD HL, HL` ×5 (×32).** No hardware divide or multiply, so both are
  built from repeated shifts: `SRL A` three times converts a pixel
  coordinate to a tile row/column; `ADD HL, HL` doubles a 16-bit value
  (no direct 16-bit shift-left exists), and five doublings gives `row×32`
  — the tile map's per-row byte stride — as a proper 16-bit value with no
  overflow risk. Combined: `$9800 + row×32 + column`.

- **A subroutine can take real parameters via registers, and return an
  answer via a flag.** `IsWall` takes `D`=Y, `E`=X (pixel coordinates) and
  returns its result in the zero flag (`Z`=1 means "this tile is solid"),
  the same "flag as the answer" convention `BIT` established. It
  deliberately avoids clobbering `B` (the caller's joypad reading, still
  needed right after) while freely using `D`/`E`/`H`/`L` as working space —
  fine, since those are exactly the inputs, expected to be fresh each call.

- **A 16×16 sprite needs 2 collision-check points per direction, not 1.**
  Since the chef spans 2 tile rows (moving horizontally) or 2 tile columns
  (moving vertically), checking only one corner would let him clip past a
  wall at the unchecked corner. Both relevant corners must come back clear
  before a move is allowed.

- **Before reusing a register to hold a value across a `CALL`, check what
  the callee clobbers.** Bit this twice in the same milestone: first, the
  jump-trigger code stashed a scratch value in `B` — but `B` held the
  D-pad reading needed right after, for the movement checks. Then, the
  falling-collision code stashed the tentative new `Y` in `C` across two
  calls to `IsWall` — but `IsWall` uses `C` internally (for the tile
  column) and never restores it, so after the first call `C` held
  leftover garbage instead of the real value, corrupting the second check
  and the final applied position. Both bugs had the identical shape: a
  register assumed to "just sit there" across a call that actually
  touches it. The fix each time was the same — read the subroutine's body
  for which registers it uses as scratch, and pick one it doesn't.

- **The idle/walk tile-swap mechanism generalizes to any pose, not just
  locomotion.** Jump/ascent/crouch reuse exactly the same trick — swap
  `PlayerTileBase` to a different pre-drawn frame's tile index — just
  driven by physics state (velocity sign/magnitude, a landing timer)
  instead of D-pad input. No new hardware technique needed, only more art
  frames and more conditions for picking one.

- **A "just landed" check needs a magnitude guard, not just an edge.**
  While resting on the ground, gravity nudges `PlayerY` down by 1 every
  frame and collision immediately catches and resets it — meaning "did we
  just land" would be true on literally every resting frame without a
  guard. Fix: only treat it as a real landing (and trigger the settle
  animation) if the velocity right before the reset was above a small
  threshold (`>= 3`, since resting oscillates between 0 and 1).

- **Two state machines sharing one variable must agree on every value's
  meaning, not just the ones each one writes.** The walk-cycle animation
  checked "is `PlayerTileBase >= 9`" to mean "already mid-walk-cycle" —
  true when we only had idle (1/5) and walk (9-29) ranges. Once the jump
  pose-override started also writing to `PlayerTileBase` (33-44), a
  leftover pose value satisfied that same `>= 9` check, so the walk logic
  treated it as "continue walking" and blindly did `+4`, landing on the
  *wall tile's own index* by coincidence. Fix: validate both bounds (`9`
  to `< 30`), not just the lower one — any value outside the true walk
  range, for any reason, now correctly triggers a fresh snap-to-start
  instead of being misread as a continuation.

- **Rising and falling collision are symmetric, and can share their "no
  collision" landing point.** `.checkRising` (top-edge points, on a hit:
  zero velocity, no landing animation) mirrors the falling check
  (bottom-edge points, on a hit: `.landed`) almost exactly — both simply
  fall through to the same `.applyFall` when clear, rather than needing
  two separate "commit the move" code paths.

- **`SCX`/`SCY` (`$FF43`/`$FF42`) pick which 160×144 window of the 256×256px
  background is shown** — the background tile map's hardware size never
  changes, only the visible offset into it does. Scrolling is a camera, not
  a bigger world; the map wraps at 256×256, so an unclamped scroll value
  would eventually show the far edge of the map wrapping back into view.

- **Sprites don't scroll with the background — OAM coordinates are always
  screen-space.** Only `SCX`/`SCY` shift what the background shows; a
  sprite's `Y`/`X` bytes are untouched by either register. Once the world
  became bigger than one screen, `PlayerX`/`PlayerY` had to be treated as
  *world* coordinates (used as-is for collision, since walls are placed in
  world/map space), with `UpdateSprites` deriving the actual on-screen
  position every frame as `world − scroll` right before writing to OAM.

- **Camera-follow is "center on the player, then clamp to the world's
  scrollable range," and that clamp is a different clamp from the
  position clamp.** `SCX = PlayerX − 80` (half the 160px screen), then
  clamped to `[0, world_width − 160]` so the camera never shows past the
  map's edge. This is independent from the existing clamp on `PlayerX`
  itself (which stops the player from walking off the world) — the two
  can legitimately disagree near an edge (player pinned at the world's
  edge while the camera has already hit its own clamp short of matching
  exactly), which is normal, correct platformer behavior, not a bug.

- **Extending the world's height resurfaced a dormant 8-bit overflow risk.**
  `PlayerY` is a single byte; `PlayerY + PlayerVelY` can exceed 255 once
  falls get long enough to matter, silently wrapping to a small,
  nonsensical position instead of erroring. Fixed two ways together: a
  velocity cap (falling `PlayerVelY` capped at 16, gated to only the
  falling branch — rising never had a symmetric risk, since the jump
  impulse is a fixed `-8` and `PlayerY` is always ≥16, so the worst case
  is `16 − 8 = 8`, safely non-negative) plus reading `ADD`'s carry flag
  (set precisely "on overflow from bit 7," confirmed via `man 7 gbz80`)
  to detect a genuine wrap and land at the world's bottom edge directly
  instead of trusting the wrapped value.

- **Flags survive intervening instructions unless that instruction's own
  documentation says it touches them — checked, not assumed.** The
  overflow check above needed the carry flag from an `ADD` to survive an
  intervening `LD`/`BIT`/conditional jump before being read. Verified via
  `man 7 gbz80`'s per-instruction flag listings, not the coarser opcode
  summary used earlier: `LD` affects no flags at all, and `BIT u3,r8`
  only touches `Z`/`N`/`H` — `C` passes through untouched. This let the
  same carry value be computed once, then checked later only inside the
  falling branch (checking it before branching would misfire, since
  adding a two's-complement-negative velocity to a small `PlayerY`
  routinely sets carry as a normal encoding artifact of rising motion,
  not a true overflow).

- **The background tile map is a hard 32×32-tile (256×256px) hardware
  ceiling, but it can be used as a ring buffer for a larger logical map.**
  The 40×32 fixture lives completely in WRAM. As the camera moves right,
  logical columns 32–39 replace physical VRAM columns 0–7 only after their
  original contents leave the viewport; moving left restores columns 0–7
  before they reappear. Collision reads WRAM rather than VRAM because one
  physical column can represent two different logical columns over time.

- **A 320-pixel world needs 16-bit horizontal world coordinates even though
  `SCX` and OAM X remain eight-bit.** `PlayerX` and `CameraX` use two bytes.
  The camera itself only ranges from 0–160 for this world, and the visible
  player-to-camera difference stays below 256, so the low byte of their
  subtraction is the correct OAM coordinate even after `PlayerX` crosses
  X=256.

- **Direct OAM writes must happen during a known writable display period.**
  The CPU cannot access OAM during LCD modes 2 and 3. Writing four sprite
  entries at the end of an increasingly long frame eventually produced a
  split update: some coordinates changed while the lower half retained an
  old Y position. The main loop now commits the camera and all four Chef OAM
  entries immediately after entering VBlank, then calculates the next state.

## Up next

The first milestone will require understanding: ROM header layout, memory
sections (`ROM0`/`ROMX`/`WRAM0`/etc. in RGBDS terms), the entry point and
boot process, basic RGBDS assembler syntax, linking, and what `rgbfix` does
to a ROM. These will be added here individually as we actually cover them,
not dumped in ahead of time.
