# Decisions Log

Short, dated records of engineering decisions actually made. Newest first.

---

## 2026-09-21 — Biome levels use a pre-generated 40×32 logical map

**Decision:** Every biome uses a 4×4 grid of 10×8-tile subrooms, producing a
40×32-tile (320×256-pixel) level. The complete current biome is generated up
front into a 1,280-byte WRAM tile buffer. Collision and generation use that
logical map, while the 32×32 VRAM background map acts as a horizontal ring
buffer. Only logical columns 32–39 require streaming into wrapped physical
columns 0–7. Logical X coordinates become 16-bit; Y remains eight-bit.

**Why:** The full generated map fits comfortably in WRAM0, so there is no need
to generate rooms during play or discard off-screen structure. It cannot be
displayed as one static hardware map because the Game Boy background is fixed
at 32×32 tiles. Separating the authoritative logical map from its streamed VRAM
view preserves deterministic collision and backtracking.

**Status:** Accepted architecture; implementation pending. See
`specs/level-design-rules.md`.

---

## 2026-09-21 — Generation separates ordinary transitions from boundary cases

**Decision:** The critical route defaults to three-tile-or-wider destinations,
gaps and rises of at most two tiles, and drops of at most four tiles. The
accepted hard limits remain available as isolated boundary cases: two-tile
landings, three-tile gaps or rises, four-tile ledge catches, and five-to-eight-
tile drops. Boundary transitions cannot be consecutive and cannot combine a
narrow destination with a maximum gap, catch, or long drop.

**Why:** Physical reachability alone is too weak a generation rule. Keeping
ordinary geometry comfortably inside the measured envelope creates variation
without making every route a traversal test, while explicit boundary cases
preserve occasional “just made it” moments under validator control.

**Status:** Accepted baseline. See `specs/level-design-rules.md`.

---

## 2026-09-21 — Spawn and exit use protected safety envelopes

**Decision:** Spawn uses a full-solid platform at least three tiles wide with a
three-by-six-tile clear volume and an ordinary first transition. The 2×3 exit
uses a full-solid threshold, a two-tile approach apron on at least one side,
three clear rows across the combined four-tile span, and an ordinary final
transition. Both envelopes exclude hazards, enemies, furniture, and objects.

**Why:** The run must begin with room to understand and control the Chef, and
must end without random geometry or encounter placement obstructing the
deliberate Down interaction. Reserving these cells before dressing makes the
guarantee independently verifiable.

**Status:** Accepted baseline. See `specs/level-design-rules.md`.

---

## 2026-09-21 — Required vertical transitions use 24/32/64-pixel limits

**Decision:** Required routes may rise at most three tiles (24 pixels) to an
ordinary landing or four tiles (32 pixels) to an exposed, full-solid ledge
catch. Required drops may descend at most eight tiles (64 pixels), keeping the
landing's first tile row visible at the normal camera offset. Downward landings
remain at least two tiles wide.

**Why:** SameBoy testing confirms both upward limits with the fixture's
two-tile landing and opposite-side ledge catch. The downward limit follows the
current 72-pixel player screen position: a surface 64 pixels lower begins at
screen Y=136, leaving its full eight-pixel tile row visible in the 144-pixel
viewport. Deeper mandatory drops should wait for look-down camera review.

**Status:** Accepted. See `specs/level-design-rules.md`.

---

## 2026-09-21 — Required-route platforms are at least two tiles wide

**Decision:** Mandatory landing surfaces are at least two tiles, or 16 pixels,
wide. One-tile platforms may be optional precision footholds but cannot be
required landings or spawn surfaces.

**Why:** The 12-pixel terrain hitbox cannot fit completely on an eight-pixel
tile. A two-tile surface leaves four pixels of total fit tolerance and was easy
to land on from either direction in SameBoy.

**Status:** Accepted. See `specs/level-design-rules.md`.

---

## 2026-09-21 — Three tiles is the maximum same-height required-route gap

**Decision:** A same-height required-route gap may span at most three empty
8-pixel columns, or 24 pixels. Three-tile gaps must end at an exposed
full-solid upper corner so ledge catch can recover a short landing. A one-way
surface cannot provide that recovery edge. Wider gaps require a later ability
and an explicitly capability-gated route.

**Why:** SameBoy testing confirmed that the Chef just clears the three-tile
fixture gap and that ledge catch provides meaningful recovery. This matches the
calculated 25-pixel absolute limit and leaves only two pixels of landing
overlap, so three tiles is suitable as a hard limit rather than a routine gap.

**Status:** Accepted. See `specs/level-design-rules.md`.

---

## 2026-09-21 — Crouching preserves the standing terrain hitbox

**Decision:** Holding Down while grounded gives the Chef the existing crouch
pose and suppresses horizontal movement. His terrain collision remains 12×16;
crouching does not permit shorter passages or change structural reachability.
Landing squash reuses the same pose. Exit descent and future Down+A one-way
drop-through take priority over ordinary crouching when implemented.

**Why:** A pose-only terrain rule prevents generated rooms from depending on
crouch tunnels while leaving room for a shorter combat or hazard hurtbox once
those systems exist.

**Status:** Implemented and accepted in SameBoy on full-solid and one-way
support.

---

## 2026-09-21 — Ledge catch uses held direction and exposed solid corners

**Decision:** While descending, the Chef catches an exposed upper corner of a
full-solid tile only while the player holds toward it. Catch detection sweeps
every crossed 8-pixel boundary so terminal fall speed cannot skip a ledge.
One-way surfaces cannot be caught. While hanging, A jumps upward and one pixel
away from the wall, Down drops, and releasing the held direction does not
release the catch. One right-facing 16×16 pose at sprite indices 45–48 is
mirrored in OAM for left-facing hangs.

**Why:** Held direction makes catches intentional, while persistent hanging
avoids demanding continuous input after a successful catch. Requiring empty
space above and beside the solid tile limits the mechanic to true exposed
upper corners rather than arbitrary wall faces or interior seams.

**Status:** Implemented and accepted in SameBoy, including the mirrored catch
and revised hanging sprite.

---

## 2026-09-21 — Down+A drops through one-way surfaces

**Decision:** While standing on a one-way tabletop, seat, counter, or other
one-way surface, pressing Down+A will make the Chef pass downward through it.
The input never permits passage through full-solid structural tiles.

**Why:** One-way furniture should support intentional downward traversal
without weakening the collision contract of opaque walls and floors.

**Status:** Accepted for later implementation; current runtime still treats
one-way surfaces as support whenever the Chef is grounded or falling.

---

## 2026-09-21 — Standing terrain hitbox is 12×16 pixels

**Decision:** Keep the Chef's visible sprite at 16×16 pixels but use a
12×16 terrain hitbox centered on `PlayerX` and ending at the `PlayerY` feet
line. Collision probes are two pixels inset from each visual side. Each
collision edge samples its two ends and center; world-edge clamps continue
to keep the full visible sprite inside the map.

**Why:** The original full-sprite box made the Chef visibly hang too far over
platform edges. A horizontal inset better matches the drawn silhouette and
gives ledge-catching a stable body width. Center probes prevent isolated
8×8 blocks from slipping between the hitbox's corner samples.

**Status:** Implemented and accepted after SameBoy edge-overhang review.

---

## 2026-09-21 — Traversal baseline precedes procedural reachability

**Decision:** Finalize the Chef's terrain hitbox and upper-corner ledge
catch/jump/drop mechanic before defining generated-room reachability. The
first generator uses a shared seeded architecture with biome parameters;
normal critical paths require only baseline abilities, while boss arenas
are curated modules. Crouch/look camera behavior may ship with the traversal
work but does not block generation if it leaves terrain reach unchanged.
Ledge catch is a baseline ability, so a critical route may include measured,
forgiving gaps whose successful traversal ends in a ledge catch rather than
a standing landing.

**Why:** Ledge catching and collision-box dimensions change which gaps,
ledges, passages, and landing areas are valid. Building a reachability
validator against temporary movement rules would encode incorrect level
constraints and force avoidable rework.

**Status:** Hitbox and ledge mechanics are implemented pending final SameBoy
review. Crouch semantics and traversal measurements remain open in
`notes/2026-09-21-player-abilities-and-generation-prerequisites.md`.

---

## 2026-09-21 — Runs descend through four ordered biomes

**Decision:** Normal progression is Patio → Dining Room → Kitchen → Deep
Freezer. Patio, Dining Room, and Kitchen end at the same recognizable 2×3
descent doorway using shared IDs 25–30. The chef enters each biome at its
configured spawn point, so no entrance asset is required. The doorway is
passable and will activate when the overlapping player presses Down. The
Deep Freezer contains the final boss; its completion flow is a later boss
design decision.

**Why:** A repeated portal gives procedural rooms a clear, consistent goal
without spending biome-specific tile budgets or requiring matching entrance
art. Explicit input prevents accidental transitions while passing the door.

**Status:** Doorway art and Tiled metadata implemented in the dining-room
fixture. Runtime biome transitions await additional biome maps and level
generation.

---

## 2026-09-18 — Counter extends the initial dining-room fixture allocation

**Decision:** Assign dining-counter tiles to IDs 112–115 in the existing
128-tile sheet. The counter is four tiles wide and two high, with a one-way
top row and passable front row. IDs 116–127 remain unassigned.

**Why:** The 32–63 fixture band is full, but the first sheet still has
unassigned slots. Using four of them keeps the landmark, rear, and detail
budgets intact without changing the ROM's tile loader or collision-table
size.

**Status:** Implemented and reviewed in SameBoy. See
`specs/background-tile-manifest.md`.

---

## 2026-09-18 — Furniture uses one-way seat and top surfaces

**Decision:** Booths, chairs, tables, and counters will be passable from
below and from either side, but will catch a descending chef at their
designated top surface. For booths and chairs, that surface is the seat;
backs and legs remain passable. A generated per-tile collision table uses
`0=empty`, `1=full solid`, and `2=one-way top`. ID 50 is a repeatable test
surface in the current dining-room fixture; IDs 51–55 form the dining
table, IDs 56–58 form the chair, IDs 59–63 form the booth, and IDs
112–115 form the counter. Down+A drop-through is planned but not yet
implemented.

**Why:** The existing full-solid structural tiles block all directions.
Distinct collision types keep visual furniture parts separate from the
surface the chef can stand on. Checking every crossed tile top avoids
skipping an 8-pixel surface during a 16-pixel fall.

**Status:** Mechanic, test surface, table, chair, booth, and counter
confirmed in SameBoy. See `specs/background-assets.md` and
`specs/background-tile-manifest.md`.

---

## 2026-09-18 — Adopt collaborative implementation with stepwise review

**Decision:** Phil approves each meaningful step, and the assistant may edit
code, assets, and documentation within that scope. The assistant builds and
checks its work, then leaves the changes uncommitted for Phil to review.
Commits and pushes require explicit requests. This supersedes the 2026-08-17
Navigator Mode agreement below; manual line-number guidance still applies
when Phil chooses to type a change himself.

**Why:** Phil now prefers reviewing small implemented changes to transcribing
every line, while retaining the learning value of hardware explanations and
stepwise approval.

**Status:** Active. See `AGENTS.md`.

---

## 2026-09-18 — Structural pilot uses signed BG addressing and fixed tile IDs

**Decision:** The first tileset pilot reserves BG IDs 0–127 at `$9000` with
signed BG addressing and keeps chef sprite IDs 1–44 at `$8010`. BG IDs 1–16
are full-solid 8×8 cells chosen from a four-neighbor mask; ID 0 is empty.
The remaining pilot slots stay reserved. `BGP=$E4` gives backgrounds four
distinct shades while `OBP0=$E0` preserves the chef's appearance. Tiled
local IDs match BG map bytes through the generated fixture map, but its
GIDs are converted rather than copied into the ROM.

**Why:** The Game Boy offers a separate physical 128-tile block at `$9000`
for signed BG IDs 0–127, so the pilot can grow without overwriting the
existing chef tiles. Fixed IDs and explicit collision semantics let a later
room generator select connecting shapes without inferring gameplay from
pixels. The art is intentionally a geometry/contrast pilot; biome fixtures
and their behavior still need individual review.

**Status:** Implemented for the structural pilot. See
`specs/background-assets.md` and `specs/background-tile-manifest.md`.

---

## 2026-08-18 — Working agreement: line-number anchors must still be written unambiguously

**Decision:** Citing line numbers (per the 2026-08-17 agreement below) isn't
sufficient on its own — a GUIDE step naming *two different* line numbers in
one sentence is just as ambiguous as the original repeated-text problem it
was meant to fix. Each insertion/move instruction should identify exactly
one unambiguous destination, stated plainly, not woven into a sentence that
also mentions a different line for context.

**Why:** A step said to insert a new subroutine "right after line 342...
i.e. leave `UpdateSprites` alone and instead add this after line 389" — two
line numbers, one sentence. The code landed after line 342 (the first one
named), splitting `UpdateSprites` in half: a new global label ended up
between its normal-facing block and its `.flipped` local label, which
silently rescoped `.flipped` to the new label instead of `UpdateSprites`.
`rgblink` caught it (`Undefined symbol UpdateSprites.flipped`), but only
after a full edit-and-build cycle — the rule was followed to the letter and
still produced an ambiguous instruction.

**Status:** Active. Supplements the 2026-08-17 entry below and
`AGENTS.md`'s Interaction loop section.

---

## 2026-08-17 — Working agreement: line-number anchors for GUIDE steps

**Decision:** When telling Phil where to insert or move code, use line
numbers as the anchor, not just surrounding source text.

**Why:** A GUIDE step said to insert a block "between `ldh [$ff47], a` and
`jr MainLoop`" — but `ldh [$ff47], a` appeared twice (once in `Start:`'s
one-time setup, once in `MainLoop:`). The D-pad-handling code landed in
`Start:`, ran exactly once at boot, and never moved the sprite again. The
code was typed correctly; the instruction was just ambiguous. Line numbers
don't have this failure mode the way repeated text does.

**Status:** Active. See `AGENTS.md`'s Interaction loop section.

---

## 2026-08-17 — Working agreement: skip sibling review branches

**Decision:** Since Brunch Bros is a solo project, background/agent sessions
no longer hand off worktree changes via a distinct sibling branch off
`main`. Once isolated in a worktree (still required by the session
harness), changes get copied directly onto `main` as uncommitted files for
Phil to review and commit, and the worktree gets removed afterward. This
supersedes the branch-per-handoff approach used earlier the same day (see
the now-merged, now-deleted `docs/dev-machine-retrofit` branch).

**Why:** the extra branch-off-main step exists to protect against other
collaborators or parallel agents reviewing/working against a repo at the
same time; neither applies here. As long as `main` has commit history, the
worktree tool can always branch from it, so this only works post-bootstrap.

**Status:** Active.

---

## 2026-08-17 — Dev machine retrofit

**Decision:** Development moves from the machine originally described in the
founding prompt (2015 11-inch MacBook Air, Intel i5, 8 GB RAM, macOS
Monterey 12) to Phil's current machine: MacBook Pro 18,2 (Apple M1 Max,
arm64), 64 GB RAM, macOS 26.6.1 (Tahoe). This supersedes the "Dev machine"
section previously recorded in `docs/PROJECT.md`.

Re-verified on the new machine:
```
rgbasm v1.0.1 / rgblink v1.0.1 / rgbfix v1.0.1 / rgbgfx v1.0.1  (Homebrew, arm64_tahoe bottle)
GNU Make 3.81
git 2.50.1 (Apple Git-155)
SameBoy.app present at /Users/phil.wells/Downloads/SameBoy.app
```
SameBoy is not yet on `PATH`, not installed via Homebrew, and not moved into
`/Applications` — still sitting where it was downloaded to. Fine for manual
launch; worth relocating/aliasing before we lean on scripted emulator runs.

**Why:** The original MacBook Air became prohibitively slow for running
LLM CLI agents, which this project's workflow depends on.

**Status:** Active. Supersedes the machine described in the original
2026-08-17 bootstrap entry below and in `docs/PROJECT.md`'s original "Dev
machine (as described by Phil)" section.

---

## 2026-08-17 — Bootstrap: adopt Navigator Mode and this doc structure

**Decision:** This repository is operated in Navigator Mode by default (see
`AGENTS.md`) for all future AI-assisted sessions, until Phil explicitly says
otherwise. Documentation lives in `docs/`, `specs/`, and `notes/` per the
structure described there.

**Why:** Phil is deliberately building Brunch Bros to learn Game Boy
development hands-on; the point of the project is understanding, not output.
This needs to survive across sessions/tools (Codex, Claude Code, etc.), so
it's encoded in the repo rather than left as conversational context.

**Status:** Superseded by the 2026-09-18 collaborative implementation decision.

---

## 2026-08-17 — Target hardware baseline

**Decision:** Primary target is original Game Boy / DMG. GBC-only features
are avoided unless a future decision explicitly says otherwise (to be
recorded here if it happens). Implementation language is RGBDS assembly;
no other engine/framework/runtime without discussion first.

**Why:** Stated directly in the project's founding prompt; keeps scope
honest to "real Game Boy hardware," which is a core goal of the project.

**Status:** Active.
