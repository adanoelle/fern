<table width="100%">
<tr>
<td><h1>🌱 Fern</h1></td>
<td align="right"><sub>Ada's NixOS</sub></td>
</tr>
</table>

A multi-machine NixOS configuration built on the dendritic pattern:
flake-parts, [import-tree](https://github.com/vic/import-tree) and
[den](https://github.com/vic/den). Every file under `modules/` is
imported automatically, and configuration is written as small **aspects**
that hosts and users compose. Detailed documentation is in the
[book](https://adanoelle.github.io/fern/).

## Machines

| Machine | What it is |
| --- | --- |
| **fern** | x86_64 desktop workstation: Niri and the garden shell, pro audio, development |
| **yarrow** | Framework Laptop 13 Pro: art, game development and playtesting |
| work laptop | Ubuntu 24.04 with a standalone home-manager configuration |
| moss | Apple Silicon laptop (Asahi), currently parked |

## Layout

```
fern/
├── flake.nix      # inputs + mkFlake over (import-tree ./modules)
├── justfile       # command recipes (the primary interface)
├── hosts/         # only generated hardware-configuration files
├── modules/       # everything else; every .nix here is auto-imported
├── book/          # mdBook documentation
├── secrets/       # sops-encrypted secrets
└── CLAUDE.md      # conventions and safety rules for AI agents
```

## Using it

On an installed host, from the repository's devShell (`direnv allow`
once):

```bash
just              # list recipes
just check        # nix flake check
just test         # build and activate without making it the boot default
just switch       # rebuild and switch
just rollback     # return to the previous generation
just book-serve   # documentation with live reload
```

Installing a new machine, and running the configuration on a non-NixOS
distribution, are covered in the book's operations chapters.

## See also

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [den](https://github.com/vic/den) and [flake-parts](https://flake.parts/)
