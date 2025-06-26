{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    # --- NixOS modules
    inputs.fern.nixosModules.boot
    inputs.fern.nixosModules.users
    inputs.fern.nixosModules.audio
    inputs.fern.nixosModules.graphics
    inputs.fern.nixosModules.rust-dev

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Extra args you want available to HM modules
  home-manager.extraSpecialArgs = { inherit inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [
      inputs.fern.homeModules.cli       # cli: git, bat, etc.
      inputs.fern.homeModules.shells    # shells: nushell, starship, zoxide
      inputs.fern.homeModules.workspace # manages xdg worspace directories
    ];
  };

  networking.hostName = "fern";
}
