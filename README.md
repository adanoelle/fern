# 🌱 Fern — NixOS + Home-Manager Flake

Fern is my personal, reproducible NixOS desktop system, built to:

- **Declaratively define everything** — from bootloader to Wayland compositor —
  so a full rebuild or new machine setup is one command away.
- **Use Flakes + Home-Manager** for clean separation of **system-level** and
  **user-level** configuration.
- **Modularize by feature** — making it easy to toggle components (e.g.,
  desktop, devtools, shells) per host.
- **Support a Hyprland-based desktop** with integrated Waybar, Hypridle,
  Hyprlock, and Hyprpaper, all styled consistently via Catppuccin Frappé.
- **Keep multi-host ready** — so the same repo can configure desktops, laptops,
  and servers with shared modules.

---

## 🗂 Repository Structure

```
.
├── flake.nix                 # Main flake definition
├── flake.lock                # Lock file for pinned inputs
├── flake.parts/               # Flake-parts modular definitions
│   ├── 00-overlay.nix         # Custom overlays
│   ├── 10-core.nix            # Shared flake outputs (systems, packages)
│   ├── 20-nixos-mods.nix      # All NixOS module imports
│   ├── 30-home-mods.nix       # All Home-Manager module imports
│   └── 40-hosts.nix           # Per-host NixOS configurations
├── hosts/
│   └── fern/
│       ├── configuration.nix  # System + HM imports + host toggles
│       └── hardware.nix       # Generated hardware profile
├── nix/
│   ├── modules/               # NixOS modules (system level)
│   │   ├── audio.nix
│   │   ├── boot.nix
│   │   ├── graphics.nix
│   │   ├── desktop/           # Desktop-specific modules (e.g. greetd)
│   │   ├── users.nix
│   │   └── …other feature modules…
│   ├── home/                  # Home-Manager modules (user level)
│   │   ├── cli/               # CLI tool modules (bat, git, ghostty, etc.)
│   │   ├── desktop/           # Hyprland + Waybar + idle/lock/wallpaper
│   │   ├── devtools/          # Language/stack toolchains
│   │   ├── shells/            # Nushell, Starship, Zoxide
│   │   ├── workspace.nix      # XDG user dirs layout
│   │   └── …other user modules…
│   └── README.md              # (This file)
├── secrets/                   # SOPS-managed secrets
│   └── main.yaml
└── README.md                  # You are here
```

---

## 💻 Desktop Overview

The `nix/home/desktop/hyprland.nix` module defines a **toggleable** Hyprland
setup:

- **Hyprland compositor** with declarative keybinds, mouse binds, and style
  settings.
- **Waybar** (`desktop.hyprland.bar.enable`) — with Catppuccin Frappé styling,
  workspace module, CPU/mem/audio/clock.
- **Hypridle** (`desktop.hyprland.idle.enable`) — idle → dim, lock, suspend.
- **Hyprlock** (`desktop.hyprland.lock.enable`) — lock screen with blur + Frappé
  palette.
- **Hyprpaper** (`desktop.hyprland.wallpaper.enable`) — static wallpaper per
  monitor.
- **Style variables** (`desktop.hyprland.style`) — gaps, border size, colours —
  applied consistently.

**Monitor-specific wallpaper**: Set `desktop.hyprland.wallpaper.monitor` to the
name from `hyprctl monitors` (`HDMI-A-1` in my case).

---

## ⚙ How to Use

### Build / Rebuild

```bash
# Switch system + user config
sudo nixos-rebuild switch --flake .#fern
home-manager switch --flake .#ada
```

### Toggle desktop features

In `hosts/fern/configuration.nix`, inside `home-manager.users.ada`:

```nix
desktop.hyprland = {
  enable     = true;
  bar.enable = true;
  idle.enable = true;
  lock.enable = true;
  wallpaper = {
    enable  = true;
    path    = "/home/ada/wallpapers/shrine.png";
    monitor = "HDMI-A-1";
  };
  style = { gapsIn = 6; gapsOut = 12; border = 2; };
};
```

---

## 🔑 Secrets

Secrets are stored in `secrets/main.yaml` and managed via
[sops-nix](https://github.com/Mic92/sops-nix). Keys are generated per-machine
and stored under `/var/lib/sops-nix/key.txt`.

---

## 🛠 Development Tooling

- **Language toolchains** via HM modules: Rust (`nix/home/devtools/rust.nix`),
  TypeScript, Zig, etc.
- **CLI utilities** grouped by topic under `nix/home/cli/`.
- **Shells**: Nushell as primary, Starship prompt, Zoxide for jump navigation.

---

## 📦 Why Flake-Parts?

The flake is composed using [flake-parts](https://flake.parts/) for:

- Structured imports of NixOS + HM modules.
- Clear separation between _definitions_ (`nix/modules`, `nix/home`) and
  _enabling/toggling_ (`hosts/<name>/configuration.nix`).
- Easy to extend to more hosts — just add another entry to
  `flake.parts/40-hosts.nix`.

---

## 🛣 Roadmap / Future Ideas

- **Dynamic wallpapers** per workspace (via `swww`).
- **Different lock screen background** from desktop wallpaper.
- **Multi-monitor wallpaper config** in `desktop.hyprland.wallpaper` as a list.
- **Idle/lock integration** with media pause/resume hooks.
- More CI/CD: `nix flake check`, formatting (`nixfmt`), dead code detection
  (`deadnix`).

---

## 📜 License

This repository is personal configuration — feel free to browse and adapt ideas,
but use at your own risk.
