# Level generation

Status: **authoritative design baseline; implementation pending**.

## Purpose

Generate deterministic 40×32-tile biome levels whose required route is always
traversable with the Chef's baseline abilities. Keep topology, room-template
selection, tile assembly, dressing, and encounter placement independently
validatable.

This specification uses the traversal envelope in
`specs/level-design-rules.md`. Boss arenas are curated modules and do not use
the ordinary 4×4 generator.

## Macro grid

- A level contains 4 columns × 4 rows of 10×8-tile rooms.
- Rooms use row-major indices: `index = row * 4 + column`, from 0 through 15.
- The spawn room is on row 0. The exit room is on row 3.
- The critical route never moves upward and never visits a room twice.
- Room boundaries are structural interfaces, not screen boundaries. The
  160×144 viewport spans more than one 80×64-pixel room.

## Runtime representation

| Field | Size | Meaning |
|---|---:|---|
| `CriticalRouteLength` | 1 byte | Number of occupied entries in the ordered route |
| `CriticalRoute` | 16 bytes | Ordered room indices from spawn through exit |
| `RoomPorts` | 16 bytes | Four low bits describe open room interfaces |
| `RoomTemplates` | 16 bytes | Selected template ID for each grid cell |
| `SpawnRoom` | 1 byte | First critical-route room index |
| `ExitRoom` | 1 byte | Last critical-route room index |

Unused `CriticalRoute` entries contain `$ff`. Port bits are:

| Bit | Value | Port |
|---:|---:|---|
| 0 | `$01` | west |
| 1 | `$02` | east |
| 2 | `$04` | north |
| 3 | `$08` | south |

Critical-route membership and direction come from the ordered route rather
than duplicated room flags. The host-side export uses the same fields with
descriptive JSON names.

## Critical-route construction

1. Choose a seeded start column from 0–3 and append its row-0 room.
2. For each row from 0 through 2, choose a seeded descent column from 0–3.
3. Append every room between the current column and descent column, moving in
   one horizontal direction without reversing. A zero-length run is allowed.
4. Connect the descent room south to the room directly below it, append that
   lower room, and continue on the next row from the same column.
5. On row 3, choose a seeded exit column from 0–3 and append the single
   horizontal run to it. Mark its final room as the exit.
6. Derive reciprocal port bits from every consecutive route pair.

The route therefore contains 4–16 rooms, exactly three southward transitions,
and at most one horizontal run per row. Selecting in-bounds target columns
eliminates out-of-grid retries. No random result may weaken a port, clearance,
or traversal rule.

The five independent column choices—spawn, three descents, and exit—produce
`4^5 = 1,024` possible macro-route topologies. The host validator enumerates
all 1,024 directly, independently of how seeds map onto them.

## Room ports

Room-local coordinates are zero-based within a 10×8 tile template.

- West and east ports are two-tile-high openings at local rows 5–6. The edge
  cell at row 7 remains full-solid support.
- North and south ports are three-tile-wide openings at local columns 4–6.
  North opens row 0; south opens row 7.
- A north-entry room places its first required landing no more than four tiles
  below the departure surface in the room above. Boundary-drop variants may
  use five to eight tiles only under the isolation rules in the traversal spec.
- Every east port has a west port in the adjacent room, and every south port
  has a north port below it. Unpaired ports are invalid.
- Ports cannot face outside the 4×4 grid. All non-port boundary cells remain
  sealed against accidental room-to-room passage.

## Critical room templates

- Each template declares its port mask plus the directed entry and exit ports
  it certifies. Spawn and exit templates declare their special role instead of
  a missing entry or exit port.
- A critical room template guarantees a route from its declared entry to exit
  using only baseline movement and the ordinary/boundary classification in
  `specs/level-design-rules.md`.
- Template selection matches the exact required port mask. It cannot introduce
  an undeclared opening at a room seam.
- The spawn template contains the protected spawn envelope and an ordinary
  route to its outgoing port.
- The exit template connects its incoming port to the protected approach apron
  and doorway using ordinary tolerances.
- Structural templates store semantic cells such as empty, full-solid, and
  one-way. The assembled 40×32 map derives final connectivity tile IDs after
  all neighboring room cells are known.

## Non-critical rooms and optional branches

- The first generator may leave every non-critical room sealed with a zero port
  mask while still filling it with biome-appropriate visual structure.
- A later optional-branch pass may open only reciprocal ports between adjacent
  rooms. It cannot remove or redirect a critical-route connection.
- Every reachable optional component attaches to the critical route at one or
  two rooms. A one-attachment branch must provide a baseline-valid return path;
  a two-attachment branch may rejoin a later critical room.
- Optional directed drops must still lead back to the critical route or forward
  to the exit. Entering an optional branch cannot permanently trap the player.
- Unreachable filler rooms may contain arbitrary internal structure, but their
  interfaces stay sealed and they cannot overlap critical-route reservations.

## Determinism

- Generation accepts a recorded 16-bit seed and a biome identifier.
- The runtime and host-side generator use the same PRNG, draw order, room
  tables, and template IDs. The exact PRNG is selected with implementation.
- Given the same generator version, biome, and seed, both implementations must
  produce identical route descriptors and 1,280 tile bytes.
- A failing seed is always printed and can be regenerated individually.

## Offline validation and inspection

`tools/generate-level-gallery.mjs` will run the host-side generator without an
emulator. Its intended interface is:

```sh
node tools/generate-level-gallery.mjs \
  --biome dining_room --seed 0 --count 256 \
  --out build/level-gallery
```

The generated directory contains:

- `index.html`: a contact-sheet gallery with seed labels, validation status,
  an art thumbnail, and a 4×4 route/port overlay for every level.
- `levels/<seed>.tmx`: the complete map referencing the biome TSX, directly
  inspectable in Tiled.
- `levels/<seed>.json`: seed, route order, room ports, template IDs, transition
  classifications, validation results, and aggregate counts.
- `summary.json`: batch failure list and distributions for route length, room
  masks, template usage, boundary transitions, spawn column, exit column, and
  unique macro topologies covered.

The gallery is generated output and is not committed. A selected failing seed
may become a committed regression fixture.

Every generated level is checked for:

1. Correct dimensions, valid tile IDs, and deterministic regeneration.
2. A unique top-row spawn and bottom-row exit with their protected clearances.
3. An ordered, non-repeating, orthogonally adjacent critical route.
4. Exactly three downward route edges and no upward route edge.
5. Reciprocal ports, sealed outer boundaries, and matching template metadata.
6. Valid ordinary/boundary sequencing and no forbidden combination of limits.
7. Tile-level spawn-to-exit reachability on the assembled collision map.
8. Unobstructed reserved cells after dressing and object-placement passes.

The batch command exits nonzero if any seed fails, while retaining its report
and inspectable map. Exhaust all 1,024 macro topologies in the topology test;
run at least 256 consecutive seeds during generator work and 4,096 seeds before
accepting the first procedural-generation milestone.

## Runtime parity

Offline validation does not replace testing the assembly generator. A fixed
set of golden seeds will compare the host output byte-for-byte with `LevelMap`
dumped from the ROM. SameBoy review then samples ordinary layouts, longest
routes, every port-turn shape, minimum and maximum route lengths, and every
boundary-transition type. Visual galleries find breadth problems; emulator
playtests remain authoritative for movement feel and hardware timing.

## Initial non-goals

- Optional branches, hazards, enemies, loot, and furniture placement.
- Streaming or generating rooms during play; the complete current biome is
  generated before control begins.
- Boss arenas or the Deep Freezer victory room.
- Proving arbitrary player input sequences. The validator proves the declared
  route under the accepted traversal model and retains SameBoy playtesting.
