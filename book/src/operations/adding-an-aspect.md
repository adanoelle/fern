# Adding an Aspect

> Step-by-step guide for adding a new aspect to the configuration. No
> registration step is needed -- `import-tree` discovers new files
> automatically.

## Adding a simple aspect

### 1. Create the aspect file

Choose the appropriate directory:

```bash
modules/           # Top-level system concerns (audio, secrets, etc.)
modules/cli/       # CLI tools (bat, helix, ghostty, etc.)
modules/desktop/   # Desktop applications (browsers, greetd, etc.)
modules/devtools/  # Language toolchains and dev tools
modules/shells/    # Shell configuration
modules/git/       # Git suite extensions
modules/cloud/     # Cloud platform tools
```

Write the aspect. For a **homeManager-only** tool:

```nix
# modules/cli/my-tool.nix
{ den, ... }:
{
  den.aspects.my-tool.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.my-tool ];

    # Or use a Home Manager program module:
    programs.my-tool = {
      enable = true;
      settings = { /* ... */ };
    };
  };
}
```

For a **nixos-only** service:

```nix
# modules/my-service.nix
{ den, ... }:
{
  den.aspects.my-service.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.my-service ];
    systemd.services.my-service = {
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.my-service}/bin/my-service";
    };
  };
}
```

For a **dual-side** aspect (system packages + user configuration):

```nix
# modules/devtools/my-lang.nix
{ den, ... }:
{
  den.aspects.my-lang = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.my-lang pkgs.my-lang-lsp ];
    };

    homeManager = { pkgs, ... }: {
      programs.helix.languages.language-server.my-lang-lsp = {
        command = "${pkgs.my-lang-lsp}/bin/my-lang-lsp";
        args = [ "--stdio" ];
      };
    };
  };
}
```

### 2. Add to a bundle (if applicable)

If the aspect belongs to a group, add it to the bundle's includes:

```nix
# modules/cli/bundle.nix
{ den, ... }:
{
  den.aspects.cli = {
    includes = [
      # ... existing aspects ...
      den.aspects.my-tool    # Add here
    ];
  };
}
```

If the bundle is already included by the user or host aspect, you are done --
the new aspect activates automatically through the bundle.

### 3. Or include directly in a host/user aspect

If the aspect does not belong to a bundle, include it directly:

```nix
# For system-level aspects, add to the host:
# modules/host-fern.nix
den.aspects.fern.includes = [
  # ... existing includes ...
  den.aspects.my-service
];

# For user-level aspects, add to the user:
# modules/user-ada.nix
den.aspects.ada.includes = [
  # ... existing includes ...
  den.aspects.my-tool
];
```

### 4. Test and commit

```bash
just fmt          # Format Nix files
just check        # Flake check
just test         # Test build
# If test succeeds:
just switch       # Apply
```

## Adding Helix LSP integration

If the new aspect is a language toolchain, add LSP configuration on the
`homeManager` side:

```nix
den.aspects.my-lang.homeManager = { pkgs, ... }: {
  programs.helix.languages.language-server.my-lang-lsp = {
    command = "${pkgs.my-lang-lsp}/bin/my-lang-lsp";
    args = [ "--stdio" ];
  };
};
```

This follows the pattern used by all existing toolchains -- LSP config is
co-located with the toolchain aspect rather than centralized in the Helix
aspect.

## What you do NOT need to do

- ~~Register in `flake.parts/20-nixos-mods.nix`~~ -- `import-tree` discovers
  the file automatically
- ~~Register in `flake.parts/30-home-mods.nix`~~ -- same
- ~~Import in `hosts/*/configuration.nix`~~ -- includes handle this
- ~~Choose a number for file ordering~~ -- Nix evaluation is lazy

## Checklist

- [ ] Aspect file created in the correct directory
- [ ] Added to bundle includes (if part of a group)
- [ ] Or included directly in host/user aspect
- [ ] `just fmt` passes
- [ ] `just check` passes
- [ ] `just test` succeeds
- [ ] Changes committed
