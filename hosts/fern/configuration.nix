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
    self.nixosModules.cursor
    self.nixosModules.docker
    self.nixosModules.lmstudio
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.graphics
    self.nixosModules.greet
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

    desktop.hyprland = {
      enable = true;
      bar.enable  = true;   # Waybar
      idle.enable = true;   # hypridle
      lock.enable = true;   # hyprlock

      wallpaper = {
        enable = true;
        path = "/home/ada/wallpapers/shrine.png";  # fallback/default
        monitor = "HDMI-A-1";                      # your current setup still works
    
        # Optional: per-monitor setup (replaces path/monitor)
        monitors = {
          "HDMI-A-1" = "/home/ada/wallpapers/shrine.png";
        };
    
        # Optional: per-workspace wallpapers
        workspaces = {
          "1" = "/home/ada/wallpapers/totoro_house.png";
          "2" = "/home/ada/wallpapers/howl_castle.png";
          "3" = "/home/ada/wallpapers/kiki.png";
          "4" = "/home/ada/wallpapers/nausicaa.png";
          "5" = "/home/ada/wallpapers/wind_rises_plane.png";
        };
    
        # Optional: transition customization
        transition = {
          type = "fade";
          duration = 1.2;
          fps = 60;
        };
      };
       
      # Optional style tweaks
      style = {
        gapsIn   = 6;
        gapsOut  = 12;
        border   = 2;
        rounding = 5;
      };
    };

    home.stateVersion = "25.11";
  };

  nix.settings.trusted-users = [ "root" "ada" ];

  services.fern-shell.enable = true;
  services.fern-fonts.enable = true;

  time.timeZone = "America/New_York";

  system.stateVersion = "25.11";
  networking.hostName = "fern";
}
