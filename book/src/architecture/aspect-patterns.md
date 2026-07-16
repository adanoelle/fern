# Aspect Patterns

> Aspects in this configuration follow a few recurring patterns: config-only,
> dual-side, option-tree, and namespaced sub-aspect. This page documents each
> with real examples.

## Pattern 1: Config-only aspect (single side)

The simplest pattern. The aspect provides configuration on one side without
declaring custom options.

**NixOS-only** (system packages, services):

```nix
# modules/audio.nix
{ den, ... }:
{
  den.aspects.audio.nixos = { pkgs, ... }: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
    security.rtkit.enable = true;
    environment.systemPackages = with pkgs; [
      audacity qpwgraph helvum pavucontrol easyeffects pulsemixer
    ];
  };
}
```

**homeManager-only** (user tools, dotfiles):

```nix
# modules/cli/bat.nix
{ den, ... }:
{
  den.aspects.bat.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.bat ];
    programs.man.enable = true;
    home.sessionVariables.MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
```

Most aspects in this configuration follow this pattern. Use it when the tool
lives cleanly on one side and needs no custom options beyond what upstream
NixOS/Home Manager modules already provide.

## Pattern 2: Dual-side aspect

Some tools need both system-level and user-level configuration. The Rust aspect
installs system packages (compiler, tools) via NixOS and could configure
user-level settings via Home Manager in the same file:

```nix
# modules/devtools/rust.nix
{ den, ... }:
{
  den.aspects.rust.nixos = { lib, pkgs, ... }:
    let
      stable = pkgs.rust-bin.stable.latest.default;
    in {
      environment.systemPackages = [
        stable
        pkgs.rust-bin.stable.latest.clippy
        pkgs.rust-bin.stable.latest.rustfmt
        pkgs.rust-analyzer
        pkgs.cargo-audit
        pkgs.cargo-deny
      ];
      environment.variables.RUSTFLAGS =
        lib.strings.concatStringsSep " " [
          "-C" "link-args=-Wl,-z,relro,-z,now"
          "-C" "opt-level=z"
          "-C" "target-cpu=native"
        ];
      environment.variables.RUST_SRC_PATH =
        "${stable}/lib/rustlib/src/rust/library";
    };
}
```

Currently this aspect uses only the `nixos` side, but it could add a
`homeManager` side for user-level Rust tooling (cargo config, Helix LSP
settings) without creating a second file.

## Pattern 3: Aspect with internal option tree

Complex features define their own options within the `homeManager` or `nixos`
block. The Hyprland aspect is the largest example:

```nix
# modules/desktop/hyprland.nix (simplified)
{ den, ... }:
{
  den.aspects.hyprland.homeManager = { pkgs, lib, config, ... }:
    let cfg = config.desktop.hyprland;
    in {
      imports = [
        ./_hyprland/bar.nix
        ./_hyprland/fern.nix
        ./_hyprland/idlelock.nix
        ./_hyprland/wallpaper.nix
      ];

      options.desktop.hyprland = {
        enable = lib.mkEnableOption "Hyprland Wayland compositor";
        modKey = lib.mkOption { type = lib.types.str; default = "SUPER"; };
        terminal = lib.mkOption { type = lib.types.str; default = "ghostty"; };
        bar.enable = lib.mkEnableOption "Waybar status bar";
        idle.enable = lib.mkEnableOption "hypridle idle timer";
        lock.enable = lib.mkEnableOption "hyprlock screen locker";
        fern.enable = lib.mkEnableOption "Fern shell (QuickShell-based bar)";
        wallpaper = {
          enable = lib.mkEnableOption "wallpaper management with swww";
          path = lib.mkOption { type = lib.types.str; /* ... */ };
          transition = { /* type, duration, fps options */ };
        };
        style = {
          gapsIn = lib.mkOption { type = lib.types.int; default = 6; };
          gapsOut = lib.mkOption { type = lib.types.int; default = 12; };
          border = lib.mkOption { type = lib.types.int; default = 2; };
          rounding = lib.mkOption { type = lib.types.int; default = 5; };
        };
      };

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland.enable = true;
        /* ... keybindings, animations, styling ... */
      };
    };
}
```

This is the standard NixOS module pattern (`options` + `config` + `mkIf`),
hosted inside a den aspect. The user aspect sets these options:

```nix
# modules/user-ada-desktop.nix (excerpt)
homeManager = { ... }: {
  desktop.hyprland = {
    enable = true;
    wallpaper.enable = true;
    wallpaper.path = "/home/ada/wallpapers/shrine.png";
    style.gapsIn = 6;
  };
};
```

### The underscore convention

The Hyprland aspect imports files from `_hyprland/`:

```
modules/desktop/
├── hyprland.nix          # Main aspect
└── _hyprland/            # Internal sub-modules
    ├── bar.nix           # Waybar
    ├── fern.nix          # Fern Shell (QuickShell)
    ├── idlelock.nix      # hypridle + hyprlock
    └── wallpaper.nix     # swww wallpaper
```

The leading underscore tells `import-tree` to **skip** this directory -- these
files are not standalone aspects. Instead, `hyprland.nix` imports them explicitly
via its `imports` list. Use this convention when you need to split a large aspect
into sub-files without exposing them as independent aspects.

## Pattern 4: Namespaced sub-aspects

The git suite uses a naming convention to keep its 13 sub-aspects organized:

```nix
# modules/git/core.nix
den.aspects.git-core.homeManager = { ... }: { /* ... */ };

# modules/git/aliases.nix
den.aspects.git-aliases.homeManager = { ... }: { /* ... */ };

# modules/git/identities.nix
den.aspects.git-identities.homeManager = { ... }: { /* ... */ };
```

The `git-` prefix groups them in the aspect namespace. The bundle then composes
them:

```nix
# modules/git/bundle.nix
den.aspects.git-suite = {
  includes = [
    den.aspects.git-core
    den.aspects.git-aliases
    den.aspects.git-identities
    # ... 13 total
  ];
};
```

Users never reference `den.aspects.git-core` directly -- they include
`den.aspects.git-suite` and the bundle handles composition.

## When to use each pattern

| Pattern | Use when... |
|---------|-------------|
| Config-only | Simple tool, no custom options needed |
| Dual-side | Tool needs both system and user config |
| Option tree | Feature has user-facing knobs (theme, keybindings, enable sub-features) |
| Namespaced sub-aspects | Large feature decomposed into independently testable parts |

## Key files

| File | Purpose |
|------|---------|
| `modules/audio.nix` | Config-only (nixos) |
| `modules/cli/bat.nix` | Config-only (homeManager) |
| `modules/devtools/rust.nix` | Dual-side potential (currently nixos) |
| `modules/desktop/hyprland.nix` | Option tree with underscore sub-modules |
| `modules/git/core.nix` | Namespaced sub-aspect |
| `modules/git/bundle.nix` | Bundle composing namespaced sub-aspects |
