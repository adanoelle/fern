# Home directory

> One capture point (`~/inbox`), everything else filed by kind, cold
> storage by year. The tree is declared by the `workspace` aspect
> (`modules/workspace.nix`); this page lists what that module creates
> and which other modules depend on the paths.

**Goes on:** every host. `workspace` is included by the `ada` base
layer (`modules/user-ada.nix`), so it applies on fern, yarrow and the
work laptop.

The day-to-day filing rules (naming, triage, category limits) are not
repeated here. They are in the manual installed at `~/docs/FILING.md`,
whose source is `modules/_workspace/FILING.md`.

## The tree

```
~/
├── inbox/            XDG_DOWNLOAD_DIR   sole capture point
├── docs/             XDG_DOCUMENTS_DIR  filed documents
│   ├── career/                          seed category
│   └── FILING.md                        managed manual (store symlink)
├── notes/                               note vaults, one subdir each
├── media/
│   ├── pictures/     XDG_PICTURES_DIR
│   ├── screenshots/                     written by screenshot tooling
│   ├── wallpapers/                      referenced by name from config
│   ├── video/        XDG_VIDEOS_DIR
│   └── music/        XDG_MUSIC_DIR
├── work/
│   └── notes/                           work notes vault
│       ├── daily/  meetings/  projects/  areas/
│       └── literature/  resources/  archive/  templates/  docs/
├── src/                                 code, one subdir per repo
└── archive/                             cold storage: archive/<year>/…
```

`~/src` is not created by the module; it appears here because other
configuration is scoped to it (see below).

`~/Desktop`, `~/Public` and `~/Templates` do not exist. Their XDG
entries (`desktop`, `publicShare`, `templates`) point at the home
directory itself, which the xdg-user-dirs specification defines as
"disabled". One side effect: `XDG_PUBLICSHARE_DIR` is the home
directory, which matters for quickemu's shared folders
(see [Other toolchains](../toolchains/other.md#virtual-machines-vm-host)).

## How the tree is created

| Mechanism in `workspace.nix`     | What it produces |
| -------------------------------- | ---------------- |
| `xdg.userDirs` with `createDirectories = true` | `~/.config/user-dirs.dirs`, a `user-dirs.conf` containing `enabled=False`, and a `mkdir -p` of each XDG directory at activation |
| `setSessionVariables = true`     | the `XDG_*_DIR` variables in the session; pinned explicitly because the home-manager default changes with `home.stateVersion` |
| `home.activation.archivistTree`  | `mkdir -p` of the non-XDG directories: `docs/career`, `notes`, `archive`, `media/screenshots`, `media/wallpapers`, `work/notes` and its subdirectories |
| `home.file."docs/FILING.md"`     | the manual, linked from the Nix store (read-only) |

Details worth knowing:

- XDG values are absolute paths built from `config.home.homeDirectory`.
  New values reach running programs after the next login.
- No `.keep` files are written: `~/inbox` has to be able to look empty.
- home-manager's `xdg.userDirs` also has a `projects` entry that the
  module does not set. It keeps its default, so `XDG_PROJECTS_DIR` is
  `~/Projects` and that directory is created at activation alongside
  the others.

## Paths other modules depend on

Renaming a directory means changing these modules too.

| Path                  | Module                           | Use |
| --------------------- | -------------------------------- | --- |
| `~/inbox`             | `modules/workspace.nix`          | XDG download directory |
| `~/media/screenshots` | `modules/desktop/niri.nix`       | niri `screenshot-path` |
| `~/media/screenshots` | `modules/desktop/screenshot.nix` | output directory of the screenshot scripts |
| `~/media/wallpapers`  | `modules/desktop/hyprland.nix`   | defaults of the Hyprland wallpaper options |
| `~/media/wallpapers/shrine.png` | `modules/user-ada-hyprland.nix` | the Hyprland session's wallpaper, drawn by `awww` |
| `~/src`               | `modules/user-ada.nix`           | git identity scope (personal) |
| `~/src/work`          | `modules/user-ada.nix`           | git identity scope (work) |
| `~/work`              | `modules/user-ada.nix`           | git identity scope (work, for the notes vault and other non-code repositories) |
| `~/docs/FILING.md`    | `modules/workspace.nix`          | the managed manual |

Notes:

- The wallpaper file is referenced by name, so renaming it is a Nix
  change. This applies to the Hyprland fallback session only
  ([Hyprland](../desktop/hyprland.md)). The niri session's wallpaper
  does not read `~/media/wallpapers`; see
  [Wallpaper](../desktop/wallpaper.md).
- The git identities are selected by `includeIf gitdir:` conditions
  built from the three directories above; `~/src/work` is inside
  `~/src` and takes precedence there. See [Git](../git/git.md).
- `~/media/video` is the XDG videos directory. No module configures a
  recording tool to write there.

## Key files

| File                              | Purpose                                 |
| --------------------------------- | --------------------------------------- |
| `modules/workspace.nix`           | XDG user dirs, extra directories, manual|
| `modules/_workspace/FILING.md`    | Source of `~/docs/FILING.md`            |
| `modules/user-ada.nix`            | Includes `workspace`; git identity scopes |
| `modules/user-ada-hyprland.nix`   | Hyprland wallpaper path                 |
