# Bundle Composition

> Bundles compose related aspects into a single includable unit. Some are pure
> composition; others carry orchestrator logic that wires sub-aspect options
> together.

## Pure bundles

A pure bundle has `includes` and nothing else. It exists solely to give a group
of aspects a single name:

```nix
# modules/cli/bundle.nix
{ den, ... }:
{
  den.aspects.cli = {
    includes = [
      den.aspects.bat
      den.aspects.broot
      den.aspects.claude-code
      den.aspects.crypt
      den.aspects.delta
      den.aspects.ghostty
      den.aspects.glow
      den.aspects.helix
      den.aspects.hyfetch
      den.aspects.nix-tree
      den.aspects.prettier
      den.aspects.tree
      den.aspects.audio-tools
    ];
  };
}
```

Including `den.aspects.cli` in a user aspect activates all 13 tools. Adding a
new CLI tool means creating the aspect file and adding one line to this bundle.

### All pure bundles

| Bundle | File | Includes |
|--------|------|----------|
| `cli` | `modules/cli/bundle.nix` | bat, broot, claude-code, crypt, delta, ghostty, glow, helix, hyfetch, nix-tree, prettier, tree, audio-tools |
| `shells` | `modules/shells/bundle.nix` | nushell, starship, zoxide, devenv |
| `desktop-apps` | `modules/desktop/bundle.nix` | hyprland, chromium, obs, screenshot, gaming-hm |
| `devtools` | `modules/devtools/bundle.nix` | docker, rust, node-ts, c-cpp, python, csharp, ada-lang, localstack, zig, gamedev |

## Orchestrator bundles

An orchestrator bundle adds `homeManager` or `nixos` configuration alongside its
`includes`. It typically defines an option set that controls the sub-aspects.

### The git suite orchestrator

The git suite is the most complex bundle. It defines `programs.gitSuite` options
and maps them to sub-aspect enable flags:

```nix
# modules/git/bundle.nix
{ den, ... }:
{
  den.aspects.git-suite = {
    includes = [
      den.aspects.git-core
      den.aspects.git-aliases
      den.aspects.git-identities
      den.aspects.git-github
      den.aspects.git-tools
      den.aspects.git-safety
      den.aspects.git-help
    ];

    homeManager = { config, lib, ... }:
    with lib;
    let cfg = config.programs.gitSuite;
    in {
      options.programs.gitSuite = {
        enable = mkEnableOption "Complete Git suite configuration";
        userName = mkOption { type = types.str; default = "adanoelle"; };
        userEmail = mkOption { type = types.str; default = "adanoelleyoung@gmail.com"; };
        editor = mkOption { type = types.str; default = "hx"; };
        enableGithub = mkOption { type = types.bool; default = true; };
        enableTools = mkOption { type = types.bool; default = true; };
        enableSafety = mkOption { type = types.bool; default = true; };
        enableHelp = mkOption { type = types.bool; default = true; };
      };

      config = mkIf cfg.enable {
        programs.gitCore = {
          enable = true;
          userName = cfg.userName;
          userEmail = cfg.userEmail;
          editor = cfg.editor;
        };
        programs.gitAliases.enable = true;
        programs.gitIdentities.enable = true;
        programs.gitGithub.enable = cfg.enableGithub;
        programs.gitTools.enable = cfg.enableTools;
        programs.gitSafety.enable = cfg.enableSafety;
        programs.gitHelp.enable = cfg.enableHelp;
        programs.gitGithub.editor = mkDefault cfg.editor;
      };
    };
  };
}
```

The orchestrator pattern provides:

1. **A single enable flag** -- `programs.gitSuite.enable = true` activates core,
   aliases, and identities (always on) plus optional sub-features.
2. **Shared configuration** -- `userName`, `userEmail`, and `editor` are set once
   and forwarded to the core sub-aspect.
3. **Granular control** -- Individual features (github, tools, safety, worktrees)
   can be toggled independently.

The user aspect configures the suite through the orchestrator:

```nix
# modules/user-ada.nix (excerpt)
programs.gitSuite = {
  enable = true;
  userName = "adanoelle";
  userEmail = "adanoelleyoung@gmail.com";
  editor = "hx";
  enableGithub = true;
  enableTools = true;
  enableSafety = true;
  enableHelp = true;
};
```

## Bundle composition hierarchy

Bundles compose into a tree. The user is layered: the base aspect includes the
machine-agnostic bundles, and hosts forward the desktop/dev layers via
`provides.to-users`:

```
den.aspects.ada (user base — applies on every host)
├── den.aspects.cli (bundle)
│   ├── den.aspects.bat
│   ├── den.aspects.helix
│   ├── den.aspects.ghostty
│   └── ...
├── den.aspects.git-suite (orchestrator bundle)
│   ├── den.aspects.git-core
│   ├── den.aspects.git-aliases
│   └── ... (13 aspects)
├── den.aspects.shells (bundle)
│   ├── den.aspects.nushell
│   ├── den.aspects.starship
│   ├── den.aspects.zoxide
│   └── den.aspects.devenv
├── den.aspects.workspace
└── garden.terminal (from the garden-shell namespace)

den.aspects.ada-desktop (forwarded by graphical hosts)
└── den.aspects.desktop-apps (bundle)
    ├── den.aspects.niri
    ├── den.aspects.hyprland
    ├── den.aspects.chromium
    └── ... (7 aspects)

den.aspects.ada-dev (forwarded by dev hosts)
└── den.aspects.devtools (bundle)
    ├── den.aspects.rust
    ├── den.aspects.docker
    └── ... (10 aspects)
```

## Key files

| File | Purpose |
|------|---------|
| `modules/cli/bundle.nix` | Pure bundle (CLI tools) |
| `modules/shells/bundle.nix` | Pure bundle (4 shell tools) |
| `modules/desktop/bundle.nix` | Pure bundle (7 desktop apps) |
| `modules/devtools/bundle.nix` | Pure bundle (10 dev toolchains) |
| `modules/git/bundle.nix` | Orchestrator bundle (13 git aspects) |
| `modules/user-ada.nix` | User base layer (machine-agnostic bundles) |
| `modules/user-ada-desktop.nix` | Desktop layer (forwarded by GUI hosts) |
| `modules/user-ada-dev.nix` | Dev layer (forwarded per host) |
