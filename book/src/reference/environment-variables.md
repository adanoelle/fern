# Environment Variables

> The environment variables this configuration sets, grouped by the
> module that sets each, and whether a variable is session-wide or
> exists only inside one shell. Generated from the evaluated
> configuration of fern, yarrow and the work laptop.

**Goes on:** see the last column of each table. "Every machine" means
fern, yarrow and the work laptop.

Variables that NixOS or Home Manager set on their own, with no line in
this repository asking for them (`LANG`, `PAGER`, `NIX_PATH`,
`XDG_CONFIG_DIRS`, `LOCALE_ARCHIVE`, `TMUX_TMPDIR`, `STARSHIP_CONFIG`
and similar), are left out. The commands at
[the end of the page](#regenerating-this-page) print the full sets.

## Three scopes

| Scope | Option | Who sees it |
| --- | --- | --- |
| System | `environment.variables`, `environment.sessionVariables` | Every user and login shell on a NixOS host |
| User session | `home.sessionVariables` | The user's login shells and the session started from them |
| One shell | Shell init text | Only processes started from that shell |

Where the system and the user session both set a name, the user value
wins for the user. `EDITOR` is the visible case: NixOS defaults it to
`nano` system-wide, and the user session sets `hx`.

On the work laptop there is no system scope. Only `homeManager` sides
apply, so every variable in the system table below is absent there.

## System variables

| Variable | Value | Set in | Goes on |
| --- | --- | --- | --- |
| `NH_FLAKE` | `~/src/fern` of the host's user | `programs.nh.flake` in `modules/cli/nh.nix` | fern, yarrow |
| `NIX_LD`, `NIX_LD_LIBRARY_PATH` | nix-ld loader and library path | `programs.nix-ld.enable` in `modules/core.nix` | fern, yarrow |
| `CFLAGS`, `CXXFLAGS` | `-fstack-protector-strong -Wl,-z,relro,-z,now` | `modules/devtools/c-cpp.nix` | fern, yarrow |
| `RUST_SRC_PATH` | Standard library source of the stable toolchain | `modules/devtools/rust.nix` (also set in the user session) | fern, yarrow |
| `ADA_PROJECT_PATH` | `$HOME/.config/ada_project_path` | `modules/devtools/ada.nix` | fern, yarrow |
| `AWS_SDK_LOAD_CONFIG` | `1` | `modules/cloud/aws-cli.nix` | fern, yarrow |
| `LD_LIBRARY_PATH` | PipeWire's JACK libraries | `services.pipewire.jack.enable` in `modules/audio/audio.nix` | fern, yarrow |
| `VST_PATH`, `VST3_PATH`, `LXVST_PATH`, `LV2_PATH`, `LADSPA_PATH`, `DSSI_PATH`, `CLAP_PATH` | Per-format plugin search paths: `~/.<format>`, the user profile, the system profile | musnix, imported by `modules/audio/audio-studio.nix` | fern |

The toolchain variables come from the `nixos` sides of aspects in the
`devtools` bundle. That bundle is forwarded to users, and a forwarded
aspect applies both of its sides on a NixOS host, which is how a user
layer ends up setting system variables.

`CFLAGS` and `CXXFLAGS` apply to every build run from a shell on these
hosts, including ones that do not expect linker flags in `CFLAGS`.

## User session variables

| Variable | Value | Set in | Goes on |
| --- | --- | --- | --- |
| `EDITOR`, `VISUAL` | `hx` | `programs.helix.defaultEditor` in `modules/cli/helix.nix` | every machine |
| `MANPAGER` | `sh -c 'col -bx \| bat -l man -p'` | `modules/cli/bat.nix` | every machine |
| `TERMINFO_DIRS` | Kitty's and Ghostty's terminfo directories | `modules/cli/kitty.nix` (forced; overrides the value in `modules/desktop/hyprland.nix`) | every machine |
| `SOPS_AGE_KEY_FILE` | `$HOME/.config/sops/age/keys.txt` | `modules/shells/nushell.nix` (a session variable, not a Nushell one) | every machine |
| `RUST_SRC_PATH` | Standard library source of the stable toolchain | `modules/devtools/rust.nix` | every machine |
| `CMAKE_PREFIX_PATH`, `PKG_CONFIG_PATH` | Store paths of the game libraries | `modules/devtools/gamedev.nix` | every machine |
| `BROWSER` | `zen-twilight` | `programs.zen-browser.setAsDefaultBrowser` in `modules/desktop/zen.nix` | every machine |
| `NIXOS_OZONE_WL` | `1` | `modules/desktop/chromium.nix` | fern, yarrow |
| `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME` | Standard locations under `~` | `xdg.enable` in `modules/workspace.nix` | every machine |
| `XDG_DOWNLOAD_DIR` | `~/inbox` | `xdg.userDirs` in `modules/workspace.nix` | every machine |
| `XDG_DOCUMENTS_DIR` | `~/docs` | same | every machine |
| `XDG_PICTURES_DIR`, `XDG_VIDEOS_DIR`, `XDG_MUSIC_DIR` | `~/media/pictures`, `~/media/video`, `~/media/music` | same | every machine |
| `XDG_DESKTOP_DIR`, `XDG_PUBLICSHARE_DIR`, `XDG_TEMPLATES_DIR` | `~` (the "disabled" value) | same | every machine |
| `XDG_PROJECTS_DIR` | `~/Projects` | Home Manager's default for `xdg.userDirs`; `modules/workspace.nix` does not override it | every machine |
| `BAT_THEME` | `garden` | The garden terminal stack (garden-shell flake) | every machine |
| `LG_CONFIG_FILE` | lazygit's config plus the garden theme file | The garden terminal stack (garden-shell flake) | every machine |
| `DOCKER_HOST` | `unix://$XDG_RUNTIME_DIR/docker.sock` | `modules/foreign/docker-rootless.nix` | work laptop |
| `THEODOLITE_DATA` | A data directory under `~/work/src` | `modules/cli/theodolite.nix` | work laptop |
| `XDG_DATA_DIRS` | Nix profile share directories ahead of the distribution's | `targets.genericLinux` in `modules/foreign/ubuntu-desktop.nix` | work laptop |

The directory layout behind the `XDG_*_DIR` values is described on
[Home Directory](home-directory.md).

The game library paths are in every shell on a machine that carries
`gamedev`, not only inside a project environment, so CMake and
pkg-config find those libraries by default.

## Variables set inside one shell

These are not in `home.sessionVariables`. A program started from the
desktop, or from a different shell, does not see them.

### Nushell (`modules/shells/nushell.nix`)

| Variable | Value | Note |
| --- | --- | --- |
| `EDITOR`, `VISUAL` | `hx` | Same as the session value |
| `PAGER` | `delta` | Differs from the session, where `PAGER` is the system default `less` |
| `GIT_PAGER` | `delta` | Not set outside Nushell; git uses delta there through its own configuration |
| `LESSHISTFILE` | `-` | Disables the `less` history file |
| `SSH_AUTH_SOCK` | `$XDG_RUNTIME_DIR/ssh-agent` | Written by Home Manager's ssh-agent integration when the variable is not already set |

### fish (`modules/shells/fish.nix`)

| Variable | Value | Note |
| --- | --- | --- |
| `GARDEN_CHANNEL` | Name of the focused Niri workspace | Exported on every prompt when `niri` is available; shown in the right prompt |

The right prompt also reads `GARDEN_PAGE`, `SSH_CONNECTION`,
`IN_NIX_SHELL` and `VIRTUAL_ENV`, none of which this configuration
sets.

### zsh (`modules/shells/zsh.nix`)

| Variable | Value | Note |
| --- | --- | --- |
| `KEYTIMEOUT` | `1` | Short escape delay for vi mode |
| `MANPAGER` | Same as the session value | Set again when `bat` is on `PATH`, so the copied `~/.zshrc` works on a machine without this configuration |

## Regenerating this page

```bash
# NixOS hosts: replace fern with yarrow for the other host
nix eval --json .#nixosConfigurations.fern.config.environment.variables
nix eval --json .#nixosConfigurations.fern.config.environment.sessionVariables
nix eval --json .#nixosConfigurations.fern.config.home-manager.users.ada.home.sessionVariables

# the standalone home
nix eval .#homeConfigurations --apply builtins.attrNames
nix eval --json '.#homeConfigurations."<user>@<hostname>".config.home.sessionVariables'
```

To find which module sets a system variable:

```bash
nix eval --json .#nixosConfigurations.fern.options.environment.variables.files
```

Shell-local variables are in the module text; search for `$env.` in
`modules/shells/nushell.nix`, `set -gx` in `modules/shells/fish.nix`
and `export` in `modules/shells/zsh.nix`.

## Key files

| File | Sets |
| --- | --- |
| `modules/cli/nh.nix`, `modules/core.nix` | `NH_FLAKE`, nix-ld variables |
| `modules/devtools/*.nix`, `modules/cloud/aws-cli.nix` | Toolchain variables, system and session |
| `modules/audio/audio.nix`, `modules/audio/audio-studio.nix` | JACK library path, plugin paths |
| `modules/cli/helix.nix`, `bat.nix`, `kitty.nix` | Editor, man pager, terminfo |
| `modules/workspace.nix` | XDG base and user directories |
| `modules/shells/nushell.nix`, `fish.nix`, `zsh.nix` | Shell-local variables; `SOPS_AGE_KEY_FILE` |
| `modules/foreign/*.nix` | Work-laptop session variables |
