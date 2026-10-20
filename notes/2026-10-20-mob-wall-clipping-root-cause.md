# Confirmed spawn-selector defect and remediation handoff

## Finding

The runtime population-minimum rewrite removed the instruction that tested a
room's candidate count. `FindBestMobRoom` now branches on a stale zero flag.
It can choose a room with **zero legal spawn positions**, exhaust its candidate
search, and create a mob from the loop's final coordinates, inside a wall.
The same path creates BURGERs and WEINERs.

This defect exists before any movement or drawing. The earlier viewport and
movement explanations were unproven and did not address it.

No gameplay source or ROM was changed during this investigation. The existing
uncommitted implementation and attempted fixes remain for the implementing
agent to review.

## Exact cause

At `src/level_generation.asm:3170`, in `FindBestMobRoom`:

```asm
    ld a, [hl]
    jr z, .nextRoom
```

`LD` does not change flags. `ADD HL,DE` just above it also preserves Z.
On the first iteration, Z is still set by the routine's initial `xor a`, so
room 0 is skipped even if eligible. On iterations 1–15, Z is clear from the
previous iteration's `cp a, 16`, so the branch fails to skip empty rooms.
The selector effectively ranks rooms 1–15 without filtering candidate counts.

The working diff identifies the regression:

```diff
    ld a, [hl]
-   bit 7, a
-   jr nz, .nextRoom
-   and a, $7f
    jr z, .nextRoom
```

Removing the old selected-room bit was appropriate for repeated selection.
Removing its only zero test was not.

## Failure chain

1. `PlaceMobType` builds a candidate-count table, correctly assigning zero to
   rooms that cannot be used.
2. `FindBestMobRoom` selects an empty room anyway and sets `MobBestFound = 1`.
3. `PlaceMobType` passes its zero count to `MobResultModulo`. There is no valid
   candidate ordinal for this room.
4. `FindMobCandidate` (`src/level_generation.asm:3268`) searches the room and
   falls through its terminal `ret` without finding anything.
5. The exhausted loop leaves `MobLocalX = 9`, with `MobLocalY = 7` for BURGER
   or `6` for WEINER.
6. `PlaceMobType` unconditionally calls `MarkMobCandidateOccupied` and creates
   the actor at that invalid location. Local X=9 is the last room column;
   a two-tile body occupies the side boundary and extends into the next room.

The invalid occupancy mark also spans that boundary. The first invalid write
therefore affects subsequent candidate selection as well.

## Reproduction evidence

A small diagnostic executes the **actual compiled `FindBestMobRoom`
instructions** from `build/brunchbros.gb`, using symbol addresses from
`build/main.sym`. The two salt/mix calls are supplied by their deterministic
host equivalents. It is an isolated instruction test, not a complete emulator
or a full production run.

Run it in this workspace:

```sh
node /private/tmp/brunchbros-selector-diagnosis.mjs
```

The diagnostic file is temporary; turn the important cases into permanent
runtime regression tests during remediation.

| Input, seed 1 | Existing machine code | With zero test modeled |
|---|---|---|
| Only room 1 has one candidate | Selects room 5, whose count is zero | Selects room 1 |
| Every room has zero candidates | Reports a room found | Reports no room found |

There is also a concrete generated-map reproduction to use in SameBoy:

- Generate host seed **1**. Room **5** has zero mob candidates.
- The broken selector's first BURGER selection ranks room 5 lowest, score
  **204**, using selection salt **44257**.
- Room 5 has N/S ports. The reservation checks reject local X=2–7 throughout
  the candidate rows; the side-clearance/edge checks reject the other columns.
  The runtime cannot find a legal candidate there either.
- Exhausting the BURGER search leaves local `(9, 7)`, giving world tile
  `(19, 15)`, `BurgerX = 152`, `BurgerY = 128`.
- Seed 1 has solid tile IDs **8** and **16** at `(19,15)` and `(20,15)`.
  That is exactly the side-wall embedding pattern in the screenshots.

The seed-1 map and score above were calculated with the host generator and
traced through the runtime code. Verify the corresponding runtime records in
SameBoy before the first movement update as part of remediation.

## Why previous verification passed

The host selects only rooms whose candidate arrays are nonempty. It does not
share this CPU-flag error. Running all 65,536 host seeds cannot detect it.

`VerifyMobParity` at `src/level_generation.asm:3807` now checks only mob counts.
It no longer compares positions. Four records created at invalid coordinates
still satisfy that check. A test named parity must check actual placement data
or be clearly described as a count test.

## Instructions for the implementing agent

Implement this in the existing checkout, preserving unrelated uncommitted work.
Do not commit or push.

1. Insert the missing test immediately after the count load in
   `FindBestMobRoom`:

   ```asm
       ld a, [hl]
       and a
       jr z, .nextRoom
   ```

   Do not replace this with altered sprite offsets, wider spawn exclusions,
   or collision tuning. The defect is an invalid room being selected.

2. Restore meaningful runtime placement validation. Compare every created
   record's initial X/Y with the generated host fixture, and check WEINER
   direction as well as counts. Extend the fixture data if needed; the current
   binary stores count and X/Y only. If parity still differs, diagnose the
   first discrepancy instead of weakening the assertion.

3. Add a regression that executes the selector, rather than merely checking
   the assembly text or the host implementation:
   - only room 0 eligible → room 0 selected;
   - only room 1 eligible → room 1 selected, even when room 5 scores lower;
   - all counts zero → `MobBestFound = 0`;
   - every selected room must have a nonzero candidate count.
   Include a seed-1 initial-placement check before any actor movement.

4. Consider making `FindMobCandidate` return an explicit success result and
   asserting success before marking or creating a mob in a diagnostic build.
   Exhaustion has been observed, so this is a relevant invariant. Do not
   silently skip required mobs and claim the two-per-type requirement passed.
   The one-instruction fix should make this path unreachable when counts and
   enumeration agree.

5. Verify production and BURGER-fixture builds, representative runtime seeds
   0, 1, 5, 7, 15, 19, 77, 4660, and 65535, then the existing host generator
   and composition checks. Inspect spawned records before movement; afterward,
   run normal gameplay to distinguish any remaining locomotion issues.

6. Review the earlier attempted fixes separately. Hiding all partially visible
   mobs adds popping at viewport edges and has no causal relationship to this
   spawn bug. The extra spawn clearances and reordered BURGER movement also
   have not been shown necessary for this defect. Avoid silently rolling back
   unrelated accepted behavior; propose cleanup based on evidence.

7. Restore checked-in seed-0 generated fixtures after testing other seeds and
   reopen the rebuilt production ROM in SameBoy for Phil's review.

## Completion criteria

The runtime selector never chooses a zero-candidate room; seed 1 no longer
creates a BURGER at `(152,128)` in the side wall; actual initial mob placements
match the host expectation; both required pairs still spawn; and reset/Start
playtesting no longer shows these initial wall embeds.

This confirms a cause of the reported spawn failures. It does not assert that
every possible locomotion or rendering issue has been ruled out.
