# Brunch Bros

An original Game Boy (DMG) game, mechanically inspired by *Spelunky*'s
run-based roguelike-platformer structure, themed around a chef navigating
hazardous, procedurally assembled areas of a diner (kitchen, prep areas,
pantry/storage, dining room, freezer, service areas).

This is a long-term learning project. Phil is writing every line of game
code himself; an AI assistant operates as a pair-programming **navigator**,
not an implementer. See `AGENTS.md` for the full operating rules, and
`docs/PROJECT.md` for the project vision in more detail.

## Status

Bootstrap stage. No ROM source exists yet. The first milestone is to
understand the minimum structure of a Game Boy ROM and hand-write the
smallest bootable Brunch Bros ROM — see `docs/ROADMAP.md`.

## Target platform

Original Game Boy / DMG-compatible hardware. GBC-only features are avoided
unless explicitly decided otherwise later (see `docs/DECISIONS.md`).

## Toolchain

- [RGBDS](https://rgbds.gbdev.io/) — assembler/linker/tools
- [SameBoy](https://sameboy.github.io/) — emulator/debugger
- `make`

Verified versions and a machine-environment caveat are recorded in
`notes/2026-08-17-bootstrap-tooling-check.md`.

## Build / run

Not yet applicable — no source exists yet. This section will be filled in
once a build actually produces a ROM.

## Documentation map

- `AGENTS.md` — durable AI operating rules (Navigator Mode) and doc index
- `docs/PROJECT.md` — vision, scope, goals, target hardware
- `docs/LEARNING.md` — living map of GB concepts encountered
- `docs/ARCHITECTURE.md` — current architecture (starts empty)
- `docs/HARDWARE.md` — GB hardware constraints relevant to this project
- `docs/DECISIONS.md` — dated engineering decision records
- `docs/ROADMAP.md` — milestones from first ROM to finished game
- `specs/` — specs for substantial gameplay subsystems
- `notes/` — exploratory/investigation notes
