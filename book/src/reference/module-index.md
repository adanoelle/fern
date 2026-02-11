# Module Index

> Complete list of all NixOS system modules and Home Manager modules with file
> paths and descriptions.

## NixOS system modules

Registered in `flake.parts/20-nixos-mods.nix`. Imported selectively by each
host.

| Module name      | File                                     | Description                                        |
| ---------------- | ---------------------------------------- | -------------------------------------------------- |
| `ada-dev`        | `nix/modules/devtools/ada-toolchain.nix` | GNAT 13, GPRBuild, Alire                           |
| `audio`          | `nix/modules/audio.nix`                  | PipeWire, low-latency, Audient iD24, tools         |
| `aws`            | `nix/modules/cloud/aws-cli.nix`          | AWS CLI, vault, SAM, Terraform, security tools     |
| `azure-cli`      | `nix/modules/azure-cli.nix`              | Azure CLI with extensions, azcopy                  |
| `boot`           | `nix/modules/boot.nix`                   | GRUB + Zen kernel (x86_64)                         |
| `boot-asahi`     | `nix/modules/boot-asahi.nix`             | systemd-boot (Apple Silicon)                       |
| `c-dev`          | `nix/modules/devtools/c-toolchain.nix`   | GCC, Clang, CMake, hardening flags                 |
| `claude`         | `nix/modules/desktop/claude.nix`         | VS Code                                            |
| `core`           | `nix/modules/core.nix`                   | Nix experimental features, garbage collection      |
| `cursor`         | `nix/modules/desktop/cursor.nix`         | Cursor IDE                                         |
| `docker`         | `nix/modules/devtools/docker.nix`        | Docker Engine, BuildKit, Compose, utilities        |
| `fonts`          | `nix/modules/fonts.nix`                  | Nerd Fonts, fontconfig                             |
| `gaming`         | `nix/modules/gaming.nix`                 | Steam, Gamescope, GameMode, controllers            |
| `graphics`       | `nix/modules/graphics.nix`               | NVIDIA modesetting, VRR, Wayland vars              |
| `graphics-asahi` | `nix/modules/graphics-asahi.nix`         | Asahi experimental GPU driver                      |
| `greet`          | `nix/modules/desktop/greetd.nix`         | greetd, regreet, seatd, XDG portals, Polkit        |
| `guard`          | `nix/modules/secrets-guard.nix`          | git-secrets, trufflehog                            |
| `lmstudio`       | `nix/modules/desktop/lmstudio.nix`       | LM Studio AppImage wrapper                         |
| `localstack`     | `nix/modules/devtools/localstack.nix`    | LocalStack container, awslocal wrapper             |
| `rust-dev`       | `nix/modules/devtools/rust.nix`          | Stable Rust, rust-analyzer, cargo tools, hardening |
| `secrets`        | `nix/modules/secrets.nix`                | SOPS-nix, age key, SSH key decryption              |
| `sqlserver`      | `nix/modules/desktop/sqlserver.nix`      | SQL Studio                                         |
| `teams`          | `nix/modules/desktop/teams.nix`          | Microsoft Teams                                    |
| `typescript`     | `nix/modules/devtools/node-ts.nix`       | Node.js 24, pnpm, Deno, CDK, nix-ld                |
| `users`          | `nix/modules/users.nix`                  | User account, NetworkManager, SSH                  |
| `vscode`         | `nix/modules/desktop/vscode.nix`         | VS Code (alternate module)                         |

### Additional system modules (not in flake.parts registry)

These modules exist in the tree but are imported directly rather than registered
as named modules:

| File                                        | Description                  |
| ------------------------------------------- | ---------------------------- |
| `nix/modules/devtools/csharp-toolchain.nix` | .NET 8, Mono, MSBuild        |
| `nix/modules/devtools/python-toolchain.nix` | Python 3.12, uv              |
| `nix/modules/desktop/display-manager.nix`   | Wayland session files        |
| `nix/modules/desktop/caelestia-session.nix` | Caelestia QuickShell session |

## Home Manager modules

Registered in `flake.parts/30-home-mods.nix`. All six are imported by both
hosts.

### Module groups (aggregators)

| Module name | File                       | Sub-modules                                                                                                        |
| ----------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `cli`       | `nix/home/cli.nix`         | audio-tools, bat, broot, crypt, delta, ghostty, glow, helix, hyfetch, nix-tree, prettier, tree                     |
| `desktop`   | `nix/home/desktop.nix`     | chromium, gaming, hyprland, nyxt, obs, screenshot                                                                  |
| `devtools`  | `nix/home/devtools.nix`    | ada, cpp, csharp, gamedev, python, typescript, zig                                                                 |
| `git`       | `nix/home/git/default.nix` | aliases, claude-code, claude-enhanced, core, help, identities, prompts, safety, tools, worktree, worktree-enhanced |
| `shells`    | `nix/home/shells.nix`      | devenv, nushell, starship, zoxide                                                                                  |
| `workspace` | `nix/home/workspace.nix`   | XDG directory management                                                                                           |

### Hyprland sub-modules

| File                                      | Description                                |
| ----------------------------------------- | ------------------------------------------ |
| `nix/home/desktop/hyprland/core.nix`      | Compositor config, keybindings, animations |
| `nix/home/desktop/hyprland/bar.nix`       | Waybar configuration                       |
| `nix/home/desktop/hyprland/fern.nix`      | Fern Shell (QuickShell) integration        |
| `nix/home/desktop/hyprland/idlelock.nix`  | hypridle + hyprlock                        |
| `nix/home/desktop/hyprland/wallpaper.nix` | swww wallpaper management                  |
