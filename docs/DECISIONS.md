# Decisions Log

Short, dated records of engineering decisions actually made. Newest first.

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

**Status:** Active.

---

## 2026-08-17 — Target hardware baseline

**Decision:** Primary target is original Game Boy / DMG. GBC-only features
are avoided unless a future decision explicitly says otherwise (to be
recorded here if it happens). Implementation language is RGBDS assembly;
no other engine/framework/runtime without discussion first.

**Why:** Stated directly in the project's founding prompt; keeps scope
honest to "real Game Boy hardware," which is a core goal of the project.

**Status:** Active.
