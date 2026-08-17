# Project Vision — Brunch Bros

Status: **authoritative** (Phil's stated vision, recorded 2026-08-17)

## Working title

Brunch Bros

## Concept

An original roguelike platformer for the Nintendo Game Boy, mechanically
inspired by the broad structure of *Spelunky* — but not a literal copy of it.
See the copyright/inspiration boundary in `AGENTS.md`.

## Theme

A chef navigating dangerous areas of a diner. Example thematic spaces:
kitchen, prep areas, pantry/storage, dining room, freezer/refrigeration
areas, service areas. These are thematic constraints only — not a request to
lock in detailed content yet.

## What the finished project should demonstrate

- Responsive platform movement
- Jumping and gravity
- Tile collision
- Room or level traversal
- Enemies and hazards
- Items or interactable objects
- Procedural or semi-procedural level construction
- Run-based gameplay
- Multiple diner-themed areas
- Sound and music
- Title/menu/game-over flows
- A complete playable progression
- Compatibility with real Game Boy hardware or a highly accurate emulator
- Reasonable adherence to Game Boy CPU, memory, sprite, tile, and timing limits

## Guiding stance

The project must respect Game Boy hardware rather than pretending it's a
modern engine. When a desired mechanic conflicts with a hardware limit, the
constraint gets explained and Phil chooses among realistic implementations —
behavior is never silently simplified to dodge a constraint.

This is intentionally a more ambitious scope than a typical first GB
project. That's a deliberate choice, to be reached incrementally while
understanding the machinery at each step — not a target to be talked down
from.

## Target hardware & implementation language

- Primarily original Game Boy / DMG.
- Avoid GBC-only features unless explicitly decided otherwise later (would
  be recorded in `docs/DECISIONS.md`).
- Implementation language: RGBDS assembly. No other engine, framework,
  compiler, runtime, or language without discussing it first.

## Dev machine

- MacBook Pro 18,2 (Apple M1 Max, arm64), 64 GB RAM, macOS 26.6.1 (Tahoe).
- No known Homebrew or architecture constraints; current bottles (e.g.
  `arm64_tahoe` RGBDS 1.0.1) install and run natively.

Superseded: the founding prompt originally described a 2015 11-inch
MacBook Air (Intel i5, 8 GB RAM, macOS Monterey 12) as the dev machine. That
machine became prohibitively slow for running LLM CLI agents, so development
moved to the machine above. See the 2026-08-17 "Dev machine retrofit" entry
in `docs/DECISIONS.md` for the full record, and
`notes/2026-08-17-bootstrap-tooling-check.md` (now resolved) for the
verification history.

## Engineering principles

See `AGENTS.md` and the source prompt for the full principle list
(hardware-reality-first, determinism, small milestones, build-and-test
constantly, specs-before-large-features, source-of-truth-in-repo). Restated
briefly:

1. **Hardware reality first** — design around actual constraints; track them
   in `docs/HARDWARE.md`.
2. **Determinism** — prefer deterministic systems; procedural generation
   should use reproducible seeds.
3. **Small milestones** — always have a working ROM; see `docs/ROADMAP.md`.
4. **Build and test constantly** — small changes, verified immediately.
5. **Specs before large features** — see `specs/`.
6. **Source of truth lives in the repo** — not in conversational memory.
