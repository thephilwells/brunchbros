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

## ROM banking plan

The first Patio content pass will change the cartridge from ROM-only to MBC5
without external RAM. ROM0 will own bank switching, interrupts, the main loop,
transitions, and cross-bank entry trampolines. A call must enter banked code
through ROM0 and restore the previously selected bank before returning.

- Bank 1 remains the accepted actor/runtime baseline during migration.
- Bank 2 receives shared level-generation code and generated room/template
  data moved out of bank 1.
- Bank 3 receives Patio tiles, dressing data, and Patio-specific templates.
- Later biome banks are assigned only when their reviewed assets exist.

Adding bank 2 makes the physical ROM 64 KiB because Game Boy ROM sizes are
powers of two; bank 3 is therefore available in the same first expansion. No
bank switch or cartridge-header change occurs in this architecture-only pass.
