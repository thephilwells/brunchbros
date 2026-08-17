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

## Up next

The first milestone will require understanding: ROM header layout, memory
sections (`ROM0`/`ROMX`/`WRAM0`/etc. in RGBDS terms), the entry point and
boot process, basic RGBDS assembler syntax, linking, and what `rgbfix` does
to a ROM. These will be added here individually as we actually cover them,
not dumped in ahead of time.
