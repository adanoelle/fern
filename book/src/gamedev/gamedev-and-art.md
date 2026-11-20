# Game development and art

> Three opt-in user aspects: `gamedev` (C++ game libraries, level and
> sprite editors, profilers), `art` (painting, pixel, vector and photo
> tools) and `game-audio` (trackers and sound-effect tools). They are
> global conveniences on the machines that take them, not the toolchain
> of any one project.

**Goes on:**

| Aspect       | fern | yarrow | work laptop | Included from |
| ------------ | ---- | ------ | ----------- | ------------- |
| `gamedev`    | yes  | yes    | yes         | `host-fern.nix`, `host-yarrow.nix`, `user-ada-work.nix` |
| `art`        | no   | yes    | no          | `host-yarrow.nix` |
| `game-audio` | no   | yes    | no          | `host-yarrow.nix` |
| `reference-board` | no | yes | yes | `host-yarrow.nix`, `user-ada-work.nix` |
| `color-picker` | no | yes | yes | `host-yarrow.nix`, `user-ada-work.nix` |

All five are home-manager only. `gamedev` is not part of the `devtools`
bundle: each machine opts in, the NixOS hosts by forwarding it to the
user (`provides.to-users`), the work laptop by including it in the work
layer. fern takes the full `music` layer instead of `game-audio`; see
[Audio](../services/audio.md).

## How this relates to actual game projects

The libraries here are SDL2-era. The owner's current game is built on
its own SDL3 engine, which lives in another repository and brings its
own dev shell. Nothing in this aspect is that project's toolchain. What
`gamedev` provides is a set of libraries and tools that are always on
hand for experiments, small prototypes and inspecting builds.

## `gamedev`

`modules/devtools/gamedev.nix` defines one list, `gameLibs`, installs
it, and derives two environment variables from it.

| Group             | Packages in `gameLibs` |
| ----------------- | ---------------------- |
| Windowing, media  | `SDL2`, `SDL2.dev`, `SDL2_image`, `SDL2_mixer`, `SDL2_mixer.dev`, `SDL2_ttf` |
| ECS, math, physics| `entt`, `glm`, `box2d` |
| UI, profiling     | `imgui`, `tracy` |
| Text, logging     | `nlohmann_json`, `fmt`, `fmt.dev`, `spdlog`, `spdlog.dev` |
| Scripting         | `lua5_4`, `sol2` |
| Testing, misc     | `catch2_3`, `stb` |

In the current nixpkgs pin, `SDL2` resolves to `sdl2-compat`, the SDL2
API implemented on top of SDL3.

Tools installed alongside the libraries:

| Package      | Purpose |
| ------------ | ------- |
| `tiled`      | Tile map editor |
| `ldtk`       | Level editor |
| `aseprite`   | Sprite editor |
| `heaptrack`  | Heap profiler |
| `renderdoc`  | Graphics frame debugger |
| `valgrind`   | Memory checker |
| `perf`       | Linux sampling profiler |
| `flamegraph` | Flame graphs from profiler output |

RenderDoc is used as packaged: the configuration sets nothing for it,
and the nixpkgs build enables upstream's experimental Wayland support
and wraps `qrenderdoc` with `QT_QPA_PLATFORM="wayland;xcb"`.

`ldtk` and `renderdoc` are x86_64-only, one of the reasons
[moss](../machines/moss.md) is parked.

### `CMAKE_PREFIX_PATH` and `PKG_CONFIG_PATH`

Both are set through `home.sessionVariables`, so they are part of the
login session and change only after logging in again:

| Variable            | Value |
| ------------------- | ----- |
| `CMAKE_PREFIX_PATH` | the store path of every `gameLibs` entry, joined with `:` |
| `PKG_CONFIG_PATH`   | `<store path>/lib/pkgconfig` for every `gameLibs` entry, joined with `:` |

This lets `find_package` and `pkg-config` find the libraries from a
plain shell, outside a dev shell. The list is computed mechanically, so
`PKG_CONFIG_PATH` contains an entry for each output whether or not it
has a `lib/pkgconfig` directory (for SDL2 the `.pc` files are in the
`dev` output). The variables are session-wide: they are also visible to
builds of unrelated projects started from the same session.

## `art`

`modules/desktop/art.nix` installs `krita`, `aseprite`, `inkscape` and
`gimp`. Aseprite is listed by both `art` and `gamedev`; the two resolve
to the same store path.

The aspect sets no file associations. All four programs register
`image/*` handlers, and the defaults stay pinned to the viewer by
`modules/desktop/imv.nix`, so `xdg-open` on an image opens imv rather
than an editor. Application settings are left unmanaged.

## Reference board

`modules/desktop/reference-board.nix` installs
[BeeRef](https://beeref.org), a canvas for reference images: drop
images on it, arrange and scale them, and save the board as one `.bee`
file.

- `Mod+I` brings the board up. It focuses the open board, or starts
  BeeRef if none is open (the `reference-board` command does the same).
- The window opens floating, so it stays above the tiled painting
  application and can be dragged beside the canvas.
- BeeRef is built against Python 3.13, because one of its dependencies
  fails its tests on the default Python in the pinned nixpkgs. The
  module's comment says when the override can go.

## Colour picker

`modules/desktop/color-picker.nix` binds `Mod+P` to `pick-color`. The
pointer becomes a picker; a click anywhere on screen puts that colour's
hex code (`#rrggbb`) on the clipboard, and a notification shows a
swatch with the code. `Escape` cancels.

- The picking is niri's own (`niri msg pick-color`), so it works over
  any window, including the reference board and the wallpaper.
- Every pick is appended to `~/.local/state/picked-colors` with the
  time, newest last.

## `game-audio`

`modules/audio/game-audio.nix` is the light set for writing game music
and effects, kept separate from the `music` layer so a laptop can take
it alone.

| Package          | Purpose |
| ---------------- | ------- |
| `famistudio`     | Tracker |
| `furnace`        | Tracker |
| `sfxr-qt`        | Sound-effect generator (can export from the command line) |
| `reaper`         | Arranging, editing, mastering |
| `ffmpeg`, `sox`  | Conversion and loudness measurement |

## MangoHud

The overlay used when playtesting is not part of these aspects. It comes
from the gaming setup: `modules/gaming.nix` adds it to Steam's extra
packages, and `modules/desktop/gaming-hm.nix` installs it for the user.
Both are on fern and yarrow; see [Gaming](../services/gaming.md).

## Key files

| File                            | Purpose                                    |
| ------------------------------- | ------------------------------------------ |
| `modules/devtools/gamedev.nix`  | `gamedev`: libraries, tools, path variables|
| `modules/desktop/art.nix`       | `art`                                      |
| `modules/audio/game-audio.nix`  | `game-audio`                               |
| `modules/desktop/imv.nix`       | Image mime defaults                        |
| `modules/host-fern.nix`         | Forwards `gamedev`                         |
| `modules/host-yarrow.nix`       | Forwards `gamedev`, `art`, `game-audio`    |
| `modules/user-ada-work.nix`     | Includes `gamedev`                         |
