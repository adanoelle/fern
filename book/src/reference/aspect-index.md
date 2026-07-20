# Aspect Index

> Complete list of all aspects with their type, source file, and which hosts or
> users include them.

## Host aspects

| Aspect | File | Type | Hosts |
|--------|------|------|-------|
| `fern` | `modules/host-fern.nix` | nixos | fern |
| `moss` | `modules/host-moss.nix` | nixos | moss |

## User aspects

The user is layered: the base aspect applies everywhere, and hosts forward
extra layers via `provides.to-users` (so a headless host's `ada` stays
minimal).

| Aspect | File | Type | Applied |
|--------|------|------|---------|
| `ada` | `modules/user-ada.nix` | homeManager | ada, every host (base: shells, cli, git, ssh) |
| `ada-desktop` | `modules/user-ada-desktop.nix` | homeManager | forwarded by fern, moss (parked) (desktop prefs + desktop-apps) |
| `ada-dev` | `modules/user-ada-dev.nix` | homeManager | forwarded by fern, moss (parked) (devtools bundle) |

## Role aspects

Host role bundles — compose these instead of long per-host include lists.

| Aspect | File | Includes |
|--------|------|----------|
| `workstation` | `modules/roles/workstation.nix` | core, nh, users, secrets-guard, secrets, greetd, fonts, audio, docker |
| `dev-machine` | `modules/roles/dev-machine.nix` | localstack, aws-cli |
| `server` | `modules/roles/server.nix` | core, nh, users, secrets-guard (skeleton — hardening TODOs in file) |

## Bundle aspects

| Aspect | File | Includes |
|--------|------|----------|
| `cli` | `modules/cli/bundle.nix` | bat, broot, claude-code, crypt, delta, ghostty, glow, helix, hyfetch, nix-diff, nix-tree, prettier, tree, audio-tools, kitty, kakoune, yazi, lazygit, btop, fzf, fd, ripgrep, rbw, jq |
| `git-suite` | `modules/git/bundle.nix` | git-core, git-aliases, git-identities, git-github, git-tools, git-safety, git-help |
| `desktop-apps` | `modules/desktop/bundle.nix` | hyprland, chromium, obs, screenshot, gaming-hm, daw, bitwarden (niri is deliberately NOT here — hosts forward it via provides.to-users) |
| `devtools` | `modules/devtools/bundle.nix` | docker, rust, node-ts, c-cpp, python, csharp, ada-lang, zig, gamedev |
| `shells` | `modules/shells/bundle.nix` | nushell, starship, zoxide, devenv |

## System aspects (nixos)

Aspects providing NixOS system-level configuration.

| Aspect | File | Description | Included by |
|--------|------|-------------|-------------|
| `audio` | `modules/audio.nix` | PipeWire, low-latency, Audient iD24, tools | fern, moss |
| `aws-cli` | `modules/cloud/aws-cli.nix` | AWS CLI, vault, SAM, Terraform, security tools | fern |
| `boot` | `modules/boot.nix` | systemd-boot (UEFI x86 default; kernel chosen per host) | fern |
| `boot-asahi` | `modules/asahi/boot.nix` | systemd-boot (Apple Silicon) | moss |
| `c-cpp` | `modules/devtools/c-cpp.nix` | GCC, Clang, CMake, hardening flags | fern |
| `core` | `modules/core.nix` | Nix settings, overlays, fleet defaults (trusted-users, nix-ld, timezone via mkDefault) | fern, moss |
| `docker` | `modules/devtools/docker.nix` | Docker Engine, BuildKit, Compose, utilities | fern, moss |
| `fonts` | `modules/fonts.nix` | Nerd Fonts, fontconfig | fern |
| `gaming` | `modules/gaming.nix` | Steam, Gamescope, GameMode, controllers | fern |
| `graphics-asahi` | `modules/asahi/graphics.nix` | Asahi experimental GPU driver | moss |
| `greetd` | `modules/desktop/greetd.nix` | greetd, tuigreet (sessions offered per enabled compositor), seatd, XDG portals, Polkit | fern, moss |
| `lmstudio` | `modules/desktop/lmstudio.nix` | LM Studio AppImage wrapper | fern |
| `localstack` | `modules/devtools/localstack.nix` | LocalStack container, awslocal wrapper | fern |
| `monitoring` | `modules/monitoring.nix` | Hardware sensors (lm_sensors) | fern |
| `nh` | `modules/cli/nh.nix` | nh rebuild helper + scheduled clean | fern |
| `niri` | `modules/desktop/niri.nix` | Niri compositor (nixos enable + HM settings) | fern (also forwarded to users via host provides.to-users) |
| `node-ts` | `modules/devtools/node-ts.nix` | Node.js, pnpm, Deno, CDK, nix-ld | fern |
| `rust` | `modules/devtools/rust.nix` | Stable Rust, rust-analyzer, cargo tools, hardening | fern |
| `secrets` | `modules/secrets.nix` | SOPS-nix, age key, SSH key decryption | fern (via workstation role), moss (parked) |
| `secrets-guard` | `modules/secrets-guard.nix` | git-secrets, trufflehog | fern, moss |
| `teams` | `modules/desktop/teams.nix` | Microsoft Teams | fern |
| `users` | `modules/users.nix` | User account, NetworkManager, SSH | fern, moss |

## User aspects (homeManager)

Aspects providing Home Manager user-level configuration.

### CLI tools

| Aspect | File | Description |
|--------|------|-------------|
| `audio-tools` | `modules/cli/audio-tools.nix` | LSP audio plugins |
| `bat` | `modules/cli/bat.nix` | Bat syntax highlighter, man pager |
| `broot` | `modules/cli/broot.nix` | File explorer with Nushell integration |
| `btop` | `modules/cli/btop.nix` | System monitor |
| `claude-code` | `modules/cli/claude-code.nix` | Claude Code CLI package |
| `crypt` | `modules/cli/crypt.nix` | Age encryption tool |
| `delta` | `modules/cli/delta.nix` | Delta diff tool, Catppuccin Frappe theme |
| `fd` | `modules/cli/fd.nix` | Fast file finder |
| `fzf` | `modules/cli/fzf.nix` | Fuzzy finder |
| `ghostty` | `modules/cli/ghostty.nix` | Ghostty terminal emulator |
| `glow` | `modules/cli/glow.nix` | Markdown viewer |
| `helix` | `modules/cli/helix.nix` | Helix editor, LSP, theme |
| `hyfetch` | `modules/cli/hyfetch.nix` | System info display (fastfetch) |
| `jq` | `modules/cli/jq.nix` | JSON processor |
| `kakoune` | `modules/cli/kakoune.nix` | Kakoune editor |
| `kitty` | `modules/cli/kitty.nix` | Kitty terminal (garden terminal stack) |
| `lazygit` | `modules/cli/lazygit.nix` | Git TUI |
| `nix-diff` | `modules/cli/nix-diff.nix` | Derivation diff tool |
| `nix-tree` | `modules/cli/nix-tree.nix` | Nix dependency visualizer |
| `prettier` | `modules/cli/prettier.nix` | Code formatter |
| `rbw` | `modules/cli/rbw.nix` | Bitwarden CLI client (see [Password Manager](../security/password-manager.md)) |
| `ripgrep` | `modules/cli/ripgrep.nix` | Fast grep |
| `tree` | `modules/cli/tree.nix` | Directory tree viewer |
| `yazi` | `modules/cli/yazi.nix` | Terminal file manager |

### Git suite

| Aspect | File | Description |
|--------|------|-------------|
| `git-core` | `modules/git/core.nix` | SSH signing, delta, performance |
| `git-aliases` | `modules/git/aliases.nix` | 100+ Git and shell aliases |
| `git-identities` | `modules/git/identities.nix` | Multi-identity with includeIf |
| `git-github` | `modules/git/github.nix` | GitHub CLI integration |
| `git-tools` | `modules/git/tools.nix` | Lazygit, tig, git-absorb, git-lfs |
| `git-safety` | `modules/git/safety.nix` | Protected branches, hooks |
| `git-help` | `modules/git/help.nix` | tldr, quick-reference sheet |

### Desktop

| Aspect | File | Description |
|--------|------|-------------|
| `hyprland` | `modules/desktop/hyprland.nix` | Hyprland compositor (fallback session) + sub-modules |
| `bitwarden` | `modules/desktop/bitwarden.nix` | Bitwarden desktop app |
| `chromium` | `modules/desktop/chromium.nix` | Ungoogled Chromium |
| `gaming-hm` | `modules/desktop/gaming-hm.nix` | MangoHud, Lutris, ProtonUp |
| `nyxt` | `modules/desktop/nyxt.nix` | Nyxt browser |
| `obs` | `modules/desktop/obs.nix` | OBS Studio |
| `screenshot` | `modules/desktop/screenshot.nix` | grim, slurp, satty |

### Shells

| Aspect | File | Description |
|--------|------|-------------|
| `nushell` | `modules/shells/nushell.nix` | Nushell shell configuration |
| `starship` | `modules/shells/starship.nix` | Starship prompt |
| `zoxide` | `modules/shells/zoxide.nix` | Zoxide directory jumper |
| `devenv` | `modules/shells/devenv.nix` | Devenv development environments |

### Dev toolchains

| Aspect | File | Description |
|--------|------|-------------|
| `ada-lang` | `modules/devtools/ada.nix` | GNAT, GPRBuild, Alire (renamed from `ada-dev`; that name is now the user dev layer) |
| `csharp` | `modules/devtools/csharp.nix` | .NET SDK, OmniSharp |
| `gamedev` | `modules/devtools/gamedev.nix` | SDL2, GLM, Box2D, Tracy, ImGui |
| `python` | `modules/devtools/python.nix` | Python 3.12, uv, ruff, pyright |
| `zig` | `modules/devtools/zig.nix` | Zig programming language |

### Other

| Aspect | File | Description |
|--------|------|-------------|
| `workspace` | `modules/workspace.nix` | Archivist home taxonomy: XDG user dirs (inbox/docs/media), notes + archive tree, `~/docs/FILING.md` manual |

## Infrastructure aspects

These aspects configure the den framework and flake infrastructure rather than
providing NixOS/HM configuration for the end user.

| File | Purpose |
|------|---------|
| `modules/dendritic.nix` | Den bootstrap, HM bridge, mutual provider |
| `modules/hosts.nix` | Topology declaration |
| `modules/defaults.nix` | Global defaults (stateVersion, helpers) |
| `modules/overlays.nix` | Nixpkgs config and overlays |
| `modules/dev.nix` | Development shell (just, mdbook, nixpkgs-fmt) |
| `modules/docs.nix` | mdBook documentation build |
