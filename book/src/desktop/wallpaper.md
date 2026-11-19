# Painted wallpapers

> The niri session can hang a painting behind the windows. A *study*
> pairs a garden palette, built from a painter's working colours, with
> that painter's paintings; the active palette decides which study is on
> the wall, so palette and painting change together. The images are
> fetched from pinned open-access sources and cropped at build time.

**Goes on:** the [work laptop](../machines/work-laptop.md) and
[yarrow](../machines/yarrow.md). Adding it to another niri host is one
line: put `den.aspects.wallpaper` in that host's
`provides.to-users.includes` (it sets `programs.niri.settings`, so it
needs a host that carries the niri module, like the other
[niri add-ons](niri.md#per-machine)).

## Studies and palettes

`modules/desktop/wallpaper.nix` is only the mechanism. Each study is one
data file, `modules/desktop/_studies/<palette>.nix`, named after its
palette and picked up automatically.

- The active palette's study is shown. A palette with no study shows
  the default study (`defaultStudy` in `wallpaper.nix`).
- A painting whose colour departs from its painter's can name its own
  `palette`. Choosing that painting applies that palette; choosing that
  palette (in the shell's settings, say) puts the first painting that
  uses it on the wall.
- A palette can belong to only one study. Evaluation fails with a
  message naming both studies otherwise.
- The painting last chosen for each study is remembered in
  `~/.local/state/garden-study/`.

niri's window borders take the palette at build time
([Garden](garden.md#build-time-palette)), so they do not follow.

## Commands and binds

| Command | Bind | Effect |
| ------- | ---- | ------ |
| `garden-study` | | list studies and paintings with attributions; `*` marks what is showing |
| `garden-study next` | `Mod+G` | the next study, wrapping around |
| `garden-study painting` | `Mod+Shift+G` | the next painting in the current study |
| `garden-study placard` | `Mod+Ctrl+G` | show the current painting's label |
| `garden-study <study> [painting]` | | that study, and optionally a painting in it |

Palettes are switched through the garden shell's `switchPalette` IPC
call when the shell is running, so its bar and switcher follow, and
through `garden-themes apply --name` otherwise.

Each new painting is announced by its placard: a transient notification
with title, painter, year and collection.

## Renditions and crops

Every painting is rendered twice by ImageMagick in a Nix derivation:

| Rendition | Size | Used for |
| --------- | ---- | -------- |
| `ultrawide.jpg` | 3440x1440 | the output with connector name `DP-2` |
| `panel.jpg` | 2400x1500, or the whole painting at 2400 px wide when no `panel` crop is given | every other output |

Crops are given in thousandths of the source image: `top` is where the
crop starts, `left` and `right` are its sides (default: full width),
and the height follows from the output's shape. A crop that runs past
the bottom of the image fails the build. A painting can instead supply
`ready` images that are already cropped.

swaybg can match the ultrawide only by connector name. On a different
dock or port the monitor gets the panel rendition, scaled to fill.

## The service

`systemd.user.services.wallpaper` runs `garden-wallpaper`, bound to
`graphical-session.target`. It starts swaybg with both renditions, then
watches the garden themes directory and the state directory with
inotify. On a change it starts the new swaybg before stopping the old
one, so the bare backdrop never shows. Once a minute it also restarts a
swaybg that has died.

Two niri settings make the painting visible:

- a layer rule places swaybg's `wallpaper` namespace in niri's backdrop,
  so it also shows behind the overview;
- `layout.background-color = "transparent"`, because each workspace
  otherwise paints a solid colour over the backdrop.

swaybg draws through shared memory, so it needs no GL wrapper on a
non-NixOS host.

## Adding a painting or a study

**Another painting for an existing painter:** add an entry to the
`paintings` list in that study's file. An entry needs `name`, `title`,
`year`, `collection`, a `src` (`fetchurl` with a pinned hash) and an
`ultrawide` crop; `panel` and `palette` are optional. The first entry
is the study's default painting.

**A new study:** the palette has to exist in garden-shell's
`palettes.toml` at the locked revision. Then add
`modules/desktop/_studies/<palette>.nix` with a `painter` and a
`paintings` list; an existing file is the template.

Stage a new file with `git add` before evaluating, as with any new
file in a flake.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/wallpaper.nix` | renditions, `garden-study`, the swaybg service, binds, layer rule |
| `modules/desktop/_studies/*.nix` | one study per file: painter, paintings, sources, crops |
| `modules/user-ada-work.nix` | the only includer |
