<table width="100%">
<tr>
<td><h1>🌱 Fern</h1></td>
<td align="right"><sub>Ada's NixOS</sub></td>
</tr>
</table>

Modular NixOS system configuration built with Flakes, Home Manager, and
flake-parts. Targets a Hyprland development workstation. You can find 
detailed documentation in my [book](https://adanoelle.github.io/fern/).

## Clone and Bootstrap

On a fresh NixOS install, build the system before a devShell exists:

```bash
git clone git@github.com:adanoelle/fern.git ~/src/nix/fern
cd ~/src/nix/fern
sudo nixos-rebuild switch --flake .#fern
```

## Enter the Development Shell

After the first build, enable the devShell (one-time):

```bash
direnv allow        # auto-activates via .envrc
```

This gives you `just`, `mdbook`, and `nixpkgs-fmt` on `PATH`.

## Use the Justfile

`just` is the primary command interface. Run `just` with no arguments to list
all recipes:

```bash
just                # list recipes
just switch         # rebuild and switch
just test           # test without switching
just update         # update flake inputs
just fmt            # format Nix files
just lint           # format then check
just gc             # garbage-collect old generations
just book-serve     # serve docs with live reload
```

## Documentation

The `book/` directory contains an mdBook with detailed guides:

```bash
just book-serve     # live-reload at localhost:3000
just book-build     # build to book/build/
just book-nix       # pure Nix derivation
```

## Project Structure

```
fern/
├── flake.nix               # Flake definition
├── flake.lock              # Pinned dependencies
├── justfile                # Command recipes
├── flake.parts/            # Modular flake organization
│   ├── 00-overlay.nix      # Package overlays
│   ├── 10-core.nix         # Shared flake outputs (systems)
│   ├── 20-nixos-mods.nix   # NixOS module registry
│   ├── 30-home-mods.nix    # Home Manager module registry
│   ├── 40-hosts.nix        # Per-host NixOS configurations
│   ├── 50-dev.nix          # Development shell
│   └── 60-docs.nix         # Documentation outputs
├── hosts/
│   └── fern/               # Primary workstation
│       ├── configuration.nix
│       └── hardware.nix
├── nix/
│   ├── modules/            # NixOS system modules
│   └── home/               # Home Manager user modules
├── book/                   # mdBook documentation
├── secrets/                # SOPS-encrypted secrets
└── CLAUDE.md               # AI assistant context
```

## Common Workflows

### Edit, test, switch

```bash
hx hosts/fern/configuration.nix
just test
just switch
```

### Update dependencies

```bash
just update
just switch
```

### Recover from a bad build

```bash
just rollback
```

## See Also

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [flake-parts](https://flake.parts/)
