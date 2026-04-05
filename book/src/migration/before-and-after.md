# Before & After

> Side-by-side code comparisons showing how garden.* patterns map to den
> aspects.

## Module → Aspect

### Before: garden.* system module

```nix
# nix/modules/audio.nix
{ pkgs, lib, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;
  environment.systemPackages = with pkgs; [ pavucontrol qpwgraph helvum ];
}
```

Registered in `flake.parts/20-nixos-mods.nix`:
```nix
flake.nixosModules = {
  audio = import ../nix/modules/audio.nix;
};
```

Imported in `hosts/fern/configuration.nix`:
```nix
imports = [ self.nixosModules.audio ];
```

### After: den aspect

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
    environment.systemPackages = with pkgs; [ pavucontrol qpwgraph helvum ];
  };
}
```

Included in host aspect:
```nix
den.aspects.fern.includes = [ den.aspects.audio ];
```

No registration step. No separate import. One file, one include.

## Aggregator → Bundle

### Before: aggregator with explicit imports

```nix
# nix/home/cli.nix
{ ... }:
{
  imports = [
    ./cli/bat.nix
    ./cli/broot.nix
    ./cli/ghostty.nix
    ./cli/helix.nix
    ./cli/delta.nix
    ./cli/glow.nix
    # ... 12 modules total
  ];
}
```

### After: bundle with den includes

```nix
# modules/cli/bundle.nix
{ den, ... }:
{
  den.aspects.cli = {
    includes = [
      den.aspects.bat
      den.aspects.broot
      den.aspects.ghostty
      den.aspects.helix
      den.aspects.delta
      den.aspects.glow
      # ... 13 aspects total
    ];
  };
}
```

The structural difference is small -- `imports` becomes `includes`, file paths
become aspect references. The practical difference is large: `imports` requires
exact file paths relative to the aggregator; `includes` uses aspect names that
den resolves from anywhere in the tree.

## Host configuration → Host aspect

### Before: configuration.nix

```nix
# hosts/fern/configuration.nix
{ self, inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    self.nixosModules.core
    self.nixosModules.audio
    self.nixosModules.docker
    self.nixosModules.rust-dev
    self.nixosModules.c-dev
    self.nixosModules.typescript
    # ... 20+ imports
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  home-manager.users.ada = {
    imports = [
      self.homeModules.cli
      self.homeModules.git
      self.homeModules.desktop
      self.homeModules.devtools
      self.homeModules.shells
      self.homeModules.workspace
    ];
    home.stateVersion = "25.11";
  };

  networking.hostName = "fern";
  time.timeZone = "America/New_York";
  # ...
}
```

Plus the definition in `flake.parts/40-hosts.nix`:
```nix
flake.nixosConfigurations.fern =
  withSystem "x86_64-linux" ({ pkgs, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs system;
      modules = [
        ../hosts/fern/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
      specialArgs = { inherit self inputs; };
    });
```

### After: host aspect + topology

```nix
# modules/hosts.nix
{ ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = {};
}
```

```nix
# modules/host-fern.nix
{ den, inputs, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.core
      den.aspects.audio
      den.aspects.docker
      den.aspects.rust
      den.aspects.c-cpp
      den.aspects.node-ts
      # ...
    ];

    nixos = { pkgs, lib, ... }: {
      imports = [ ../hosts/fern/hardware.nix ];
      boot.loader.systemd-boot.enable = true;
      boot.kernelPackages = pkgs.linuxPackages_zen;
      time.timeZone = "America/New_York";
    };
  };
}
```

The topology line replaces `withSystem`, `nixosSystem`, `specialArgs`, and
`home-manager.users.ada`. The host aspect replaces `configuration.nix`. Home
Manager wiring is handled by `dendritic.nix` once for all hosts.

## User wiring → User aspect

### Before: inline in host configuration

```nix
# hosts/fern/configuration.nix (excerpt)
home-manager.users.ada = {
  imports = [
    self.homeModules.cli
    self.homeModules.git
    self.homeModules.desktop
    self.homeModules.devtools
    self.homeModules.shells
    self.homeModules.workspace
  ];
  home.stateVersion = "25.11";

  programs.gitSuite = {
    enable = true;
    userName = "adanoelle";
    userEmail = "adanoelleyoung@gmail.com";
  };

  desktop.hyprland.enable = true;
};
```

### After: standalone user aspect

```nix
# modules/user-ada.nix
{ den, ... }:
{
  den.aspects.ada = {
    includes = [
      den.aspects.cli
      den.aspects.git-suite
      den.aspects.desktop-apps
      den.aspects.devtools
      den.aspects.shells
      den.aspects.workspace
    ];

    homeManager = { ... }: {
      home.packages = [ pkgs.home-manager ];

      desktop.hyprland.enable = true;

      programs.gitSuite = {
        enable = true;
        userName = "adanoelle";
        userEmail = "adanoelleyoung@gmail.com";
      };
    };
  };
}
```

The user aspect is now a first-class file rather than a block nested inside a
host configuration. It applies to user `ada` on every host in the topology.
