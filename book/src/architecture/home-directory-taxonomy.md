# Home Directory Taxonomy

> One capture point (`~/inbox`), filed by kind, cold storage by year.
> The entire tree is declared by the `workspace` aspect
> (`modules/workspace.nix`) -- nothing about the home layout is ad hoc.

This page documents the *configuration side* of the home layout: which
module owns which path, and how the tree is materialized. The
*day-to-day filing rules* (naming, triage, category caps) live in the
hm-managed manual at `~/docs/FILING.md`, which is source-controlled at
`modules/_workspace/FILING.md`.

## The tree

```
~/
├── inbox/            XDG_DOWNLOAD_DIR   sole capture point, empty by design
├── docs/             XDG_DOCUMENTS_DIR  filed documents (≤ 7 categories)
│   ├── career/                          seed category (job hunt)
│   └── FILING.md                        hm-managed manual (read-only symlink)
├── notes/                               Obsidian vaults, one subdir per vault
├── media/
│   ├── pictures/     XDG_PICTURES_DIR   images kept for their own sake
│   ├── screenshots/                     tool-written captures (niri, hyprshot)
│   ├── wallpapers/                      wallpaper images (paths load-bearing)
│   ├── video/        XDG_VIDEOS_DIR     recordings (OBS output)
│   └── music/        XDG_MUSIC_DIR      audio library
├── src/                                 code, one subdir per repo
└── archive/                             cold storage: archive/<year>/…
```

`~/Desktop`, `~/Public`, and `~/Templates` intentionally do not exist:
their XDG entries point at `$HOME`, the spec-sanctioned idiom for
"this directory is disabled". `xdg-user-dirs-update` will not recreate
them because Home Manager also writes `user-dirs.conf` with
`enabled=False`.

## Lifecycle

Files move through the tree in one direction:

1. **Capture** -- everything arriving from outside lands in `~/inbox`
   (it is the XDG download dir, so browsers and email clients agree).
2. **Triage** -- the inbox trends toward empty; an aging item is an
   unmade decision.
3. **File** -- moved to its kind: `docs/<category>/`, `notes/<vault>/`,
   `media/<subdir>/`, or `src/<project>/`.
4. **Archive** -- finished material moves to `archive/<year>/…`.
   Johnny.Decimal numbering is the designed graduation path for the
   archive, applied at archive time only -- active directories are
   never numbered or renumbered.

## How the tree is materialized

The `workspace` aspect (included by the `ada` base layer, so it applies
on every host) does three things:

| Mechanism | What it produces |
|-----------|------------------|
| `xdg.userDirs` (enabled) | `~/.config/user-dirs.dirs` + `user-dirs.conf`, eight `XDG_*_DIR` session variables, and `createDirectories = true` mkdir-p's the five real XDG dirs at activation |
| `home.activation.archivistTree` | mkdir-p for the non-XDG dirs: `docs/career`, `notes`, `archive`, `media/screenshots`, `media/wallpapers` |
| `home.file."docs/FILING.md"` | the filing manual, symlinked from the Nix store |

Two implementation details worth knowing:

- XDG dir values are **absolute paths** built from
  `config.home.homeDirectory`, not literal `"$HOME/…"` strings --
  Home Manager exports them as session variables, which do not undergo
  shell expansion. New values take effect after re-login.
- There are deliberately **no `.keep` files**: `~/inbox` must be able
  to look empty, because "empty inbox" is the signal that triage is
  done.

## Load-bearing paths

Several other aspects read or write specific taxonomy paths. Renaming
a directory here means touching these modules:

| Path | Module | Role |
|------|--------|------|
| `~/inbox` | `modules/workspace.nix` | XDG download dir (browsers, portals) |
| `~/media/screenshots` | `modules/desktop/niri.nix` | niri `screenshot-path` (built-in `Print` action) |
| `~/media/screenshots` | `modules/desktop/screenshot.nix` | hyprshot/satty script output (`shotsDir`) |
| `~/media/wallpapers` | `modules/desktop/hyprland.nix` | wallpaper option defaults + rotation directory |
| `~/media/wallpapers/shrine.png` | `modules/user-ada-desktop.nix` | the configured wallpaper (swww) |
| `~/media/video` | `modules/workspace.nix` | XDG videos dir; OBS default output |
| `~/src` | `modules/user-ada.nix` | git identity scope (`includeIf gitdir:~/src/`) |
| `~/docs/FILING.md` | `modules/workspace.nix` | hm-managed manual |

Wallpaper filenames are config-referenced (`shrine.png`), so renaming
a wallpaper is a Nix change, not just a file move.

## Invariants

- New files land in `~/inbox` and nowhere else; if an app writes
  elsewhere by default, that app gets configured, not tolerated.
- `ls ~` shows only the lowercase taxonomy -- a stray file or a
  capitalized `Downloads/` means some tool bypassed the config and
  should be traced (see the load-bearing table above).
- Every directory is enumerated in `FILING.md`; structural changes
  update the manual, this page, and `modules/workspace.nix` together.

## Deliberately out of scope

- **Preservation** -- organization is not backup. Restic/syncthing for
  `docs`, `notes`, and `archive` is a separate concern (and PR).
- **Johnny.Decimal today** -- deferred until the archive has a corpus
  worth numbering.
