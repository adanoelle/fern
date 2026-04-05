# Aspect Index

> Complete list of all aspects with their type, source file, and which hosts or
> users include them.

## Host aspects

| Aspect | File | Type | Hosts |
|--------|------|------|-------|
| `fern` | `modules/host-fern.nix` | nixos | fern |
| `moss` | `modules/host-moss.nix` | nixos | moss |

## User aspects

| Aspect | File | Type | Users |
|--------|------|------|-------|
| `ada` | `modules/user-ada.nix` | homeManager | ada (both hosts) |

## Bundle aspects

| Aspect | File | Includes |
|--------|------|----------|
| `cli` | `modules/cli/bundle.nix` | bat, broot, claude-code, crypt, delta, ghostty, glow, helix, hyfetch, nix-tree, prettier, tree, audio-tools |
| `git-suite` | `modules/git/bundle.nix` | git-core, git-aliases, git-identities, git-github, git-tools, git-safety, git-help, git-claude-code, git-claude-enhanced, git-worktree, git-worktree-enhanced, git-helix, git-prompts |
| `desktop-apps` | `modules/desktop/bundle.nix` | hyprland, chromium, obs, screenshot, gaming-hm |
| `devtools` | `modules/devtools/bundle.nix` | docker, rust, node-ts, c-cpp, python, csharp, ada-dev, localstack, zig, gamedev |
| `shells` | `modules/shells/bundle.nix` | nushell, starship, zoxide, devenv |

## System aspects (nixos)

Aspects providing NixOS system-level configuration.

| Aspect | File | Description | Included by |
|--------|------|-------------|-------------|
| `audio` | `modules/audio.nix` | PipeWire, low-latency, Audient iD24, tools | fern, moss |
| `aws-cli` | `modules/cloud/aws-cli.nix` | AWS CLI, vault, SAM, Terraform, security tools | fern |
| `azure-cli` | `modules/cloud/azure-cli.nix` | Azure CLI with extensions, azcopy | fern |
| `boot` | `modules/boot.nix` | GRUB + Zen kernel (x86_64 legacy) | -- |
| `boot-asahi` | `modules/asahi/boot.nix` | systemd-boot (Apple Silicon) | moss |
| `c-cpp` | `modules/devtools/c-cpp.nix` | GCC, Clang, CMake, hardening flags | fern |
| `core` | `modules/core.nix` | Nix settings, flakes, garbage collection, overlays | fern, moss |
| `docker` | `modules/devtools/docker.nix` | Docker Engine, BuildKit, Compose, utilities | fern, moss |
| `fonts` | `modules/fonts.nix` | Nerd Fonts, fontconfig | fern |
| `gaming` | `modules/gaming.nix` | Steam, Gamescope, GameMode, controllers | -- |
| `graphics-asahi` | `modules/asahi/graphics.nix` | Asahi experimental GPU driver | moss |
| `greetd` | `modules/desktop/greetd.nix` | greetd, regreet, seatd, XDG portals, Polkit | fern, moss |
| `lmstudio` | `modules/desktop/lmstudio.nix` | LM Studio AppImage wrapper | fern |
| `localstack` | `modules/devtools/localstack.nix` | LocalStack container, awslocal wrapper | fern |
| `monitoring` | `modules/monitoring.nix` | Hardware sensors (lm_sensors) | fern |
| `node-ts` | `modules/devtools/node-ts.nix` | Node.js, pnpm, Deno, CDK, nix-ld | fern |
| `rust` | `modules/devtools/rust.nix` | Stable Rust, rust-analyzer, cargo tools, hardening | fern |
| `secrets` | `modules/secrets.nix` | SOPS-nix, age key, SSH key decryption | moss |
| `secrets-guard` | `modules/secrets-guard.nix` | git-secrets, trufflehog | fern, moss |
| `sqlserver` | `modules/desktop/sqlserver.nix` | SQL Studio | fern |
| `teams` | `modules/desktop/teams.nix` | Microsoft Teams | fern |
| `users` | `modules/users.nix` | User account, NetworkManager, SSH | fern, moss |
| `vscode` | `modules/desktop/vscode.nix` | VS Code | fern |

## User aspects (homeManager)

Aspects providing Home Manager user-level configuration.

### CLI tools

| Aspect | File | Description |
|--------|------|-------------|
| `audio-tools` | `modules/cli/audio-tools.nix` | LSP audio plugins |
| `bat` | `modules/cli/bat.nix` | Bat syntax highlighter, man pager |
| `broot` | `modules/cli/broot.nix` | File explorer with Nushell integration |
| `claude-code` | `modules/cli/claude-code.nix` | Claude Code CLI package |
| `crypt` | `modules/cli/crypt.nix` | Age encryption tool |
| `delta` | `modules/cli/delta.nix` | Delta diff tool, Catppuccin Frappe theme |
| `ghostty` | `modules/cli/ghostty.nix` | Ghostty terminal emulator |
| `glow` | `modules/cli/glow.nix` | Markdown viewer |
| `helix` | `modules/cli/helix.nix` | Helix editor, LSP, theme |
| `hyfetch` | `modules/cli/hyfetch.nix` | System info display (fastfetch) |
| `nix-tree` | `modules/cli/nix-tree.nix` | Nix dependency visualizer |
| `prettier` | `modules/cli/prettier.nix` | Code formatter |
| `tree` | `modules/cli/tree.nix` | Directory tree viewer |

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
| `git-worktree` | `modules/git/worktree.nix` | `wt` helper script |
| `git-worktree-enhanced` | `modules/git/worktree-enhanced.nix` | Dashboard, templates, parallel |
| `git-helix` | `modules/git/helix.nix` | Difftastic, editor aliases |
| `git-prompts` | `modules/git/prompts.nix` | Shell prompt git indicators |
| `git-claude-code` | `modules/git/claude-code.nix` | Claude safety wrapper |
| `git-claude-enhanced` | `modules/git/claude-enhanced.nix` | Claude session manager |

### Desktop

| Aspect | File | Description |
|--------|------|-------------|
| `hyprland` | `modules/desktop/hyprland.nix` | Hyprland compositor + sub-modules |
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
| `ada-dev` | `modules/devtools/ada.nix` | GNAT, GPRBuild, Alire |
| `csharp` | `modules/devtools/csharp.nix` | .NET SDK, OmniSharp |
| `gamedev` | `modules/devtools/gamedev.nix` | SDL2, GLM, Box2D, Tracy, ImGui |
| `python` | `modules/devtools/python.nix` | Python 3.12, uv, ruff, pyright |
| `zig` | `modules/devtools/zig.nix` | Zig programming language |

### Other

| Aspect | File | Description |
|--------|------|-------------|
| `workspace` | `modules/workspace.nix` | XDG user directories |

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
