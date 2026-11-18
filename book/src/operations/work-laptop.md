# Standalone Home on Ubuntu (Work Laptop)

> How a machine that must run Ubuntu still gets the niri + garden desktop
> from this flake: no NixOS install, just a multi-user Nix daemon, a
> standalone home-manager configuration and a few one-time root files.
> Ubuntu's GNOME session stays untouched as a fallback.
>
> This page describes the pattern. Site-specific detail (network, VPN,
> authentication, internal hosts) is deliberately kept out of this
> repository's documentation.

## How it fits together

The laptop runs Ubuntu 24.04 with sudo available. Instead of a
`nixosConfiguration` it gets a **standalone den home**, declared in
`modules/hosts.nix`:

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
- `aspect = "ada"` maps the local user onto the existing ada aspect.
  Only the `homeManager` sides of aspects are evaluated; `nixos` sides
  are ignored.
- `pkgs` and `instantiate` are overridden because den's defaults use
  plain nixpkgs (no overlays, no unfree) and pass no `extraSpecialArgs`,
  and several home modules take `inputs`.
- den's mutual provider (wired for homes through `ctx.home.includes` in
  `modules/dendritic.nix`) routes
  `den.aspects.ada.provides."<hostname>"` into the home. That is where
  the **ada-work** layer attaches (`modules/user-ada-work.nix`): the dev
  toolchain, niri, the garden shell and the work applications.

Aspects specific to a foreign distribution:

- **niri-standalone** (`modules/desktop/niri-standalone.nix`) imports
  niri-flake's *home* module once at home level (there is no NixOS side
  here) and reuses the shared `den.aspects.niri` settings unchanged.
- **ubuntu-desktop** (`modules/foreign/ubuntu-desktop.nix`) does the
  foreign-distro work:
  - `targets.genericLinux` and **nixGL**: `programs.niri.package` is
    wrapped with the mesa wrapper. The compositor is the root of the
    session, so everything started from it inherits the GL environment.
  - It links the wrapped package's `niri.service` and
    `niri-shutdown.target` into `~/.config/systemd/user`, because
    Ubuntu's systemd does not search the Nix profile for units.
  - It installs `~/.local/bin/niri-session-shim`, the stable `Exec`
    target for the root-owned display-manager session file. The shim
    loads the Nix environment before `exec niri-session`.
  - It routes portals to Ubuntu's system `xdg-desktop-portal`.
- **docker-rootless** (`modules/foreign/docker-rootless.nix`) runs
  `dockerd` as a systemd user service: no root daemon, no `docker`
  group.
- **ada-work** overrides a few shared niri binds for the laptop (panel
  brightness through `brightnessctl`, its own channel layout) and
  disables the idle lock; see "Known rough edges".

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
   group with a udev rule for `/dev/i2c-*` and add the user, for
   `ddcutil` brightness control.
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
   is NixOS-side only, and connection details (database services, object
   store aliases) stay out of this repository: the modules install the
   clients, and the configuration lives in the usual per-user files
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
and are for NixOS hosts; they do not apply here.

Bumping the shared nixpkgs pin is expensive on this machine: packages
built through the flake's overlays are not in the public cache, so a
bump has meant several hundred local source builds. When one package
needs to be newer, take it from a separate, non-following nixpkgs input
instead (see the `nixpkgs-uv` and `nixpkgs-thunderbird` inputs in
`flake.nix`).

## Known rough edges

- **Lock screen**: the garden lock and swaylock both authenticate
  through PAM from inside the Nix closure, which cannot drive a host PAM
  stack that needs multi-step or hardware-token conversations. On such a
  machine the idle lock is disabled and `Mod+Alt+L` is unbound; lock by
  switching to the display manager's VT (`Ctrl+Alt+F1`), which uses the
  host stack natively.
- **Inherited `LD_LIBRARY_PATH`**: everything in the session inherits
  the nixGL environment, including Ubuntu-native applications launched
  from it. If one misbehaves, start it with a clean environment.
- **Portals**: `xdg-desktop-portal-gnome` under
  `XDG_CURRENT_DESKTOP=niri` is lightly tested; screencasting is
  untested.
- **Network**: TLS interception can break substituters for the daemon
  (root step 1).
