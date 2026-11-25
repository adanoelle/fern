# Aspect Index

> Every `den.aspects.<name>` defined under `modules/`, with its file,
> which sides it has, what it does and which machines carry it. Use it
> to find where something lives or to see what a new host could
> include.

## Reading the tables

**Side(s)** is what the aspect defines:

| Value | Meaning |
| --- | --- |
| nixos | A `nixos` (system) side only |
| home | A `homeManager` (user) side only |
| both | Both sides |
| includes-only | No side of its own; it only includes other aspects |
| … + includes | A side of its own and an `includes` list |

**Goes on** is worked out from the include graph (`modules/hosts.nix`,
`modules/host-*.nix`, `modules/roles/`, the bundles and
`modules/user-ada*.nix`). Which sides take effect depends on the route:

- An aspect in a host's `includes` contributes its `nixos` side only.
- An aspect forwarded through `provides.to-users`, or included by a
  user layer, contributes both sides on a NixOS host.
- On the work laptop (a standalone home) only `homeManager` sides
  apply; every `nixos` side is ignored.

Where that makes a difference the cell says which side applies. The
mechanics are in [Aspects & Composition](../architecture/aspects.md);
what each machine is for is under [Machines](../machines/fern.md).

"Every machine" means fern, yarrow and the work laptop. moss is parked
and is not counted; aspects that only it uses are marked.

## Hosts

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `fern` | `modules/host-fern.nix` | nixos + includes | Desktop workstation: roles, forwarded user layers, zen kernel, studio-interface udev rules | fern |
| `yarrow` | `modules/host-yarrow.nix` | nixos + includes | Framework laptop: roles, forwarded user layers, nixos-hardware module, latest kernel | yarrow |
| `moss` | `modules/host-moss.nix` | nixos + includes | Apple Silicon laptop, composed by hand without the workstation role | moss (parked) |

## User layers

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `ada` | `modules/user-ada.nix` | home + includes | Base layer: the `cli`, `git-suite`, `shells` and `workspace` aspects, git identities, SSH client and agent | every machine |
| `ada-desktop` | `modules/user-ada-desktop.nix` | includes-only | Desktop layer: `desktop-apps` and the garden terminal stack | fern (yarrow takes `desktop-apps` and `garden.shell` directly) |
| `ada-dev` | `modules/user-ada-dev.nix` | includes-only | Development layer: the `devtools` bundle | every machine |
| `ada-work` | `modules/user-ada-work.nix` | home + includes | Work-laptop layer: standalone niri and garden desktop, work applications and data tools, output layout, channel bindings | work laptop |

## Roles

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `workstation` | `modules/roles/workstation.nix` | includes-only | What every graphical x86 host shares: `core`, `nh`, `users`, `secrets-guard`, `secrets`, `greetd`, `fonts`, `audio`, `bluetooth`, `docker` | fern, yarrow |
| `laptop` | `modules/roles/laptop.nix` | nixos | Power profiles, zram swap, firmware updates | yarrow |
| `dev-machine` | `modules/roles/dev-machine.nix` | includes-only | Host-level development services (`aws-cli`) | fern, yarrow |
| `homelab` | `modules/roles/homelab.nix` | nixos + includes | Always-on services: `tailscale` with routing features, `radicale` | fern |
| `server` | `modules/roles/server.nix` | includes-only | Headless role: `core`, `nh`, `users`, `secrets-guard` | no host yet |

## Bundles

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `cli` | `modules/cli/bundle.nix` | includes-only | Terminal tools, editors, terminal emulators | every machine |
| `shells` | `modules/shells/bundle.nix` | includes-only | Fish, Nushell, zsh, prompt, zoxide, devenv | every machine |
| `git-suite` | `modules/git/bundle.nix` | home + includes | The `git-*` aspects, plus the `programs.gitSuite` options that switch them on | every machine |
| `devtools` | `modules/devtools/bundle.nix` | includes-only | Language toolchains and VM tools | every machine |
| `desktop-apps` | `modules/desktop/bundle.nix` | includes-only | Applications every graphical NixOS host gets | fern, yarrow |
| `music` | `modules/audio/music.nix` | includes-only | Music production: `daw` and `audio-tools` | fern |

## System aspects

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `core` | `modules/core.nix` | nixos | Nix settings, overlays, unfree, trusted users, nix-ld, default timezone | fern, yarrow |
| `users` | `modules/users.nix` | nixos | Accounts from the topology, all group membership, NetworkManager, key-only sshd | fern, yarrow |
| `boot` | `modules/boot.nix` | nixos | systemd-boot on UEFI | fern, yarrow |
| `nh` | `modules/cli/nh.nix` | nixos | `nh` rebuild helper, default flake path, weekly clean | fern, yarrow |
| `secrets` | `modules/secrets.nix` | nixos | sops-nix with the SSH host key as identity; the user's GitHub SSH key | fern, yarrow |
| `secrets-guard` | `modules/secrets-guard.nix` | nixos | trufflehog and system-wide Git | fern, yarrow |
| `greetd` | `modules/desktop/greetd.nix` | nixos | greetd with tuigreet, session list from enabled compositors, portals, polkit | fern, yarrow |
| `fonts` | `modules/fonts.nix` | both | Garden typography and fontconfig defaults | fern, yarrow (nixos side); work laptop (home side) |
| `audio` | `modules/audio/audio.nix` | nixos | PipeWire base stack, rtkit, mixer and patchbay tools | fern, yarrow |
| `audio-studio` | `modules/audio/audio-studio.nix` | nixos + includes | Low-latency tuning with musnix for a recording machine | fern |
| `audio-laptop` | `modules/audio/audio-laptop.nix` | nixos | Noise-suppressed virtual microphone and the `studio-mode` command | yarrow |
| `bluetooth` | `modules/bluetooth.nix` | nixos | BlueZ, bluetooth audio codec preference | fern, yarrow |
| `docker` | `modules/devtools/docker.nix` | nixos | Docker daemon with BuildKit and container tools | fern, yarrow |
| `tailscale` | `modules/tailscale.nix` | nixos | Tailscale client, trusted `tailscale0`, user as operator | fern, yarrow |
| `radicale` | `modules/radicale.nix` | nixos + includes | CalDAV/CardDAV server reachable only over the tailnet | fern |
| `monitoring` | `modules/monitoring.nix` | nixos | lm_sensors, stress tools, sensor logging service | fern |
| `gaming` | `modules/gaming.nix` | nixos | Steam, GameScope, GameMode, controller support | fern, yarrow |
| `aws-cli` | `modules/cloud/aws-cli.nix` | nixos | AWS CLI and infrastructure tooling | fern, yarrow |
| `boot-asahi` | `modules/asahi/boot.nix` | nixos | Apple Silicon bootloader settings | moss (parked) |
| `graphics-asahi` | `modules/asahi/graphics.nix` | nixos | Apple Silicon graphics diagnostics (`mesa-demos`, `vulkan-tools`) | moss (parked) |

## User aspects: home layout

Included directly by the base `ada` layer.

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `workspace` | `modules/workspace.nix` | home | Home directory taxonomy and XDG user directories; see [Home Directory](home-directory.md) | every machine |

## User aspects: CLI

All of these are in the `cli` bundle unless the last column says
otherwise.

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `bat` | `modules/cli/bat.nix` | home | bat, and bat as the man pager | every machine |
| `broot` | `modules/cli/broot.nix` | home | broot tree navigator | every machine |
| `btop` | `modules/cli/btop.nix` | home | btop system monitor | every machine |
| `claude-code` | `modules/cli/claude-code.nix` | home | Claude Code CLI and its session hooks | every machine |
| `crypt` | `modules/cli/crypt.nix` | home | age encryption tool | every machine |
| `delta` | `modules/cli/delta.nix` | home | Garden theme for the delta diff viewer | every machine |
| `duf` | `modules/cli/duf.nix` | home | duf disk usage | every machine |
| `dust` | `modules/cli/dust.nix` | home | dust directory sizes | every machine |
| `eza` | `modules/cli/eza.nix` | home | eza with its `ls` aliases and fish abbreviations | every machine |
| `fd` | `modules/cli/fd.nix` | home | fd file finder | every machine |
| `fzf` | `modules/cli/fzf.nix` | home | fzf fuzzy finder | every machine |
| `ghostty` | `modules/cli/ghostty.nix` | home | Ghostty terminal with garden colour and font includes | every machine |
| `glow` | `modules/cli/glow.nix` | home | glow Markdown renderer | every machine |
| `helix` | `modules/cli/helix.nix` | home | Helix editor, garden theme link, language servers | every machine |
| `herdr` | `modules/cli/herdr.nix` | home | herdr agent-aware terminal multiplexer | every machine |
| `hyfetch` | `modules/cli/hyfetch.nix` | home | hyfetch system summary | every machine |
| `jq` | `modules/cli/jq.nix` | home | jq JSON processor | every machine |
| `kakoune` | `modules/cli/kakoune.nix` | home | Kakoune editor with garden colours | every machine |
| `kitty` | `modules/cli/kitty.nix` | home | Kitty terminal | every machine |
| `lazygit` | `modules/cli/lazygit.nix` | home | Garden theme overlay for lazygit | every machine |
| `nix-diff` | `modules/cli/nix-diff.nix` | home | nix-diff derivation comparison | every machine |
| `nix-tree` | `modules/cli/nix-tree.nix` | home | nix-tree closure browser | every machine |
| `presenterm` | `modules/cli/presenterm.nix` | home | presenterm slide decks, themes and the `present` launcher | every machine |
| `prettier` | `modules/cli/prettier.nix` | home | prettier and its default configuration | every machine |
| `procs` | `modules/cli/procs.nix` | home | procs process viewer | every machine |
| `rbw` | `modules/cli/rbw.nix` | home | rbw Bitwarden command-line client | every machine |
| `ripgrep` | `modules/cli/ripgrep.nix` | home | ripgrep | every machine |
| `tmux` | `modules/cli/tmux.nix` | home | tmux with vi-style bindings | every machine |
| `tree` | `modules/cli/tree.nix` | home | tree | every machine |
| `yazi` | `modules/cli/yazi.nix` | home | Yazi file manager and its `yy` shell wrapper | every machine |
| `duckdb` | `modules/cli/duckdb.nix` | home | DuckDB CLI, harlequin, the `dpeek` helper | work laptop (not in the bundle) |
| `postgres` | `modules/cli/postgres.nix` | home | psql client and its startup settings | work laptop (not in the bundle) |
| `rustfs` | `modules/cli/rustfs.nix` | home | `rc`, an S3-compatible object store client | work laptop (not in the bundle) |
| `theodolite` | `modules/cli/theodolite.nix` | home | Data directory variable for a geocoding tool | work laptop (not in the bundle) |

## User aspects: shells

All in the `shells` bundle.

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `fish` | `modules/shells/fish.nix` | home | Fish: garden prompt, vi mode, abbreviations | every machine |
| `nushell` | `modules/shells/nushell.nix` | home | Nushell with its own aliases and environment | every machine |
| `zsh` | `modules/shells/zsh.nix` | home | zsh mirroring the fish setup in a portable `~/.zshrc` | every machine |
| `starship` | `modules/shells/starship.nix` | home | Starship prompt | every machine |
| `zoxide` | `modules/shells/zoxide.nix` | home | zoxide directory jumper | every machine |
| `devenv` | `modules/shells/devenv.nix` | home | devenv from its flake input | every machine |

## User aspects: git

All in the `git-suite` bundle.

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `git-core` | `modules/git/core.nix` | home | Core git settings, SSH commit signing, delta | every machine |
| `git-aliases` | `modules/git/aliases.nix` | home | Git aliases and shell aliases for them | every machine |
| `git-identities` | `modules/git/identities.nix` | home | Per-directory identities through `includeIf` | every machine |
| `git-github` | `modules/git/github.nix` | home | GitHub CLI, its aliases and credential helper | every machine |
| `git-tools` | `modules/git/tools.nix` | home | lazygit, tig, git-absorb, git-lfs | every machine |
| `git-safety` | `modules/git/safety.nix` | home | Safety aliases; hooks for secret scanning (gitleaks) and protected-branch pushes | every machine |
| `git-help` | `modules/git/help.nix` | home | tldr, a quick-reference file, help aliases | every machine |

## User aspects: desktop

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `niri` | `modules/desktop/niri.nix` | both | Niri: system enablement and portals; bindings, channels, idle and lock on the home side | fern, yarrow (both sides); work laptop (home side, through `niri-standalone`) |
| `brightness-ddc` | `modules/desktop/brightness-ddc.nix` | both | Brightness keys over DDC/CI for external monitors | fern |
| `brightness-backlight` | `modules/desktop/brightness-backlight.nix` | home | Brightness keys for a built-in panel | yarrow |
| `idle-suspend` | `modules/desktop/idle-suspend.nix` | home | Suspend when idle on battery | yarrow |
| `cursor` | `modules/desktop/cursor.nix` | home | The chrome key pointer theme | work laptop, yarrow |
| `wallpaper` | `modules/desktop/wallpaper.nix` | home | Painted wallpapers tied to the active palette; `garden-study` | work laptop, yarrow |
| `gtk-theme` | `modules/desktop/gtk-theme.nix` | home | GTK applications and Krita follow the active palette | work laptop, yarrow |
| `reference-board` | `modules/desktop/reference-board.nix` | home | BeeRef reference board, floating, on `Mod+I` | work laptop, yarrow |
| `color-picker` | `modules/desktop/color-picker.nix` | home | Pick a colour from the screen on `Mod+P`; hex code to the clipboard | work laptop, yarrow |
| `screen-recorder` | `modules/desktop/screen-recorder.nix` | home | Record a clip of part of the screen on `Mod+Shift+R`; MP4 in `~/recordings` | work laptop |
| `garden-app` | `modules/desktop/garden-app.nix` | home | The Garden collection app on `Mod+C` | work laptop, yarrow |
| `zen` | `modules/desktop/zen.nix` | home | Zen browser as the default browser | every machine |
| `chromium` | `modules/desktop/chromium.nix` | home | ungoogled-chromium with Wayland flags | fern, yarrow |
| `bitwarden` | `modules/desktop/bitwarden.nix` | both | Bitwarden desktop; permits its end-of-life electron | fern, yarrow |
| `screenshot` | `modules/desktop/screenshot.nix` | home | Capture tools (`grim`, `slurp`, `satty`, `wl-clipboard`) and satty defaults for the garden shell's screenshot flow, on hosts without `garden.shell` | fern |
| `imv` | `modules/desktop/imv.nix` | home | imv as the default image viewer | every machine |
| `pdf` | `modules/desktop/pdf.nix` | home | PDF viewer, manipulation and signing tools | every machine |
| `obsidian` | `modules/desktop/obsidian.nix` | home | Obsidian with the garden CSS snippet | work laptop |
| `obs` | `modules/desktop/obs.nix` | home | OBS Studio with capture plugins | fern, yarrow |
| `teams` | `modules/desktop/teams.nix` | both | teams-for-linux | fern (nixos side); work laptop (home side) |
| `thunderbird` | `modules/desktop/thunderbird.nix` | home | Thunderbird from a newer nixpkgs input | work laptop |
| `art` | `modules/desktop/art.nix` | home | Painting, pixel art, vector and photo tools | yarrow |
| `gaming-hm` | `modules/desktop/gaming-hm.nix` | home | MangoHud, Lutris, Proton helpers | fern, yarrow |

`desktop-apps` holds `zen`, `chromium`, `imv`, `pdf` and `bitwarden`. The rest are forwarded per host or included by the work
layer.

## User aspects: development

All in the `devtools` bundle except `gamedev`, which hosts forward
separately.

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `rust` | `modules/devtools/rust.nix` | both | Stable Rust through rust-overlay, rust-analyzer, cargo tools | fern, yarrow (both sides); work laptop (home side) |
| `c-cpp` | `modules/devtools/c-cpp.nix` | both | GCC, Clang, CMake, debuggers, hardening flags | fern, yarrow (both sides); work laptop (home side) |
| `node-ts` | `modules/devtools/node-ts.nix` | both | Node.js, package managers, TypeScript tooling | fern, yarrow (both sides); work laptop (home side) |
| `python` | `modules/devtools/python.nix` | both | Python, uv from a newer nixpkgs input, linters, Jupyter | fern, yarrow (both sides); work laptop (home side) |
| `ada-lang` | `modules/devtools/ada.nix` | both | Ada toolchain: GNAT, gprbuild, Alire | fern, yarrow (both sides); work laptop (home side) |
| `zig` | `modules/devtools/zig.nix` | home | Zig compiler and its language server (`zls`) | every machine |
| `vm-host` | `modules/devtools/vm-host.nix` | home | quickemu for desktop test VMs | every machine |
| `gamedev` | `modules/devtools/gamedev.nix` | home | Game libraries, level and sprite editors, profilers | every machine |

## User aspects: audio

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `daw` | `modules/audio/daw.nix` | home | Ardour and REAPER | fern (through `music`) |
| `audio-tools` | `modules/audio/audio-tools.nix` | home | Plugins, synthesizers, samplers | fern (through `music`); work laptop |
| `game-audio` | `modules/audio/game-audio.nix` | home | Chiptune trackers and sound-effect tools | yarrow |

## Work laptop and foreign distributions

Aspects that exist only for a standalone home on another distribution.
The work layer that includes them is `ada-work`, under
[User layers](#user-layers).

| Aspect | File | Side(s) | Description | Goes on |
| --- | --- | --- | --- | --- |
| `niri-standalone` | `modules/desktop/niri-standalone.nix` | home + includes | Imports niri-flake's Home Manager module and reuses `niri`'s home side | work laptop |
| `ubuntu-desktop` | `modules/foreign/ubuntu-desktop.nix` | home | nixGL wrapping, session packages and systemd user units for the niri session on Ubuntu | work laptop |
| `docker-rootless` | `modules/foreign/docker-rootless.nix` | home | Rootless Docker as a systemd user service | work laptop |
| `repd-chrome` | `modules/foreign/repd-chrome.nix` | home | Launcher for the system Chrome with an isolated profile, for one work web portal | work laptop |

## Not `den.aspects`

Two names that appear in `includes` lists are not defined here.
`garden.terminal` and `garden.shell` come from the `garden` namespace
imported from the garden-shell flake in `modules/garden.nix`; see
[Garden](../desktop/garden.md). `den._.*` entries are den's own
batteries; see
[Defaults, Core & Users](../architecture/defaults-core-users.md).

## Keeping this page in step

The `aspect-index` flake check (defined in `modules/docs.nix`, run by
`just check`) compares this page with the evaluated `den.aspects`. It
fails when an aspect has no row here, when a row names an aspect that
no longer exists, or when an aspect has two rows. A row counts when its
first cell is the aspect name alone, in backticks.

To run only this check:

```bash
nix build .#checks.x86_64-linux.aspect-index -L
```

The check covers names only. Descriptions and the "Goes on" column are
still maintained by hand.
