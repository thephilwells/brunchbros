# Biome architecture and bank budget

The production queue is now data-driven and begins:

`PATIO_1 → PATIO_2 → DINING_ROOM_1 → DINING_ROOM_2`

Until Patio assets and templates are authored, both Patio levels use the
Dining Room tile, dressing, room-template, and shared 4×4 generation profiles.
Their encounter profiles are already distinct: Patio 1 uses WEINER, while
Patio 2 uses WEINER and BURGER.

## Budget after the architecture pass

- ROM0: 14,868 bytes used, 1,516 free
- ROMX bank 1: 16,143 bytes used, 241 free
- WRAM0: 2,733 bytes used, 1,363 free
- HRAM: 10 bytes used, 117 free
- OBJ VRAM: one unused tile index
- Shadow OAM: 12 reserved entries and 28 dynamic entries

Bank 1 is frozen except for fixes to code already resident there. New biome
content must not be appended to it.

## MBC5 migration

The cartridge now uses MBC5 without external RAM. ROM0 owns bank switching,
interrupts, the main loop, transitions, and cross-bank entry trampolines.
`GenerateLevelBanked` restores the previously selected bank before returning.
Generation-specific actor trampolines temporarily select bank 1 and restore
bank 2.

- Bank 1 contains the accepted actor/runtime baseline.
- Bank 2 contains shared level-generation code and generated room/template
  data.
- Bank 3 is reserved for Patio tiles, dressing data, and Patio-specific
  templates.
- Later biome banks are assigned only when their reviewed assets exist.

The physical ROM is 64 KiB because Game Boy ROM sizes are powers of two; bank
3 is available in the same expansion.

## Budget after migration

- ROM0: 10,030 bytes used, 6,354 free
- ROMX bank 1: 13,673 bytes used, 2,711 free
- ROMX bank 2: 7,453 bytes used, 8,931 free
- ROMX bank 3: 0 bytes used, 16,384 free
- WRAM0: 2,734 bytes used, 1,362 free
- HRAM: 10 bytes used, 117 free
