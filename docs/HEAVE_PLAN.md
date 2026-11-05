# HEAVE implementation plan

Status: accepted for staged implementation on 2026-11-05.

`docs/HEAVE.md` is the feature brief. This plan records the implementation
architecture, initial calibration rules, sequencing, and regression gates.

## Architecture

Extend the existing Treasure Egg actor. Do not introduce a second egg object
system. Add carried and thrown states to the Treasure Egg state machine and
expand each record with the motion and impact state needed by a toss. A global
held-egg index identifies the one egg Chef is carrying.

Input precedence is:

1. While carrying, a fresh B press tosses the egg.
2. Otherwise, Down+B starts a lift attempt.
3. Otherwise, a fresh B press starts the frying-pan attack.

Down+A passage remains unchanged.

Prototype Chef's carrying poses as arm overlays using the OAM slots reserved
for the inactive pan. The carried egg continues using its existing Treasure Egg
tiles and OAM entries. Validate this approach with reviewable composites before
committing to it because OBJ VRAM currently has only 14 unused tile slots.

For mob impacts, give each existing species a damage-by-amount entry point. Pan
attacks pass one damage unit; thrown eggs pass two. Preserve each species'
existing flash, knockback, stun, and cloudburst behavior.

## Initial interaction rules

- Both uncracked and cracked Treasure Eggs are liftable.
- A lift candidate must overlap Chef's body. Ties select the lowest egg record
  index for deterministic behavior.
- A lift takes 12 frames: six reaching forward and six raising the egg. A miss
  plays both frames before returning Chef to the normal pose.
- Movement and gravity continue during lift and toss, matching pan behavior.
- Carried eggs ignore terrain so Chef can pass through Chef-sized openings.
- Chef may walk, jump, and use Down+A while carrying.
- Chef cannot swing the pan or grab ledges while carrying.
- B tosses the carried egg in Chef's facing direction.
- The initial toss arc targets approximately 40 pixels on level ground.
- Thrown eggs collide with solid walls and ceilings. They land on solid terrain
  and on one-way platforms only while descending.
- A wall stops horizontal motion and lets the egg fall.
- The first mob struck takes two damage units. The egg then loses horizontal
  momentum, cannot damage another mob during that toss, and falls.
- Mob contact does not damage the egg. Terrain landing supplies the egg's one
  damage event: an uncracked egg becomes cracked; a cracked egg bursts and
  reveals its contents.
- Ordinary Chef damage does not drop a carried egg. Lethal damage and level
  transitions clear it.

These are calibration defaults. Hands-on fixture testing may revise timing,
range, collision bounds, and interruption behavior.

## Implementation sequence

### 1. Checkpoint and budget guard

- Begin from a committed production build.
- Record ROM0, ROMX, WRAM, OBJ tile, and OAM usage.
- Build production and all existing focused fixtures without behavior changes.

### 2. Reviewable HEAVE art

- Draw the reach-forward arm used by lift and toss.
- Draw raised carrying-arm overlays for idle, movement, and jumping.
- Produce a review sheet showing each overlay composed with the existing Chef
  frames in both directions.
- Stop and revise the sprite strategy if the overlay cannot convincingly conceal
  the original arm within the available tile and OAM budgets.

### 3. Lift-only fixture

- Mount one uncracked egg, one cracked egg, and an empty lift position.
- Implement the two-frame lift animation and animated miss.
- Implement deterministic candidate selection and carried positioning.
- Confirm ordinary B attacks and Down+A passage still work.

### 4. Carry traversal fixture

- Exercise idle, walking, jumping, falling, and camera scrolling.
- Exercise narrow Chef-sized openings and Down+A through one-way platforms.
- Confirm the carried egg ignores terrain.
- Confirm pan attacks and ledge grabs remain disabled while carrying.

### 5. Throw and landing fixture

- Calibrate the toss to approximately five tiles on level ground.
- Exercise solid floors, walls, ceilings, world edges, and descending one-way
  landings.
- Verify uncracked-to-cracked and cracked-to-cloudburst transitions.
- Verify empty, heart, and key contents remain attached to the egg and reveal
  only after a cracked landing.

### 6. Mob-impact fixture

- Exercise WEINER, BURGER, PANCAKE, FRIED_EGG, DISCO_FRY, and ICE_CUBE.
- Test full-health, nonlethal, and lethal two-damage impacts.
- Confirm one mob can be damaged per toss.
- Confirm each species retains its accepted knockback, flash, stun, and
  cloudburst behavior.

### 7. Production integration

- Keep existing deterministic Treasure Egg placement and contents selection.
- Run host and RGBDS placement parity checks.
- Run exhaustive dining-room composition validation.
- Build production and all focused fixtures.
- Recheck normal pan attacks, Down+A, ledge grabs without a carried egg, heart
  and key collection, locked exits, death, Game Over, level transitions, sprite
  cleanup, camera scrolling, and crowded-room performance.
- Complete a manual production playtest across both Dining Room level kinds.

## Regression matrix

| Area | Required checks |
|---|---|
| Input | B attack, Down+B hit, Down+B miss, carried B toss, Down+A passage, A jump |
| Chef state | Idle, walk, jump, fall, knockback, invulnerability, death, exit |
| Egg state | Uncracked, cracked, carried, thrown, burst, heart, key, empty |
| Terrain | Solid floor, one-way platform, wall, ceiling, narrow opening, world edge |
| Combat | Every mob, one target per toss, nonlethal and lethal two-damage hits |
| Rendering | Facing both ways, camera movement, flicker, OAM cleanup, scanline crowding |
| Generation | Fixed-seed parity, all-seed validation, unchanged treasure guarantees |
| Performance | Carrying, throwing, crowded rooms, cloudbursts, simultaneous actors |

## Current budget baseline

The production map at planning time reports:

- ROM0: 14,608 bytes used, 1,776 free
- ROMX: 14,379 bytes used, 2,005 free
- WRAM0: 2,701 bytes used, 1,395 free
- OBJ VRAM: 14 unused tile indices

The tile budget is the first implementation constraint. Do not begin full-body
carrying-frame production until the arm-overlay review establishes whether the
compact approach is visually acceptable.
