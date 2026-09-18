# Work Laptop (Ubuntu + Standalone Home)

> How the ORNL work laptop runs the full niri + garden desktop from this
> flake on Ubuntu 24.04 — no NixOS install, just a multi-user Nix daemon,
> a standalone home-manager configuration, and a handful of one-time root
> files. Ubuntu's GNOME session stays untouched as a fallback.

## How it fits together

ORNL IT requires Ubuntu (24.04 LTS, full-disk encryption with key
escrow), but grants full sudo. Instead of a `nixosConfiguration`, the
laptop gets a **standalone den home**:

```nix
# modules/hosts.nix
den.homes.x86_64-linux."tyo@LAP155464" = {
  aspect = "ada";   # ORNL login reuses the ada aspect
  pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
  instantiate = { pkgs, modules }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs modules;
      extraSpecialArgs = { inherit inputs; };
    };
};
```

- The `"user@host"` key becomes `homeConfigurations."user@host"`, which
  the `home-manager` CLI auto-selects when it matches `whoami@hostname`.
- `aspect = "ada"` maps the ORNL user id onto the existing ada aspect;
  only `homeManager` sides of aspects evaluate (nixos sides are ignored).
- `pkgs`/`instantiate` are overridden because den's defaults use plain
  nixpkgs (no claude-code overlay, no allowUnfree) and pass no
  `extraSpecialArgs` (devtools/devenv.nix needs `inputs`).
- den's `mutual-provider` (wired for homes via `ctx.home.includes` in
  `modules/dendritic.nix`) routes `den.aspects.ada.provides."LAP155464"`
  into the home — this is where the **ada-work** layer attaches
  (`modules/user-ada-work.nix`): dev toolchain + niri + garden shell,
  deliberately without ada-desktop (no hyprland/DAW/gaming).

Aspects specific to the foreign distro:

- **niri-standalone** (`modules/desktop/niri-standalone.nix`) imports
  niri-flake's *home* module once at home level (there is no NixOS-side
  bridge here) and reuses the shared `den.aspects.niri` settings —
  keybinds, workspaces, swayidle, garden IPC — verbatim.
- **ubuntu-desktop** (`modules/foreign/ubuntu-desktop.nix`) does the
  foreign-distro heavy lifting:
  - `targets.genericLinux` + **nixGL**: `programs.niri.package` is
    wrapped with the mesa wrapper. The compositor is the root of the
    session tree, so quickshell, kitty, xwayland-satellite and firefox
    all inherit the GL environment. `nixGLMesa` is installed for ad-hoc
    wrapping. If niri-flake's sandboxed `niri validate` ever breaks on
    the wrapped package, fall back to plain `pkgs.niri` and override
    `niri.service`'s ExecStart with `nixGLMesa niri --session`.
  - links the wrapped package's `niri.service` / `niri-shutdown.target`
    into `~/.config/systemd/user` (Ubuntu's systemd doesn't search the
    Nix profile for units),
  - installs `~/.local/bin/niri-session-shim`, the stable Exec target
    for the root-owned GDM session file (it bootstraps the Nix env
    before `exec niri-session`),
  - routes portals to Ubuntu's system `xdg-desktop-portal`
    (`niri-portals.conf`: gtk first, gnome for screencast).
- **ada-work** overrides the brightness keys to `brightnessctl` (the
  shared niri aspect binds `ddcutil`, which is DDC/CI for external
  monitors only — laptop panels need sysfs backlight).

The ORNL user id (`tyo`) and hostname (`LAP155464`) are baked into
`modules/hosts.nix`, `modules/user-ada-work.nix`, and the work git
identity in `modules/user-ada.nix`.

## One-time root checklist (Ubuntu)

Everything root-owned on the Ubuntu side, in order. Steps 1–2 come
before the first switch; steps 4–5 after it (they reference files the
switch creates).

1. **Multi-user Nix** — use the Determinate installer (flakes enabled by
   default). If ORNL intercepts TLS, point `ssl-cert-file` in
   `/etc/nix/nix.conf` at the corporate CA bundle.
2. **`/etc/nix/nix.conf`** — add:

   ```
   trusted-users = root tyo
   extra-substituters = https://niri.cachix.org https://nix-community.cachix.org
   extra-trusted-public-keys = niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

   then `sudo systemctl restart nix-daemon`.
3. **First `home-manager switch`** — see the runbook below. Must happen
   before step 4 so `~/.local/bin/niri-session-shim` exists.
4. **`/usr/share/wayland-sessions/niri.desktop`**:

   ```ini
   [Desktop Entry]
   Name=Niri (garden)
   Comment=Scrollable-tiling Wayland compositor (Nix-managed)
   Exec=/home/tyo/.local/bin/niri-session-shim
   Type=Application
   DesktopNames=niri
   ```

   GDM picks this up next to Ubuntu's GNOME session; GNOME is untouched.
5. **`/etc/pam.d/swaylock`** — the garden lock screen's PamContext uses
   the `swaylock` service name (auth-only stack):

   ```
   auth include common-auth
   ```

6. *Optional (docked external monitors)*: load `i2c-dev`
   (`/etc/modules-load.d/i2c.conf`), create an `i2c` group with a udev
   rule for `/dev/i2c-*`, and add the user — enables `ddcutil`
   brightness control.
7. *Optional*: add the Nix-profile `fish` to `/etc/shells` and `chsh`.
   Recommended: keep bash as the login shell initially — the GDM session
   choice is shell-independent and kitty launches fish itself.
8. **Verify apt-side deps** (all present on a default Ubuntu GNOME
   install): `xdg-desktop-portal` + gtk/gnome backends, PipeWire +
   WirePlumber (`wpctl` drives the volume binds).
9. *Optional (containers — rootless Docker)*: the home config runs
   `dockerd` rootless as a systemd user service
   (`modules/foreign/docker-rootless.nix`, included by ada-work); no
   root daemon, no `docker` group. First deployed 2026-08-10 for
   theodolite's DeGAUSS comparative benchmark
   ([adanoelle/theodolite#16](https://github.com/adanoelle/theodolite/pull/16)),
   which runs the DeGAUSS geocoder container through this daemon.
   Root-side prerequisites:

   ```bash
   sudo apt install uidmap dbus-user-session
   grep tyo /etc/subuid /etc/subgid   # verify subordinate id ranges exist
   # if absent (ORNL-provisioned user):
   sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 tyo
   ```

   **apt unreachable?** ORNL wires apt to an internal mirror that only
   resolves on the lab network. `dbus-user-session` is preinstalled on
   Ubuntu desktop; the only thing `uidmap` actually provides is setuid
   `newuidmap`/`newgidmap`, and Nix can supply those. The Nix store
   cannot hold setuid binaries (this is what NixOS's `/run/wrappers`
   solves), so install setuid *copies* by hand — they only dlopen
   world-readable store libs via rpath, so copies run fine:

   ```bash
   nix build --inputs-from ~/src/fern 'nixpkgs#shadow' -o /tmp/nix-shadow
   sudo install -m 4755 -o root -g root "$(readlink -f /tmp/nix-shadow)/bin/newuidmap" /usr/local/bin/newuidmap
   sudo install -m 4755 -o root -g root "$(readlink -f /tmp/nix-shadow)/bin/newgidmap" /usr/local/bin/newgidmap
   ```

   The docker user unit's PATH includes `/usr/local/bin` for exactly
   this. `usermod` itself is in Ubuntu's base `passwd` package (always
   present), so the subuid/subgid step above works regardless.

   Ubuntu 24.04 restricts unprivileged user namespaces via AppArmor,
   so the Nix-store `rootlesskit` needs a profile — the glob attachment
   survives store-path changes across flake updates
   (`/etc/apparmor.d/nix-rootlesskit`):

   ```
   abi <abi/4.0>,
   include <tunables/global>

   profile nix-rootlesskit /nix/store/*/bin/rootlesskit flags=(unconfined) {
     userns,
     include if exists <local/nix-rootlesskit>
   }
   ```

   then `sudo apparmor_parser -r /etc/apparmor.d/nix-rootlesskit`.
   After the next `home-manager switch`, verify:

   ```bash
   systemctl --user status docker
   docker info | grep -i rootless   # DOCKER_HOST is set by the home config
   docker run --rm hello-world
   ```

   (New login shells pick up `DOCKER_HOST`; existing ones need
   `export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock`.)
10. **Google Chrome for the REPD enclave** — the enclave admins want the
    REPD portal opened in Chrome. Install it from Google's apt repo, not
    from Nix: Ubuntu 24.04 sets
    `kernel.apparmor_restrict_unprivileged_userns=1`, so a Chromium-family
    browser only gets its sandbox with a root-owned SUID helper or an
    AppArmor profile granting `userns`. Google's `.deb` ships the SUID
    helper and Ubuntu ships `/etc/apparmor.d/chrome` for
    `/opt/google/chrome/chrome`; a Nix-store Chrome would have neither
    and would have to run `--no-sandbox` (acceptable for Teams/Obsidian,
    not for an enclave browser).

    ```bash
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
      | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
      | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update && sudo apt install google-chrome-stable
    ```

    Everything around it is Nix-managed
    (`modules/foreign/repd-chrome.nix`, included by ada-work): the `repd`
    launcher runs `/opt/google/chrome/google-chrome` with its own
    `--user-data-dir` (`~/.local/share/repd-chrome`) and app-id
    `repd-chrome`, so the enclave profile shares nothing with the daily
    browser and Chrome is used for nothing else. It checks the
    GlobalProtect VPN first (`globalprotect show --status`; connects
    interactively from a terminal, warns from the launcher), strips the
    session's nixGL `LD_LIBRARY_PATH` so Chrome loads Ubuntu's mesa,
    and is not registered as an http(s) handler. Login flow inside the
    browser is unchanged: RSA SecurID PIN+token, then username/password.

    Verify:

    ```bash
    repd                       # from a terminal: VPN check, then Chrome
    ls ~/.local/share/repd-chrome/Default    # isolated profile exists
    ```

    Fallback if IT refuses the apt install: `pkgs.google-chrome` plus a
    root-installed SUID helper via `CHROME_DEVEL_SANDBOX` (Chromium
    documents it as a slightly weaker sandbox, and it needs root
    attention when the helper's API version changes). Not implemented.

## First-deploy runbook (on the laptop)

1. Root steps 1–2, then log out/in so the nix profile scripts load.
2. Clone:

   ```bash
   mkdir -p ~/src/work
   git clone https://github.com/adanoelle/fern ~/src/fern
   ```

3. Keys (manual — sops provisioning is nixos-side only):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/ornl
   # register with ORNL git hosting; optionally provision ~/.ssh/github
   ```

4. Bootstrap the home (no `home-manager` on PATH yet):

   ```bash
   cd ~/src/fern
   nix build '.#homeConfigurations."tyo@LAP155464".activationPackage'
   ./result/activate
   ```

   On file collisions, move the offender aside (or re-run activation
   with `HOME_MANAGER_BACKUP_EXT=backup`). From then on:

   ```bash
   home-manager switch --flake ~/src/fern   # auto-selects id@host
   ```

5. Root steps 4–5, then `systemctl --user daemon-reload`.
6. Log out → GDM → "Niri (garden)". Verify:
   - `niri msg outputs` and `systemctl --user status niri.service`
   - garden bar renders; `Mod+Slash` opens the launcher
   - `nixGLMesa glxinfo | grep renderer` shows the real GPU
   - `Mod+S` screenshot flow; lock (`Mod+Alt+L`) and PAM unlock
   - brightness keys (panel via brightnessctl)
   - `git -C ~/src/work/<repo> config user.email` shows the work identity
   - Ubuntu's GNOME session still boots

## Known rough edges

- **Lock screen is manual VT-switch only**: neither garden lock nor
  swaylock can authenticate with the ORNL YubiKey/PKCS#11 PAM stack.
  Garden's `PamContext` can't drive multi-step PAM conversations;
  swaylock's Nix-packaged libpam can't talk to the host `pam_pkcs11`.
  swayidle is disabled and `Mod+Alt+L` is a no-op. **Lock by pressing
  `Ctrl+Alt+F1`** (VT-switch to GDM greeter, which handles YubiKey
  auth natively, then returns to the Niri session on tty2). Automated
  idle lock would require `sudo chvt 1`, but CFEngine manages sudoers
  on this machine. See `work-laptop-preflight.md` for full history.
- Panel brightness may need the user in the `video` group (or a udev
  rule) for sysfs backlight writes; garden's BrightnessService is
  DDC-only, so the panel OSD won't track brightnessctl yet.
- Portal quirks: `xdg-desktop-portal-gnome` under
  `XDG_CURRENT_DESKTOP=niri` is lightly tested; screencast is untested.
  Watch for a gnome-keyring double-daemon (Ubuntu autostarts one; the
  home config also enables the HM service).
- `LD_LIBRARY_PATH` from the nixGL-wrapped compositor is inherited by
  everything in the session, including Ubuntu-native apps launched from
  it. If a native app misbehaves, launch it with a clean env (or wrap it
  per-app instead).
- ORNL network: TLS interception can break substituters for the daemon
  (root checklist step 1); check whether IT policy prefers the snap
  Firefox over the Nix one. The daily browser is now Zen (Nix, via
  `den.aspects.zen`); the Nix Firefox stays installed as a fallback
  until the migration settles.
