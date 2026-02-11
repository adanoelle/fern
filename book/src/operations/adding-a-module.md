# Adding a New Module

> Step-by-step guide for adding a new NixOS system module or Home Manager module
> to the configuration.

## Adding a NixOS system module

### 1. Create the module file

```bash
# Choose the appropriate directory
# nix/modules/           -- top-level system concerns
# nix/modules/devtools/  -- language toolchains, dev tools
# nix/modules/desktop/   -- desktop applications
# nix/modules/cloud/     -- cloud platform tools
```

Write the module:

```nix
# nix/modules/category/my-tool.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    my-tool
  ];

  # Services, environment variables, etc.
}
```

### 2. Register in flake.parts

Add an entry to `flake.parts/20-nixos-mods.nix`:

```nix
flake.nixosModules = {
  # ... existing modules ...
  my-tool = import ../nix/modules/category/my-tool.nix;
};
```

### 3. Import in host configuration

Add to `hosts/fern/configuration.nix` (and/or `hosts/moss/configuration.nix`):

```nix
imports = [
  # ... existing imports ...
  self.nixosModules.my-tool
];
```

### 4. Test and commit

```bash
just fmt          # Format
just check        # Flake check
just test         # Test build
# If test succeeds:
just switch       # Apply
```

## Adding a Home Manager module

### 1. Create the module file

```bash
# nix/home/cli/        -- CLI tools
# nix/home/desktop/    -- Desktop applications
# nix/home/devtools/   -- Language-specific dev tools
# nix/home/shells/     -- Shell configuration
# nix/home/git/        -- Git extensions
```

Write the module:

```nix
# nix/home/cli/my-tool.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.my-tool ];

  # Or use a Home Manager program module:
  programs.my-tool = {
    enable = true;
    settings = { ... };
  };
}
```

### 2. Add to the aggregator

Import the new module in the appropriate aggregator file:

```nix
# nix/home/cli.nix (for CLI tools)
{
  imports = [
    # ... existing imports ...
    ./cli/my-tool.nix
  ];
}
```

### 3. Test and commit

Same as system modules:

```bash
just fmt && just check && just test
```

No changes to `flake.parts/30-home-mods.nix` or host configurations are needed
because the aggregator modules are already registered and imported.

## Adding Helix LSP integration

If the new module is a language toolchain, add LSP configuration in the home
module:

```nix
# nix/home/devtools/my-lang.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.my-lang-lsp ];

  programs.helix.languages.language-server.my-lang-lsp = {
    command = "${pkgs.my-lang-lsp}/bin/my-lang-lsp";
    args = [ "--stdio" ];
  };
}
```

This follows the pattern used by all existing language toolchains -- the LSP
config is co-located with the toolchain module rather than centralized in the
Helix module.

## Checklist

- [ ] Module file created in the correct directory
- [ ] Registered in `flake.parts/` (system modules only)
- [ ] Imported in aggregator (home modules) or host config (system modules)
- [ ] `just fmt` passes
- [ ] `just check` passes
- [ ] `just test` succeeds
- [ ] Changes committed
