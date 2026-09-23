# Specs

Specifications for substantial gameplay subsystems, written *before*
implementing them, per the "specs before large features" principle in
`AGENTS.md` / `docs/PROJECT.md`.

Each spec should describe observable behavior more than implementation
details (unless a specific architectural requirement matters), and cover:
purpose, requirements, constraints, acceptance criteria, non-goals, and
unresolved questions.

Current subsystem specifications:

- `background-assets.md` — environment-art and import contract.
- `background-tile-manifest.md` — tile IDs and biome asset vocabulary.
- `level-design-rules.md` — accepted traversal and clearance envelope.
- `level-generation.md` — 4×4 topology, connectivity, determinism, and
  offline-validation contract.
