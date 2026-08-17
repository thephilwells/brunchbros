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

## Up next

The first milestone will require understanding: ROM header layout, memory
sections (`ROM0`/`ROMX`/`WRAM0`/etc. in RGBDS terms), the entry point and
boot process, basic RGBDS assembler syntax, linking, and what `rgbfix` does
to a ROM. These will be added here individually as we actually cover them,
not dumped in ahead of time.
