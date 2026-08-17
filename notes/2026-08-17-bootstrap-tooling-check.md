# Bootstrap tooling check — 2026-08-17

Exploratory note, not authoritative. Recorded during the initial
documentation bootstrap.

## What was actually verified, and where

The bootstrap task asked to confirm tool versions. That check ran in
whatever machine executed this session — **not** necessarily Phil's
described dev laptop. Results:

```
rgbasm v1.0.1
rgblink v1.0.1
rgbfix  v1.0.1
rgbgfx  v1.0.1
GNU Make 3.81
git 2.50.1 (Apple Git-155)
```

Homebrew reports `rgbds 1.0.1` installed via the `arm64_tahoe` bottle.

`sameboy` was **not found** in this environment: not on `PATH`, not via
`brew list`, and no `.app` bundle turned up in `/Applications`,
`~/Applications`, or Spotlight (`mdfind`).

The machine this check ran on reports:
```
macOS 26.6.1 (build 25G76), arm64 (Apple Silicon), Darwin 25.6.0
```

## Why this is flagged, not just recorded as fact

`docs/PROJECT.md` records Phil's stated dev machine as a **2015 11-inch
MacBook Air, Intel i5, 8 GB RAM, macOS Monterey 12** — which is a different
machine (different CPU architecture, different OS major version) than the
one this check actually ran on. That mismatch means:

- The RGBDS version above is *not* confirmed to be what's installed on the
  actual dev laptop, even though the founding prompt says RGBDS is already
  installed there.
- SameBoy not being found here says nothing about whether it's installed
  on the actual dev laptop — it plausibly is, and this environment simply
  doesn't have it (or it's a GUI-only app bundle that wouldn't show up the
  way this check looked for it).
- Homebrew bottle architecture (`arm64_tahoe`) would differ on an Intel
  Monterey machine — an Intel build would come from a different bottle
  entirely, so version numbers could match while binaries differ.

## Open question

Before trusting any tooling assumption in future sessions: re-run the same
checks (`rgbasm --version`, `rgblink --version`, `rgbfix --version`,
`rgbgfx --version`, `make --version`, `git --version`, and locating SameBoy)
directly on Phil's actual dev machine, and record the result in
`docs/HARDWARE.md` or a fresh dated note — not by assuming this note's
numbers carry over.
