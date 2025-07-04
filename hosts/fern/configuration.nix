{ self, inputs, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Allow dynamic linking for Python
  programs.nix-ld.enable = true;

  imports = [
    ./hardware.nix

    # --- NixOS modules
    self.nixosModules.boot
    self.nixosModules.core
    self.nixosModules.c-dev
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.rust-dev
    self.nixosModules.secrets

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Extra args you want available to HM modules
  home-manager.extraSpecialArgs = {
    inherit inputs;
    zig-overlay = inputs.zig-overlay;
  };

  home-manager.backupFileExtension = "backup";

  # --- User imports
  home-manager.users.ada = {
    imports = [
      self.homeModules.cli       # cli: git, bat, etc.
      self.homeModules.desktop   # hyprland
      self.homeModules.devtools  # zig, cpp
      self.homeModules.shells    # shells: nushell, starship, zoxide
      self.homeModules.workspace # manages xdg worspace directories
    ];
    home.packages = [ pkgs.home-manager ];

    desktop.hyprland.enable = true;
    
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
  networking.hostName = "fern";
}
