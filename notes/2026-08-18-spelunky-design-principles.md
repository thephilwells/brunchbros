# Design notes — lessons from a Spelunky design breakdown

Exploratory, not authoritative — ideas worth keeping in mind, not decisions.

Source: [Spelunky: a Study in Good Game Design](https://alconost.medium.com/spelunky-a-study-in-good-game-design-669a18f1a178)
(full text also saved at `docs/research/medium`). Per `AGENTS.md`'s
copyright boundary, this note studies *design principles* only — it doesn't
reproduce or adapt any of the source article's specific content, and
nothing here is Brunch Bros content, just things to consider when we
actually design our own hazards/enemies/areas later.

## Principles worth carrying forward

1. **Teach mechanics through play, in a hand-authored space, before turning
   on full randomness.** Suggests our eventual "Level generation" milestone
   may want a curated first room/area rather than procedural generation
   from the very first thing the player sees — a question for that
   milestone's own planning, not decided here.

2. **No reskins — every hazard/enemy should behave distinctly**, not just
   look different. Worth keeping in mind when scoping the Hazards and
   Enemies milestones' specs later.

3. **Fairness: the same rules apply to the player and to everything else.**
   If a hazard can hurt an enemy, it should be able to hurt the player the
   same way, and vice versa. Suggests one shared collision/damage mechanism
   rather than special-cased logic per actor — an architecture
   consideration for whenever "Gameplay systems" gets designed.

4. **New areas introduce a fresh mix of hazards/enemies/terrain together**,
   not "more of the same, reskinned." This is a content-design note for
   "Additional areas" — Hazards and Enemies stay separate *technical*
   milestones (build the mechanism once), but populating each area's
   specific mix is a separate, later concern.

5. **Risk/reward tension sustains replayability**: permadeath plus a fast
   restart, combined with randomized equipment, lets cautious and
   aggressive playstyles coexist rather than one dominating.

6. **A persistent, cross-run record of discovered knowledge (not power)**
   rewards skill growth without undermining permadeath. If Brunch Bros ever
   wants something like this — a "log" of encountered hazards/items that
   survives death — that implies needing actual persistent save data
   (battery-backed SRAM), which is cartridge hardware we haven't touched at
   all (we're currently `-m` ROM ONLY, no MBC, no save RAM). Flagging this
   as an open question for later, not a decision — would need its own
   `docs/DECISIONS.md` entry if we ever pursue it, since it changes the
   cartridge type.

## How this was used

Informed the 2026-08-18 roadmap expansion (see `docs/ROADMAP.md`) —
mostly principle #1 and #4, which touch how/when Level generation and
Additional areas get approached. Did not change the *technical* milestone
order otherwise; the rest of the roadmap shape is driven by hardware/code
dependency (what needs to exist before what's buildable), not by this
research.
