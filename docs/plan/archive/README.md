# Archived Planning Documents

These documents planned the garden desktop build-out (2026-03 → 2026-07).
The work they describe **shipped**: the Niri + garden-shell desktop, the
terminal stack (kitty/fish/kakoune), run-time palette theming,
notifications, power menu, and session lock are all live on fern. They are
kept for the historical record, not as guidance — the current state is
documented in the book (`just book-serve`), especially the
[Garden](../../../book/src/desktop/garden.md) and
[Niri](../../../book/src/desktop/niri.md) chapters.

## What each document was

| Document | What it was | Why archived |
|----------|-------------|--------------|
| `09-build-plan.md` | Phase-by-phase build plan (dendritic migration → shell phases), created 2026-03-27 | All phases through the C-track shipped; remaining ideas live in open-questions/newer plans |
| `10-session-plan.md` | Scoped Claude Code session breakdown of the build plan | Sessions executed; superseded along with the build plan |
| `session-handoff.md` | Point-in-time handoff for the `feat/niri` branch (2026-04-06) | Branch long since merged and switched |
| `garden-jam-session.md` | Day-one hands-on setup jam (fresh install → garden) | The install happened; book operations chapters cover setup now |

## Where planning lives now

- **This repo** — `docs/plan/`: `garden-design-docs/06-open-questions.md`
  (living decision record), `art-bundle.md` (active), the design reference
  docs 00–08 and 11, and the `.jsx` mockups.
- **garden-shell repo** — `plan/core-services-plan.md` and the shell's own
  design docs, for everything inside the shell.
- **The book** — `book/src/` documents what actually exists; when a plan
  ships, the book chapter replaces it.
