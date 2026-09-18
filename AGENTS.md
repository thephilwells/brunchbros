# AGENTS.md — Durable Instructions for This Repository

This file is the map. Deeper, longer-lived material lives under `docs/`,
`specs/`, and `notes/` — read those when you need depth; this file just
tells you the rules and where to look.

## Collaborative implementation (default)

Phil approves the scope of each meaningful step; the assistant may then edit
source, assets, tools, tests, and documentation within that scope. Keep changes
small enough to review, explain Game Boy-specific decisions, verify the build
and behavior where possible, and hand the diff back for Phil's review before
the next substantial step. Phil need not type the code himself.

Do not silently expand an approved step into a different mechanic, engine, or
hardware target. Surface material tradeoffs before committing to them. Do not
commit or push unless Phil explicitly asks; never push to `main`/`master`
without explicit approval for that push. Preserve unrelated worktree changes.
Generated tables and converted assets may be automated when they are within
the approved step and their source and output contract are clear.

Keep code direct: no comments unless the reason is genuinely non-obvious, and
no abstractions or error handling for hypothetical futures. Always make a new
commit rather than amending unless Phil asks otherwise; never force-push or
discard his work without approval.

## Teaching style

- Assume ordinary programming fluency; don't over-explain general concepts.
- Explain Game Boy-specific concepts as they become relevant, including why a
  technique exists on this hardware and how it relates to familiar concepts.
- Distinguish conventions from hardware requirements and flag meaningful
  alternatives. Explain nontrivial assembly changes so Phil can review them.

## Interaction loop

Work in reviewable increments:

1. **UNDERSTAND** — inspect repo state and agree on the immediate goal.
2. **EXPLAIN** — state the key hardware/architecture implications and plan.
3. **IMPLEMENT** — edit within the approved scope, without speculative extras.
4. **VERIFY** — build, test, and inspect the result proportionate to risk.
5. **REVIEW** — report what changed, what remains unverified, and any decision
   needed before the next substantial step.

Cite concrete file paths and line numbers when referring to existing code.
When a manual-edit guide tells Phil where to insert or move code, anchor it with
line numbers, not just surrounding text — text anchors like "between X and
Y" can be ambiguous if that text appears more than once in the file (e.g.
`ldh [$ff47], a` showed up in both `Start:` and `MainLoop:`, and code meant
for the loop landed in one-time setup instead). Line numbers referenced
should be re-confirmed with a fresh `Read` if there's any chance prior
edits shifted them.

## Documentation discipline

Distinguish **authoritative** material (current architecture, accepted specs,
confirmed hardware facts, decisions actually made — lives in `docs/` and
`specs/`) from **exploratory** material (ideas, open questions, experiments —
lives in `notes/`). Never promote exploratory content to authoritative
without Phil's approval. If existing docs contradict each other, flag the
contradiction rather than silently picking a side. When a decision changes,
update or supersede the old text clearly — don't leave two versions that
both look current.

## Copyright / inspiration boundary

Brunch Bros is inspired by the *design principles* of Spelunky, not a clone.
We may study publicly observable mechanics and technical patterns. We do not
copy copyrighted art, audio, source code, dialogue, level layouts,
distinctive written content, or other proprietary assets. Flag it if Phil
drifts toward reproducing something that is effectively a direct copy.

## Background-session worktree handling

Brunch Bros is a solo project — no other collaborators or parallel agent
sessions review this repo. When a background/agent session needs to write
to the repository and the session harness requires worktree isolation, there is no
need for a sibling review branch: enter the worktree, make the change, exit
with `keep`, then copy the changed files straight onto whatever branch is
checked out in the main checkout (normally `main`) as **uncommitted**
changes, and remove the worktree once the copy is confirmed. Phil reviews
and commits from his own checkout as usual. This only works because `main`
always has commit history for the worktree tool to branch from — if it's
ever empty again, the first commit still has to come from Phil. See the
2026-08-17 "Working agreement: skip sibling review branches" entry in
`docs/DECISIONS.md`.

## Where things live

| Doc | Purpose |
|---|---|
| `README.md` | Human-facing intro, build/run instructions (as they exist) |
| `docs/PROJECT.md` | Vision, scope, goals, target hardware |
| `docs/LEARNING.md` | Living map of GB concepts encountered so far |
| `docs/ARCHITECTURE.md` | Current architecture of the actual game (starts empty) |
| `docs/HARDWARE.md` | GB constraints relevant to this project |
| `docs/DECISIONS.md` | Short, dated engineering decision records |
| `docs/ROADMAP.md` | Milestones, first ROM through finished game |
| `specs/` | Specs for substantial gameplay subsystems, written before building them |
| `notes/` | Exploratory/investigation notes, not yet authoritative |

## Current state (as of 2026-08-27)

Past bootstrap. `src/main.asm` is a real, playable-so-far ROM: input,
animated player sprite, tile collision, jumping/gravity, and a scrolling
camera (both axes) over a widened world. Check `docs/ROADMAP.md`'s checked
items and "Immediate next milestone" line for exactly where things stand —
that file is kept current every milestone, this section is not a substitute
for reading it. `docs/LEARNING.md` has the full concept log; read it before
assuming a hardware fact isn't already established. The dev machine changed
from the one in the founding prompt to Phil's current machine (MacBook Pro
18,2 / M1 Max / 64 GB / macOS 26.6.1) — see the 2026-08-17 "Dev machine
retrofit" entry in `docs/DECISIONS.md`. `notes/2026-08-17-bootstrap-tooling-check.md`
documents the original verification mismatch and is now resolved/historical.
