# Debugging prompt: production mobs appear inside solid terrain

**2026-10-20 update:** A missing zero-flag test in `FindBestMobRoom` has been
identified and reproduced against the compiled selector. Start with
[the root-cause evidence and remediation handoff](../notes/2026-10-20-mob-wall-clipping-root-cause.md).
The investigation prompt below is historical context; its earlier hypotheses
should not supersede the confirmed selector defect.

Work in `/Users/phil/github/brunchbros` and diagnose the remaining production
mob-placement or locomotion bug. Do not discard or overwrite existing
uncommitted changes. Do not commit unless asked.

## Objective

In some procedurally generated production levels, a BURGER or WEINER is visibly
drawn inside opaque wall terrain. Determine whether the invalid position exists
at creation time or develops during offscreen simulation, identify the exact
cause, implement the smallest correct fix shared by production behavior, and
verify it against many deterministic seeds.

Do not assume this is viewport clipping. Rendering was changed to require the
entire 16-pixel-wide mob to be inside the viewport, but the defect remains with
the complete sprite visibly embedded in terrain.

## Manual reproduction

1. Build and open `build/brunchbros.gb` in SameBoy.
2. Reset the game.
3. Press Start to generate and load a level.
4. Capture the screen and inspect its edges and visible rooms for BURGER or
   WEINER sprites intersecting dark opaque wall tiles.
5. Repeat reset, Start, and inspection. The problem occurs in only some levels.

For automation, always overwrite `/private/tmp/brunchbros-screen.png` rather
than inventing new screenshot filenames. `osascript` commands targeting
SameBoy or its debugger and `screencapture` are approved for this project.

The latest report showed a fully visible mob overlapping a vertical wall, so a
simple partially-offscreen OBJ explanation is insufficient. Both mob types
have been observed in bad positions.

## Deterministic reproduction opportunities

The ordinary title screen derives a seed from timing, which makes the manual
flow nondeterministic. Prefer one of these approaches:

- Record `SelectedSeed` from SameBoy memory when a bad level appears, rebuild a
  fixed-seed parity ROM, and reproduce that exact level.
- Generate fixed seeds with `node tools/generate-seeded-level.mjs --seed N`,
  assemble with `FURNITURE_PARITY_TEST=1`, and inspect the resulting runtime mob
  records immediately after `PlaceDiningRoomMobs`.
- Add a temporary debugger breakpoint immediately after `GenerateLevel` and
  compare each runtime mob rectangle against `LevelMap` and `CollisionTypes`
  before the first call to `AdvanceWeiners` or `AdvanceBurgers`.
- Build a harness that iterates fixed seeds, reads the runtime mob records, and
  fails if any active mob body cell has full-solid collision. A second check
  after simulated frames would distinguish creation defects from locomotion
  defects more reliably than screenshots.

Host-side exhaustive validation currently passes all 65,536 seeds, but that
does not prove that RGBDS runtime placement matches host placement or that mobs
remain valid after movement.

## Relevant implementation

- Runtime generation and selection:
  - `src/level_generation.asm:3073` (`PlaceDiningRoomMobs`)
  - `src/level_generation.asm:3305` (`IsMobCandidate`)
  - `src/level_generation.asm:3382` (`ResolveWeinerCandidateDirection`)
  - `src/level_generation.asm:3660` (`CreateSelectedWeiner`)
  - `src/level_generation.asm:3693` (`CreateSelectedBurger`)
- Runtime creation, movement, and rendering:
  - `src/main.asm:1890` (`CreateWeinerAtTile`)
  - `src/main.asm:2036` (`AdvanceWeinerAnimation`)
  - `src/main.asm:2117` (`AdvanceWeinerTurn`)
  - `src/main.asm:2733` (`UpdateWeinerSprite`)
  - `src/main.asm:2977` (`CreateBurgerAtTile`)
  - `src/main.asm:3132` (`AdvanceBurgerAirborne`)
  - `src/main.asm:3693` (`UpdateBurgerSprite`)
  - `src/main.asm:4198` (`IsWall`)
  - `src/main.asm:4203` (`IsSupport`)
- Host composition:
  - `tools/lib/dining-room-composition.mjs:376` (`mobCandidates`)
  - `tools/lib/dining-room-composition.mjs:413` (`mobSelections`)
- Fixed-seed support and existing checks:
  - `tools/generate-seeded-level.mjs`
  - `tools/verify-dining-room-composition.mjs`
  - `src/level_generation.asm:3807` (`VerifyMobParity`)

Coordinate conventions matter:

- WEINER uses a 16×16 top-left world anchor in `WeinerX`, `WeinerY`.
- BURGER uses a 16×8 left/bottom-baseline anchor: `BurgerX` is its left edge
  and `BurgerY` is its baseline. Its visible/collision body occupies roughly
  `BurgerY - 7` through `BurgerY`.
- Level dimensions are 40×32 tiles. Horizontal world coordinates are 16-bit;
  vertical coordinates are 8-bit.
- All mobs advance globally even while outside the current viewport.

## Changes already attempted

These changes are present in the working tree and did not eliminate the bug:

1. Host and runtime spawn candidates reject local room-edge anchors and require
   an empty tile immediately to both horizontal sides of the body.
2. WEINER initial placement was restricted to floors and ceilings. It may still
   crawl onto walls during simulation.
3. BURGER's spawn Y was restored to its bottom-baseline convention.
4. BURGER and WEINER rendering now hides horizontally partial sprites, ruling
   out the earlier viewport-peeking artifact.
5. BURGER airborne movement was reordered to resolve vertical motion before
   its horizontal step, with landing support rechecked afterward. This was
   intended to prevent diagonal corner penetration, but the reported defect
   still occurs.

Do not repeat these as conclusions without testing them. They may be incomplete
or wrong and should be revised if evidence points elsewhere.

## Candidate causes to investigate

At minimum, test these independently:

1. **Runtime placement divergence.** `IsMobCandidate`, candidate ordinal
   selection, room-to-world conversion, or record creation may produce a
   different or invalid coordinate despite valid host JSON.
2. **Record/state corruption.** Multi-mob record copy sizes, generation scratch
   memory, OAM bookkeeping, or subsequent actor loops may overwrite X, Y,
   direction, or state. Check all records immediately after generation and
   again after each actor update.
3. **Locomotion corner transitions.** BURGER axis resolution or WEINER
   concave/convex snap turns may place a body into solid cells. Validate the
   complete body after every movement or turn, not only the forward probes.
4. **Collision sampling mismatch.** End-point probes may miss terrain crossed
   between poses or may use an anchor/bounds convention different from the
   renderer. Inspect tile-boundary cases and 16-bit X carry/borrow behavior.
5. **Bad support interpretation.** One-way support, full-solid support, or
   furniture collision tiles may be classified correctly at spawn but allow an
   actor to enter an impossible idle state later.

The screenshot evidence now makes initial placement, record corruption, and
post-spawn locomotion all plausible. Establish the first frame on which a valid
mob rectangle becomes invalid before changing more geometry rules.

## Required verification

- Preserve the guarantee of exactly two WEINERs and two BURGERs per dining-room
  level.
- Run `node tools/verify-dining-room-composition.mjs` across all 65,536 seeds.
- Run `node tools/verify-level-generation.mjs` and
  `node tools/verify-seeded-level.mjs`.
- Build both production and the focused BURGER fixture with RGBDS.
- Add a deterministic regression that fails on a mob body overlapping a
  full-solid tile at creation and, if locomotion caused the bug, at the movement
  transition that previously failed.
- Reopen production in SameBoy for manual review.

Keep any diagnostic instrumentation narrowly scoped and remove it unless it is
valuable as a permanent invariant or regression check.
