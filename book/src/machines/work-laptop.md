# The work laptop (standalone home on Ubuntu)

> A machine that must run Ubuntu still gets the Niri + garden desktop
> from this flake: no NixOS install, just a multi-user Nix daemon, a
> standalone home-manager configuration and a few one-time root files.
> Ubuntu's GNOME session stays untouched as a fallback.
>
> This page describes the pattern and the mechanisms. Site-specific
> detail (network, VPN, authentication, internal hosts) is deliberately
> kept out of this book.

| | |
| --- | --- |
| System | Ubuntu 24.04 with sudo available; a laptop with a built-in panel |
| Topology | a `den.homes.x86_64-linux."<user>@<hostname>"` entry in `modules/hosts.nix` |
| Flake output | `homeConfigurations."<user>@<hostname>"`; there is no `nixosConfiguration` |
| Status | active |
| `home.stateVersion` | `"25.11"`, pinned in `modules/user-ada-work.nix`; never bumped |
| Graphics | host drivers, reached through nixGL (Mesa wrapper) |

## How it fits together

Instead of a host, the laptop is a **standalone den home**:

```nix
den.homes.x86_64-linux."<user>@<hostname>" = {
  aspect = "ada";   # the local login reuses the ada aspect
  pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
  instantiate = { pkgs, modules }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs modules;
      extraSpecialArgs = { inherit inputs; };
    };
};
```

- The `"user@host"` key becomes `homeConfigurations."user@host"`, which
  the `home-manager` CLI selects automatically when it matches
  `whoami@hostname`.
- `aspect = "ada"` maps the local user onto the existing `ada` aspect.
  Only the `homeManager` sides of aspects are evaluated; `nixos` sides
  are ignored.
- `pkgs` and `instantiate` are overridden because den's defaults use
  plain nixpkgs (no overlays, no unfree) and pass no `extraSpecialArgs`,
  and several home modules take `inputs`.
- den's mutual provider, wired for homes through `den.ctx.home.includes`
  in `modules/dendritic.nix`, routes
  `den.aspects.ada.provides."<hostname>"` into the home. That is where
  the **work layer**, `den.aspects.ada-work`
  (`modules/user-ada-work.nix`), attaches.

Three aspects do the foreign-distribution work:

- **niri-standalone** (`modules/desktop/niri-standalone.nix`) imports
  niri-flake's *home* module once at home level (there is no NixOS side
  here) and reuses the shared `den.aspects.niri` settings unchanged;
  see [Niri](../desktop/niri.md).
- **ubuntu-desktop** (`modules/foreign/ubuntu-desktop.nix`):
  - `targets.genericLinux` and **nixGL**: `programs.niri.package` is
    wrapped with the Mesa wrapper. The compositor is the root of the
    session, so everything started from it inherits the GL
    environment. `nixGLMesa` is installed for wrapping anything started
    outside the session.
  - It installs what the NixOS side of the `niri` aspect would have
    provided: `xwayland-satellite`, `quickshell`, plus `ddcutil`,
    `firefox` and `mesa-demos`.
  - It links the wrapped package's `niri.service` and
    `niri-shutdown.target` into `~/.config/systemd/user`, because
    Ubuntu's systemd does not search the Nix profile for units.
  - It installs `~/.local/bin/niri-session-shim`, the stable `Exec`
    target for the root-owned display-manager session file. The shim
    loads the Nix environment before `exec niri-session`.
  - It routes portals to Ubuntu's system `xdg-desktop-portal` (gtk
    first, then gnome).
- **docker-rootless** (`modules/foreign/docker-rootless.nix`) runs
  `dockerd` as a systemd user service: no root daemon, no `docker`
  group. See [Containers and cloud](../services/containers-and-cloud.md).

## What the work layer adds

`ada-work` is deliberately **not** `ada-desktop`: it picks its own
aspects, so the laptop has no DAWs or gaming layer, and does
not take the `desktop-apps` bundle as a whole.

### Shared aspects it includes

| Aspect | What it brings |
| --- | --- |
| `ada-dev` | the `devtools` bundle, as on [fern](fern.md#user-layers-it-forwards). Only home sides apply. Docker here is `docker-rootless`; the system daemon comes from the `workstation` role on NixOS hosts |
| `niri-standalone`, `ubuntu-desktop`, `docker-rootless` | described above |
| `garden.shell` | the garden shell bundle, which brings the garden terminal stack with it; see [Garden](../desktop/garden.md) |
| `fonts` | the font set, installed into the home profile |
| `zen` | the daily browser; see [Browsers](../desktop/browsers.md) |
| isolated Chrome launcher | a launcher around an apt-installed Chrome with its own profile, for one site that requires Chrome; see [Browsers](../desktop/browsers.md) |
| `thunderbird` | mail; see [Mail](../desktop/mail.md) |
| `teams` | `teams-for-linux`, wrapped with `--no-sandbox` on a non-NixOS system |
| `imv`, `pdf`, `obsidian` | image viewer, PDF tools, notes |
| `wallpaper` | painted wallpapers behind the Niri session; see [Wallpaper](../desktop/wallpaper.md). This is the only place the aspect is included |
| `cursor` | the chrome key pointer; see [Niri](../desktop/niri.md#pointer) |
| `duckdb`, `postgres`, `rustfs` | data clients; see [Data tools](../toolchains/data-tools.md) |
| `gamedev` | game libraries and tools; see [Gamedev and art](../gamedev/gamedev-and-art.md) |
| `audio-tools` | the plugin and synth collection, without the DAWs; see [Audio](../services/audio.md) |

It also includes one small site-specific aspect that only sets an
environment variable for a data directory, and it installs
`brightnessctl`, `pandoc`, `glow` and `zotero` directly.

### Channels and app pinning

The laptop defines its own channel table in a `let` block at the top of
`modules/user-ada-work.nix`. Keybinds, workspaces and window rules are
all generated from it.

| Key | Channel | Apps pinned to it |
| --- | --- | --- |
| `Mod+0` | zen | none; see zen mode below |
| `Mod+1` | studio | — |
| `Mod+2` | research | — |
| `Mod+3` | writing | Obsidian, Zotero |
| `Mod+4` | music | — |
| `Mod+5` | system | `btop` in kitty |
| `Mod+6` | laptop | none; reserved for the built-in panel |
| `Mod+7` | browser | Zen, and any Chrome, Chromium or Firefox window |
| `Mod+8` | comms | Teams, Thunderbird |

- `Mod+<key>` goes to the channel; `Mod+Shift+<key>` sends the focused
  window there (not for zen).
- Channels 1 to 5 have the same names as the shared ones in the `niri`
  aspect. The laptop's binds replace the shared ones with `mkForce`.
- A pinned app always *opens* on its channel, through a window rule;
  it can be moved away afterwards. The rules are appended with
  `mkAfter`, so they win over shared rules such as the one in
  `modules/desktop/zen.nix`.
- Terminals are not pinned: they open wherever you are.
- `Mod+B` goes to the browser channel instead of opening a new browser
  window.

### `garden-channel`

Channels that list an app with a `run` command are bound to a helper
script, `garden-channel <name>`, instead of a plain `focus-workspace`:

1. It focuses the channel.
2. If the channel is empty, it starts each of the channel's apps that
   has a `run` command and no window anywhere in the session. An app
   already running on another channel is left where it is.
3. A stamp file in `$XDG_RUNTIME_DIR` stops a second key press within
   ten seconds from starting the apps twice.

Apps pinned without a `run` command (the non-default browsers) are
placed but never started.

### Zen mode

A single centred pane on the wallpaper, for reading or writing.

| Key | Action |
| --- | --- |
| `Mod+Z` | move the focused window to the zen channel, floating, 75% of the screen height and centred; pressed again, send it back to the workspace it came from at its earlier width |
| `Mod+0` | go to the zen channel without bringing a window |
| `Mod+R` | cycle the 50 / 75 / 100% preset widths; a floating pane is re-centred afterwards |

Zen holds one window at a time: sending another one there returns the
current occupant first. Widths are stored as percentages of the output
in `$XDG_RUNTIME_DIR/niri-zen/`, so a pane keeps its proportions when
the workspace moves between screens. The scripts are `niri-zen`,
`niri-zen-fit` and `niri-cycle-width`.

Outside zen, `layout.always-center-single-column` centres a column that
is alone on its workspace; two or more columns scroll as on the other
machines.

### Docking to an external ultrawide

- **Outputs**: the external monitor is matched by its make, model and
  serial (connector names change between docks and ports) and placed
  above the built-in panel, with the panel centred beneath it.
- **Workspaces**: every channel has `open-on-output` set to the
  external monitor; the `laptop` channel is pinned to the panel. Niri
  moves named workspaces to their output when it connects and back to
  the panel when it disconnects.
- **`garden-undock`**: a systemd user service that watches Niri's event
  stream. On every dock and undock it puts the channels back in order
  (Niri does not preserve it) and refits the zen pane. On undock it
  also moves `laptop` after the named channels and refocuses the
  channel that was showing on the external monitor, so `Mod+1` and the
  rest keep pointing at the right places.
- Docking with the lid closed needs no configuration here.

### Brightness

The work layer binds the brightness keys itself, with `mkForce`:
`XF86MonBrightnessUp` and `XF86MonBrightnessDown` run
`brightnessctl set 5%+` and `5%-` against the panel's sysfs backlight.
It does not include the `brightness-backlight` aspect that
[yarrow](yarrow.md) uses, which binds the same keys with a 1% floor;
here the panel can be stepped down to zero.

The garden shell only *reads* brightness. Its `BrightnessService`
chooses a backend once at startup: if `/sys/class/backlight` has a
device it polls that file every 500 ms, otherwise it polls
`ddcutil getvcp 10` every 3 s. A change in the value triggers the
on-screen display, so the `brightnessctl` binds need no IPC call. On a
laptop the backlight backend is always chosen, so the shell shows the
panel's brightness, not the external monitor's. `ddcutil` is installed
for setting an external monitor by hand; no key is bound to it.

### Lock and idle

The shared `niri` aspect locks after ten idle minutes and before sleep
through swayidle, and binds `Mod+Alt+L` to the garden lock. The work
layer turns both off: `services.swayidle.enable` is forced to `false`
and `Mod+Alt+L` is rebound to a no-op. The reason is under
[Known rough edges](#known-rough-edges).

### GitHub over HTTPS

The shared git configuration rewrites `https://github.com/` URLs to
SSH ([Git](../git/git.md)). The work layer replaces that rewrite with
the reverse, for `github.com` and `gist.github.com`: remotes written as
`git@github.com:` or `ssh://git@github.com/` go over HTTPS, with `gh`
supplying the credential. Existing clones need no change. Commit
signing is SSH-key based and local, so it is unaffected. Pushing
workflow files needs the token's `workflow` scope:
`gh auth refresh -s workflow`.

The layer also carries SSH host blocks and shell abbreviations for
site systems; they are not documented here.

## One-time root files

Everything root-owned on the Ubuntu side. Steps 1 and 2 come before the
first switch; step 4 after it, because it points at a file the switch
creates.

1. **Multi-user Nix**, with flakes enabled. If the network intercepts
   TLS, point `ssl-cert-file` in `/etc/nix/nix.conf` at the site's CA
   bundle.
2. **`/etc/nix/nix.conf`**: add the user to `trusted-users` and the
   niri and nix-community caches to `extra-substituters` (with their
   public keys), then `sudo systemctl restart nix-daemon`.
3. **First `home-manager switch`**; see the next section.
4. **`/usr/share/wayland-sessions/niri.desktop`**:

   ```ini
   [Desktop Entry]
   Name=Niri (garden)
   Comment=Scrollable-tiling Wayland compositor (Nix-managed)
   Exec=/home/<user>/.local/bin/niri-session-shim
   Type=Application
   DesktopNames=niri
   ```

   GDM offers this next to the GNOME session.
5. *Optional, docked external monitors*: load `i2c-dev`, create an `i2c`
   group with a udev rule for `/dev/i2c-*` and add the user, so
   `ddcutil` works without root.
6. **apt-side dependencies**, all present on a default Ubuntu desktop:
   `xdg-desktop-portal` with the gtk and gnome backends, PipeWire and
   WirePlumber (`wpctl` drives the volume keys).

### Rootless Docker

Root-side prerequisites for the `docker-rootless` aspect:

```bash
sudo apt install uidmap dbus-user-session
grep "$USER" /etc/subuid /etc/subgid   # subordinate id ranges must exist
# if absent:
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
```

**If apt is unreachable**, Nix can supply what `uidmap` provides. The
store cannot hold setuid binaries, so install setuid *copies* by hand;
they only load world-readable store libraries, so copies work:

```bash
nix build --inputs-from ~/src/fern 'nixpkgs#shadow' -o /tmp/nix-shadow
sudo install -m 4755 -o root -g root "$(readlink -f /tmp/nix-shadow)/bin/newuidmap" /usr/local/bin/newuidmap
sudo install -m 4755 -o root -g root "$(readlink -f /tmp/nix-shadow)/bin/newgidmap" /usr/local/bin/newgidmap
```

The docker user unit's `PATH` includes `/usr/local/bin` for this reason.

Ubuntu 24.04 restricts unprivileged user namespaces through AppArmor, so
the Nix-store `rootlesskit` needs a profile. The glob keeps working when
the store path changes (`/etc/apparmor.d/nix-rootlesskit`):

```
abi <abi/4.0>,
include <tunables/global>

profile nix-rootlesskit /nix/store/*/bin/rootlesskit flags=(unconfined) {
  userns,
  include if exists <local/nix-rootlesskit>
}
```

Then `sudo apparmor_parser -r /etc/apparmor.d/nix-rootlesskit`, and
after the next switch:

```bash
systemctl --user status docker
docker info | grep -i rootless   # DOCKER_HOST is set by the home config
docker run --rm hello-world
```

### Chromium-family browsers come from apt, not Nix

The same AppArmor restriction means a Chromium-family browser only gets
its sandbox with a root-owned SUID helper or an AppArmor profile that
grants `userns` to a fixed path. Vendor `.deb` packages ship both; a
Nix-store binary can have neither and would have to run `--no-sandbox`.
So the daily browser is Zen (Firefox-based, from Nix), and where a
Chrome is required it is installed from the vendor's apt repository and
only *launched* from Nix; see [Browsers](../desktop/browsers.md).

## First deploy

1. Root steps 1 and 2, then log out and in so the Nix profile scripts
   load.
2. Clone the flake to `~/src/fern`.
3. Create SSH keys and service credentials by hand. sops provisioning
   is NixOS-side only ([sops-nix](../security/sops-nix.md)), and
   connection details (database services, object store aliases) stay
   out of this repository: the modules install the clients, and the
   configuration lives in the usual per-user files
   (`~/.pg_service.conf`, `~/.pgpass`, `~/.config/rc/config.toml`).
4. Bootstrap the home, since `home-manager` is not on `PATH` yet:

   ```bash
   cd ~/src/fern
   nix build ".#homeConfigurations.\"$USER@$(hostname)\".activationPackage"
   ./result/activate
   ```

   On file collisions, move the offender aside, or re-run with
   `HOME_MANAGER_BACKUP_EXT=backup`. From then on:

   ```bash
   home-manager switch --flake ~/src/fern   # selects user@host itself
   ```

5. Root step 4, then `systemctl --user daemon-reload`.
6. Log out and choose "Niri (garden)" in GDM. Check:
   - `niri msg outputs` and `systemctl --user status niri.service`
   - the garden bar renders; `Mod+Slash` opens the launcher
   - `nixGLMesa glxinfo | grep renderer` shows the real GPU
   - the `Mod+S` screenshot flow and the brightness keys
   - `git -C ~/src/work/<repo> config user.email` shows the work identity
   - Ubuntu's GNOME session still starts

## Day to day

```bash
home-manager switch --flake ~/src/fern
home-manager expire-generations now && nix-collect-garbage -d
```

The `just` system recipes (`just switch`, `just test`) call `nh os …`
and are for NixOS hosts; they do not apply here. The rest of the
routine is in [Day to day](../operations/day-to-day.md).

Bumping the shared nixpkgs pin is expensive on this machine: packages
built through the flake's overlays are not in the public cache, so a
bump has meant several hundred local source builds. When one package
needs to be newer, take it from a separate, non-following nixpkgs input
instead (see the `nixpkgs-uv` and `nixpkgs-thunderbird` inputs in
`flake.nix`).

## Known rough edges

- **Lock screen**: the garden lock and swaylock both authenticate
  through PAM from inside the Nix closure, which cannot drive a host PAM
  stack that needs multi-step or hardware-token conversations. That is
  why the work layer disables the idle lock and unbinds `Mod+Alt+L`.
  Lock by switching to the display manager's VT (`Ctrl+Alt+F1`), which
  uses the host stack natively. Nothing locks the session automatically,
  including before suspend.
- **Inherited `LD_LIBRARY_PATH`**: everything in the session inherits
  the nixGL environment, including Ubuntu-native applications launched
  from it. If one misbehaves, start it with a clean environment.
- **Portals**: `xdg-desktop-portal-gnome` under
  `XDG_CURRENT_DESKTOP=niri` is lightly tested; screencasting is
  untested.
- **Network**: TLS interception can break substituters for the daemon
  (root step 1).

## Key files

| File | Purpose |
| --- | --- |
| `modules/hosts.nix` | the `den.homes` entry |
| `modules/user-ada-work.nix` | the work layer: includes, channels, zen mode, docking, overrides |
| `modules/desktop/niri-standalone.nix` | niri-flake home module for a standalone home |
| `modules/foreign/ubuntu-desktop.nix` | nixGL, session units, session shim, portals |
| `modules/foreign/docker-rootless.nix` | rootless Docker user service |
| `modules/dendritic.nix` | `den.ctx.home.includes`, which routes the layer into the home |
