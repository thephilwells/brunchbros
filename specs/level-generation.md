# Level generation

Status: **macro-route generator, structural gallery, semantic template format,
and three representative room templates implemented; remaining templates,
tile-level validation, and runtime parity pending**.

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

- Each baseline template declares one exact nonzero port mask and makes every
  declared port mutually reachable using baseline movement. It can therefore
  serve either a critical-route room or an optional branch without separate
  directed entry/exit variants.
- Template selection matches the exact required port mask. It cannot introduce
  an undeclared opening at a room seam.
- The spawn template contains the protected spawn envelope and an ordinary
  route to its outgoing port.
- The exit template connects its incoming port to the protected approach apron
  and doorway using ordinary tolerances.
- Structural templates store semantic cells such as empty, full-solid, and
  one-way. The assembled 40×32 map derives final connectivity tile IDs after
  all neighboring room cells are known.

### Semantic source format

`data/room-templates/dining-room.json` is the authoritative source for the
initial template library. Format version 1 fixes every template at 10×8 cells
and uses three symbols:

| Symbol | Meaning | Collision |
|---|---|---|
| `.` | Empty structural space | Empty |
| `#` | Full structural block | Solid |
| `=` | Jump-through platform | One-way from above |

Each template has a stable string ID, a numeric port mask using the shared
W/E/N/S bits, and eight ten-character rows. The source validator requires
declared boundary openings at the fixed port cells and full-solid cells at
every other boundary position. Rendering derives IDs 1–16 from neighboring
`#` cells, maps `.` to the dining-room rear tile, and maps `=` to the existing
one-way pilot tile.

The initial review fixture contains W|E, N|S, and N|E ordinary templates.
Static validation currently proves dimensions, symbols, exact boundary ports,
and tile conversion. Mutual port reachability remains provisional until the
tile-level traversal validator is implemented and the vertical shapes are
reviewed in play.

## Non-critical rooms and optional branches

- Every room belongs to the spawn room's connected component. Inaccessible
  filler rooms are invalid.
- After constructing the critical route, the generator repeatedly chooses a
  seeded edge from any connected room to an unconnected orthogonal neighbor.
  It opens reciprocal ports and adds that room to the connected set until all
  16 rooms are included.
- The initial branch pass creates no loops: each optional subtree attaches to
  the already-connected graph once. A later pass may add reciprocal loop edges,
  but cannot remove or redirect a critical-route connection.
- Optional branches provide a baseline-valid return path. Dead ends are
  permitted; permanent traps are not.
- Optional directed drops must still lead back to the critical route or forward
  to the exit. Entering an optional branch cannot permanently trap the player.

## Determinism

- Generation accepts a recorded 16-bit seed and a biome identifier.
- The runtime and host-side generator use the same PRNG, draw order, room
  tables, and template IDs. The PRNG is xorshift16 with left/right/left shifts
  of 7/9/8 bits. Seed zero is normalized to `$ace1`; generation draws five
  values and uses each value's low two bits as one route column.
- Given the same generator version, biome, and seed, both implementations must
  produce identical route descriptors and 1,280 tile bytes.
- A failing seed is always printed and can be regenerated individually.

## Offline validation and inspection

`tools/generate-level-gallery.mjs` runs the host-side generator without an
emulator. Its interface is:

```sh
node tools/generate-level-gallery.mjs \
  --biome dining_room --seed 0 --count 256 \
  --out build/level-gallery
```

The generated directory contains:

- `index.html`: a contact-sheet gallery with seed labels, validation status,
  a structural thumbnail, and a 4×4 route overlay for every level.
- `levels/<seed>.tmx`: the complete map referencing the biome TSX, directly
  inspectable in Tiled.
- `levels/<seed>.json`: seed, selected columns, route order, room ports,
  provisional template IDs, scaffold tiles, and validation results.
- `summary.json`: batch failure list and distributions for route length, room
  masks, spawn column, exit column, and unique macro topologies covered.

The gallery is generated output and is not committed. A selected failing seed
may become a committed regression fixture.

The implemented structural phase checks every generated level for:

1. Correct dimensions, valid tile IDs, and deterministic regeneration.
2. A top-row spawn and bottom-row exit.
3. An ordered, non-repeating, orthogonally adjacent critical route.
4. Exactly three downward route edges and no upward route edge.
5. Reciprocal ports, sealed outer boundaries, all 16 rooms connected to spawn,
   and exactly 15 room-to-room connections in the initial branch tree.

The provisional `RoomTemplates` values encode each critical room's entry/exit
pair for gallery inspection; they do not yet identify authored templates. Once
those templates exist, validation also checks their metadata, protected
spawn/exit clearances, ordinary/boundary sequencing, transition limits,
tile-level spawn-to-exit reachability, and reserved cells after dressing and
object placement.

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

- Optional-branch content, hazards, enemies, loot, and furniture placement.
- Streaming or generating rooms during play; the complete current biome is
  generated before control begins.
- Boss arenas or the Deep Freezer victory room.
- Proving arbitrary player input sequences. The validator proves the declared
  route under the accepted traversal model and retains SameBoy playtesting.
