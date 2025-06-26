{ self, inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    # --- NixOS modules
    self.nixosModules.boot
    self.nixosModules.core
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.rust-dev

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Extra args you want available to HM modules
  home-manager.extraSpecialArgs = { inherit inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [
      self.homeModules.cli       # cli: git, bat, etc.
      self.homeModules.shells    # shells: nushell, starship, zoxide
      self.homeModules.workspace # manages xdg worspace directories
    ];
  };

  networking.hostName = "fern";
}
