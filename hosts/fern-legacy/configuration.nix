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
    self.nixosModules.azure-cli
    self.nixosModules.cursor
    self.nixosModules.claude
    self.nixosModules.docker
    self.nixosModules.lmstudio
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.gaming
    self.nixosModules.graphics
    self.nixosModules.monitoring
    self.nixosModules.greet
    self.nixosModules.localstack
    self.nixosModules.rust-dev
    self.nixosModules.teams
    self.nixosModules.typescript
    self.nixosModules.secrets
    self.nixosModules.guard
    self.nixosModules.vscode
    self.nixosModules.sqlserver

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
  home-manager.extraSpecialArgs = { inherit self inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [ ../common-hm.nix ];

    # Per-host wallpaper overrides (HDMI-A-1 + per-workspace)
    desktop.hyprland.wallpaper = {
      monitor = "HDMI-A-1";

      monitors = {
        "HDMI-A-1" = "/home/ada/wallpapers/shrine.png";
      };

      workspaces = {
        "1" = "/home/ada/wallpapers/totoro_house.png";
        "2" = "/home/ada/wallpapers/howl_castle.png";
        "3" = "/home/ada/wallpapers/kiki.png";
        "4" = "/home/ada/wallpapers/nausicaa.png";
        "5" = "/home/ada/wallpapers/wind_rises_plane.png";
      };
    };
  };

  nix.settings.trusted-users = [ "root" "ada" ];

  # Fern fonts (system-wide) - shell services are managed by Home-Manager
  services.fern-fonts.enable = true;

  time.timeZone = "America/New_York";

  system.stateVersion = "25.11";
  networking.hostName = "fern-legacy";
}
