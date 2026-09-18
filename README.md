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

Past bootstrap — a real, playable-so-far ROM exists (`src/main.asm`). Done:
input, a 16×16 animated player sprite (idle/walk cycles, horizontal flip),
tile-based wall collision, jumping/gravity with squash-stretch-settle
animation, and scrolling camera follow (both axes) over a widened world.
The tileset milestone has begun with a 17-tile structural pilot and a Tiled
fixture map. See `docs/ROADMAP.md` for the full milestone list and
`docs/LEARNING.md` for concepts covered so far.

## Target platform

Original Game Boy / DMG-compatible hardware. GBC-only features are avoided
unless explicitly decided otherwise later (see `docs/DECISIONS.md`).

## Toolchain

- [RGBDS](https://rgbds.gbdev.io/) — assembler/linker/tools
- [SameBoy](https://sameboy.github.io/) — emulator/debugger
- `make`
- Node.js — generates the structural pilot PNG, TSX, and fixture map
- [Tiled](https://www.mapeditor.org/) — opens the pilot tileset and fixture map

Verified on the current dev machine (see `docs/DECISIONS.md`, "Dev machine
retrofit"): RGBDS 1.0.1, GNU Make 3.81, git 2.50.1. SameBoy is installed
(`~/Downloads/SameBoy.app`) but not yet on `PATH` or in `/Applications`.
Verification history: `notes/2026-08-17-bootstrap-tooling-check.md`.

## Build / run

```sh
node tools/generate-structural-pilot.mjs
rgbgfx -c dmg=E4 -o build/structural_pilot.2bpp gfx/structural_pilot.png
for f in chef_idle0 chef_idle1 chef_walk0 chef_walk1 chef_walk2 chef_walk3 chef_walk4 chef_walk5 chef_jump chef_ascent chef_crouch; do
  rgbgfx -c dmg=E4 -o build/$f.2bpp gfx/$f.png
done
rgbasm -o build/main.o src/main.asm
rgblink -o build/brunchbros.gb -m build/main.map -n build/main.sym build/main.o
rgbfix -v -p 0xFF build/brunchbros.gb
```

Produces `build/brunchbros.gb`. Open it in SameBoy to run. The default VS
Code build task runs the same steps. Open `gfx/structural_fixture.tmx` in
Tiled to inspect all 16 structural variants; its external tileset is
`gfx/structural_pilot.tsx`. The pilot uses the first 17 IDs of a 128-slot
atlas. The remaining slots are reserved until later art groups are reviewed.

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
