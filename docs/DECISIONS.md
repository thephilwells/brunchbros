# Decisions Log

Short, dated records of engineering decisions actually made. Newest first.

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
