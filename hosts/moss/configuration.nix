{ self, inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    # Apple Silicon support
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support

    # --- NixOS modules (shared with fern where compatible)
    self.nixosModules.boot-asahi      # Apple Silicon boot (not the x86 boot module)
    self.nixosModules.core
    self.nixosModules.docker
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.graphics-asahi  # Apple Silicon graphics (not Nvidia)
    self.nixosModules.greet
    self.nixosModules.secrets
    self.nixosModules.guard

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Allow dynamic linking for Python
  programs.nix-ld.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  home-manager.extraSpecialArgs = { inherit inputs; };

  # --- User configuration
  home-manager.users.ada = {
    imports = [
      self.homeModules.cli
      self.homeModules.git
      self.homeModules.desktop
      self.homeModules.devtools
      self.homeModules.shells
      self.homeModules.workspace
    ];
    home.packages = [ pkgs.home-manager ];

    desktop.hyprland = {
      enable = true;
      bar.enable  = false;
      idle.enable = true;
      lock.enable = true;

      fern = {
        enable = true;
        obs.enable = false;
        themeWatcher.enable = false;
      };

      wallpaper = {
        enable = true;
        path = "/home/ada/wallpapers/shrine.png";
        monitor = "";  # Will auto-detect on Apple Silicon

        transition = {
          type = "fade";
          duration = 1.2;
          fps = 60;
        };
      };

      style = {
        gapsIn   = 6;
        gapsOut  = 12;
        border   = 2;
        rounding = 5;
      };
    };

    programs.gitSuite = {
      enable = true;
      userName = "adanoelle";
      userEmail = "adanoelleyoung@gmail.com";
      editor = "hx";
      enableGithub = true;
      enableTools = true;
      enableSafety = true;
      enableHelp = true;
    };

    programs.gitIdentities.identities = {
      personal = {
        name = "adanoelle";
        email = "adanoelleyoung@gmail.com";
        directory = "/home/ada/personal/";
        signingKey = "/home/ada/.ssh/github";
      };
      work = {
        name = "youngt0dd";
        email = "todd.young@pinnaclereliability.com";
        directory = "/home/ada/work/";
        signingKey = "/home/ada/.ssh/github-work";
        sshCommand = "ssh -i /home/ada/.ssh/github-work -o IdentitiesOnly=yes";
      };
    };

    home.stateVersion = "25.11";
  };

  nix.settings.trusted-users = [ "root" "ada" ];

  time.timeZone = "America/New_York";

  system.stateVersion = "25.11";
  networking.hostName = "moss";
}
