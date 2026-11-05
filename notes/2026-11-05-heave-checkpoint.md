# HEAVE checkpoint and budget guard

Checkpoint date: 2026-11-05

Baseline commit:
`83e3e8737f81c002d73547329a0febdb613340c7` (`architecture for interactive eggs`)

The committed source and generated assets were clean before checkpoint work.
Reproducible generation, production assembly, and the existing structural
verification suite passed.

## Behavior-neutral prerequisites

The room-variant fixture exposed a pre-existing ROM0 placement failure. The
1,040-byte Treasure Egg runtime moved from ROM0 to ROMX, while the 1,048-byte
DISCO_FRY runtime moved from ROMX to ROM0. The BURGER fixture no longer embeds
the unused WEINER combat map or its loader. No runtime behavior changed.
Production and every conditional gameplay fixture assembled, linked, passed
`rgbfix`, and remained a two-bank 32 KiB ROM.

## Production resource baseline

| Resource | Used | Free |
|---|---:|---:|
| ROM0 | 14,616 bytes | 1,768 bytes |
| ROMX | 14,371 bytes | 2,013 bytes |
| WRAM0 | 2,701 bytes | 1,395 bytes |
| HRAM | 10 bytes | 117 bytes |
| OBJ tile indices | 242 of 256 | 14 |
| Shadow OAM entries | 12 reserved | 28 dynamic |

The 12 reserved OAM entries are four Chef entries, four pan entries, three
heart entries, and one key entry. DMG rendering remains limited to ten sprites
on one scanline regardless of free shadow-OAM entries.

## Built gameplay ROMs

- Production
- Room-variant traversal
- Exit animation
- Pan attack animation
- WEINER combat
- BURGER
- PANCAKE
- FRIED_EGG
- DISCO_FRY and gravy
- Treasure Egg, heart, key, and locked exit
- ICE_CUBE fall-through and combat
- HUD, mob selection/population, treasure, and ICE_CUBE parity variants

Every ROM above is 32,768 bytes.

## Verification baseline

- All 1,024 route topologies and 4,096 deterministic generation seeds passed.
- All 15 room masks and traversal contracts passed.
- Room-template, room-variant, seeded-level, furniture, background, wallpaper,
  and runtime mob-selector verification passed.
- All 65,536 dining-room seeds passed composition validation.
- Every seed contained 4–8 mobs, 2–4 Treasure Eggs, and exactly one key-bearing
  egg under the current generation rules.
- `git diff --check` passed.
