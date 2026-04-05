# Home Manager

> Home Manager extends the NixOS module system to user-space configuration:
> dotfiles, user services, shell settings, and per-user packages.

NixOS system modules configure things that require root: system services, kernel
settings, hardware drivers, system-wide packages. But most of a developer's
environment is user-level: shell configuration, editor settings, Git config,
terminal themes.

Home Manager fills this gap. It uses the same module system as NixOS (options,
config, `mkIf`, `mkDefault`) but targets `~/.config/`, user systemd services,
and per-user package installation.

## System modules vs home modules

| Concern                 | NixOS side                     | Home Manager side              |
| ----------------------- | ------------------------------ | ------------------------------ |
| PipeWire audio service  | `modules/audio.nix`            | --                             |
| GPU driver              | `modules/graphics.nix`         | --                             |
| Ghostty terminal config | --                             | `modules/cli/ghostty.nix`      |
| Helix editor settings   | --                             | `modules/cli/helix.nix`        |
| Git configuration       | --                             | `modules/git/`                 |
| Docker engine           | `modules/devtools/docker.nix`  | --                             |

The rule of thumb: if it needs root or affects the system globally, it belongs
in a NixOS module. If it is per-user configuration, it belongs in Home Manager.

## Integration as a NixOS module

Home Manager can run standalone, but this configuration integrates it as a NixOS
module via den's bootstrap (`modules/dendritic.nix`):

```nix
den = {
  ctx.hm-host.nixos.home-manager = {
    useGlobalPkgs = true;        # Use the system's nixpkgs, not a separate one
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
  };

  schema.user.classes = [ "homeManager" ];
};
```

Every user declared in the topology automatically gets a Home Manager
configuration. `nixos-rebuild switch` builds both the system and the user
environment in one step. There is no separate `home-manager switch` command
needed.

`useGlobalPkgs = true` ensures Home Manager uses the same nixpkgs instance (with
overlays) as the system, avoiding duplicate package builds.

## Home module structure

Home modules follow the same pattern as NixOS modules but use Home Manager
options:

```nix
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config.pager = "less -FR";
  };
}
```

Home Manager provides hundreds of program modules (`programs.git`,
`programs.starship`, `programs.helix`, etc.) that generate the right dotfiles
from Nix expressions. When no built-in module exists, you can use `home.file` or
`xdg.configFile` to manage arbitrary dotfiles.
