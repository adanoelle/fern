{ self, inputs, pkgs, ... }:

{
  # Allow dynamic linking for Python
  programs.nix-ld.enable = true;

  imports = [
    ./hardware.nix

    # --- NixOS modules
    self.nixosModules.boot
    self.nixosModules.core
    self.nixosModules.c-dev
    self.nixosModules.aws
    self.nixosModules.docker
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.hyprland-sessions
    self.nixosModules.greet
    # self.nixosModules.caelestia-session
    self.nixosModules.localstack
    self.nixosModules.rust-dev
    self.nixosModules.typescript
    self.nixosModules.secrets
    self.nixosModules.guard

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    # Allow our packages from Caelestia overlay
    # This keeps home-manager from getting a fresh version of pkgs
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  # Extra args you want available to HM modules
  home-manager.extraSpecialArgs = { inherit inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [
      self.homeModules.cli       # cli: git, bat, ghostty, etc.
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
