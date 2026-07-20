# FILING.md — the home directory filing manual

This home directory is a filing system, not a junk drawer. Every file
has exactly one designed destination, and this document is the map.
The tree is managed declaratively by `modules/workspace.nix` in the
fern repo — this file is itself hm-managed and read-only; edit it in
the repo.

## The tree

```
~/
├── inbox/            capture point — the ONLY place new files land
├── docs/             filed documents (≤ 7 categories, see index below)
│   ├── career/         job hunt: résumés, offers, applications
│   └── FILING.md       this manual (hm-managed symlink)
├── notes/            Obsidian vaults — one subdir per vault, nothing loose
├── media/
│   ├── pictures/       photos and images kept for their own sake
│   ├── screenshots/    tool-written captures (niri, hyprshot, satty)
│   ├── wallpapers/     wallpaper images — these paths are LOAD-BEARING
│   │                   (awww/hyprland config points here by name)
│   ├── video/          recordings (OBS default output)
│   └── music/          audio library
├── src/              code — one subdir per repo/project
└── archive/          cold storage, by year: archive/2026/…
```

`~/Desktop`, `~/Public`, and `~/Templates` do not exist: they are
disabled via the spec-sanctioned idiom of pointing their XDG entries
at `$HOME`. If an app recreates one, that app is misconfigured — fix
the app, don't keep the directory.

## Lifecycle: capture → triage → file → archive

1. **Capture.** Everything arriving from outside (browser downloads,
   email attachments, exports) lands in `~/inbox`. Nothing else ever
   writes anywhere else by default.
2. **Triage.** `inbox/` is empty by design. An item aging in the inbox
   is an unmade decision — make it: file it, or delete it.
3. **File.** Move it to its kind: `docs/<category>/`, `notes/<vault>/`,
   `media/<subdir>/`, or `src/<project>/`.
4. **Archive.** When something is finished — a project shipped, a
   document superseded, a year closed — it moves to
   `archive/<year>/…`. Archived means "kept but no longer worked on".

## docs/ — category index

Hard cap: **seven categories**. If an eighth seems necessary, either
merge two existing ones or the new thing belongs in `notes/` or
`archive/`. Current index:

| Category  | Contents                                    |
| --------- | ------------------------------------------- |
| `career/` | résumés, job applications, offers, reviews  |

(Six slots free. Add rows here when adding directories.)

**Naming rule:** `YYYY-MM-DD-kebab-description.ext`, where the date is
the **document's** date (when it was issued/signed/received), not the
filing date. Example: `2026-03-14-acme-offer-letter.pdf`.

## notes/ — thinking, not records

- Vaults only. Every child of `notes/` is an Obsidian vault; no loose
  files at the top level.
- The distinction: **docs are *about* something; notes are the
  thinking itself.** A signed lease → `docs/`. Your analysis of
  whether to sign it → `notes/<vault>/`.

## archive/ — by year, Johnny.Decimal-ready

- Layout today: `archive/<year>/<whatever-made-sense>/`.
- **Graduation path:** when the corpus is large enough to warrant it,
  Johnny.Decimal numbering (`archive/10-19 finances/11 taxes/…`) is
  applied **at archive time only**. JD never applies to active
  directories, and existing numbers are **never renumbered** — a JD
  number is a permanent address, that's the whole point.

## media/ — subdirectory contract

- `pictures/` is the XDG pictures dir; generic images live here.
- `screenshots/` is written by tooling (niri `Print`, hyprshot
  scripts) with timestamped names; prune freely.
- `wallpapers/` filenames are referenced from Nix config
  (e.g. `shrine.png`) — renaming a wallpaper means a config change.
- `video/` is the XDG videos dir and OBS's output target.
- `music/` is the XDG music dir.

## Invariants (the archivist's oath)

- `inbox/` trends toward empty.
- Nothing valuable lives loose in `~/` — if `ls ~` shows a file,
  something went wrong upstream.
- Every directory in this tree is enumerated in this manual; every
  addition updates the manual (in the repo) in the same change.
