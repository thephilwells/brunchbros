# Decisions Log

Short, dated records of engineering decisions actually made. Newest first.

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
