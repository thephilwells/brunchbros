# Brunch Bros

An original Game Boy (DMG) game, mechanically inspired by *Spelunky*'s
run-based roguelike-platformer structure, themed around a chef navigating
hazardous, procedurally assembled areas of a diner (kitchen, prep areas,
pantry/storage, dining room, freezer, service areas).

This is a long-term learning project. Phil reviews and approves changes in
small steps while an AI assistant may implement them. See `AGENTS.md` for
the full operating rules and `docs/PROJECT.md` for the project vision.

## Status

Past bootstrap — a real, playable-so-far ROM exists (`src/main.asm`). Done:
input, a 16×16 animated player sprite (idle/walk cycles, horizontal flip),
tile-based wall collision, jumping/gravity with squash-stretch-settle
animation, and scrolling camera follow (both axes) over a widened world.
The tileset milestone now has a 17-tile structural pilot plus shared rear
surfaces, passable dining-room wall art, a shared descent doorway, a one-way
platform test strip, and a one-way dining table, chair, booth, and counter
in a Tiled map. See
`docs/ROADMAP.md` for the full milestone list and `docs/LEARNING.md` for
concepts covered so far.

## Target platform

Original Game Boy / DMG-compatible hardware. GBC-only features are avoided
unless explicitly decided otherwise later (see `docs/DECISIONS.md`).

## Toolchain

- [RGBDS](https://rgbds.gbdev.io/) — assembler/linker/tools
- [SameBoy](https://sameboy.github.io/) — emulator/debugger
- `make`
- Node.js — generates the structural pilot and dining-room assets
- [Tiled](https://www.mapeditor.org/) — opens the tilesets and fixture maps

Verified on the current dev machine (see `docs/DECISIONS.md`, "Dev machine
retrofit"): RGBDS 1.0.1, GNU Make 3.81, git 2.50.1. SameBoy, Tiled, and
Aseprite are installed in `/Applications`. Verification history:
`notes/2026-08-17-bootstrap-tooling-check.md`.

## Build / run

```sh
node tools/generate-structural-pilot.mjs
node tools/generate-dining-room.mjs
node tools/generate-room-template-fixture.mjs
node tools/generate-room-template-playtest.mjs
node tools/generate-seeded-level.mjs --seed 0
node tools/generate-room-variant-playtest.mjs
rgbgfx -c dmg=E4 -o build/dining_room.2bpp gfx/dining_room.png
node tools/verify-dining-room.mjs
node tools/verify-room-templates.mjs
node tools/verify-room-template-playtest.mjs
node tools/verify-seeded-level.mjs
node tools/verify-room-variant-playtest.mjs
for f in chef_idle0 chef_idle1 chef_walk0 chef_walk1 chef_walk2 chef_walk3 chef_walk4 chef_walk5 chef_jump chef_ascent chef_crouch chef_ledge; do
  rgbgfx -c dmg=E4 -o build/$f.2bpp gfx/$f.png
done
rgbasm -o build/main.o src/main.asm
rgblink -o build/brunchbros.gb -m build/main.map -n build/main.sym build/main.o
rgbfix -v -p 0xFF build/brunchbros.gb
```

Produces `build/brunchbros.gb`. Open it in SameBoy to run. The default VS
Code build task runs the same steps. Open `gfx/dining_room_fixture.tmx` in
Tiled to inspect the current dining-room sheet. Its external tileset is
`gfx/dining_room.tsx`. The structural test remains in
`gfx/structural_fixture.tmx` for inspecting all 16 solid masks.

The host-side level generator can verify every macro-route topology and render
a 256-seed inspection gallery without launching the ROM:

```sh
node tools/verify-level-generation.mjs
node tools/generate-level-gallery.mjs
open build/level-gallery/index.html
```

The gallery shows seeded levels assembled from authored room templates. Its TMX
files expose the critical route, room ports, spawn, and exit in Tiled.

The semantic room templates can be regenerated and checked separately:

```sh
node tools/generate-room-template-fixture.mjs
node tools/verify-room-templates.mjs
node tools/generate-room-template-playtest.mjs
node tools/verify-room-template-playtest.mjs
```

Open `gfx/room_template_fixture.tmx` in Tiled to inspect all 15 nonzero port
masks. Their source is `data/room-templates/dining-room.json`.

The default ROM temporarily uses `gfx/room_variant_playtest.tmx` to review a
paired wide seam and a required ledge catch. Seed 0 remains available in
`gfx/seeded_level.tmx` and has been accepted in SameBoy.

## Documentation map

- `AGENTS.md` — durable AI operating rules and doc index
- `docs/PROJECT.md` — vision, scope, goals, target hardware
- `docs/LEARNING.md` — living map of GB concepts encountered
- `docs/ARCHITECTURE.md` — current architecture (starts empty)
- `docs/HARDWARE.md` — GB hardware constraints relevant to this project
- `docs/DECISIONS.md` — dated engineering decision records
- `docs/ROADMAP.md` — milestones from first ROM to finished game
- `specs/` — specs for substantial gameplay subsystems
- `notes/` — exploratory/investigation notes
