# Sprite buffer pipeline

Status: **implemented and accepted after hands-on scrolling/animation stress
testing** as of 2026-10-13.

## Frame contract

All sprite producers write to one 160-byte, 256-byte-aligned WRAM shadow OAM
buffer. No gameplay routine writes directly to `$FE00–$FE9F`.

Before waiting for the next VBlank, the runtime:

1. derives `CameraX` and `CameraY` from the current player state;
2. advances visual actor state;
3. composes Chef, pan, HUD, and enemy entries into shadow OAM using that camera.

At the beginning of VBlank, an HRAM-resident routine starts OAM DMA from the
shadow buffer and waits for the transfer to finish. Background streaming and
the matching `SCX`/`SCY` register commit follow the DMA.

This costs 160 bytes of WRAM and one approximately 160-microsecond DMA transfer
per displayed frame. Sprite composition itself is ordinary WRAM work and does
not consume the restricted OAM-access portion of VBlank.

## Slot ownership

| OAM slots | Owner | Maximum entries |
|---|---|---:|
| 0–3 | Chef | 4 |
| 4–7 | Frying pan | 4 |
| 8–10 | Health HUD | 3 |
| 11–26 | Up to four WEINERs or their cloudbursts | 16 |
| 27–30 | BURGER fixture or its cloudburst | 4 |
| 31–39 | Unassigned | 9 |

An inactive composite hides its entries by setting their Y bytes to zero.
Unused slots remain zero after startup. The established ordering preserves
Chef and pan priority over enemies when sprites overlap horizontally.

## Remaining hardware limits

DMA prevents partial or forbidden CPU writes from corrupting OAM; it does not
increase DMG rendering capacity. At most 40 entries exist, and only the first
10 entries encountered on a scanline are rendered. Every new actor therefore
needs both a tile-storage budget and an OAM/per-scanline budget.

The 24-pose WEINER sheet occupies 96 tiles in ROM bank 1, but each live WEINER
or cloudburst uses four OAM entries. Pose count does not increase scanline
cost; population does. The BURGER normally uses two entries and temporarily
uses four while showing the generic cloudburst.
