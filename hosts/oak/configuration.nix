{ self, inputs, pkgs, lib, ... }:

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
    self.nixosModules.monitoring
    self.nixosModules.greet
    self.nixosModules.localstack
    self.nixosModules.rust-dev
    self.nixosModules.teams
    self.nixosModules.typescript
    # self.nixosModules.secrets  # TODO: add oak's host key to .sops.yaml first
    self.nixosModules.guard
    self.nixosModules.vscode
    self.nixosModules.sqlserver

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # --- AMD GPU (uses Mesa/AMDGPU, no proprietary driver needed)
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;

  # --- Disable LightDM (auto-enabled when xserver is on);
  #     use greetd from the greet module instead.
  services.xserver.displayManager.lightdm.enable = false;

  # --- Disable regreet (GTK greeter renders with corruption on Granite Ridge iGPU);
  #     auto-login into Hyprland via greetd instead.
  programs.regreet.enable = lib.mkForce false;
  services.greetd.settings.default_session = {
    command = "${pkgs.hyprland}/bin/Hyprland";
    user = "ada";
  };

  environment.systemPackages = with pkgs; [
    mesa-demos # glxinfo, glxgears
    vulkan-tools # vulkaninfo, vkcube
  ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  home-manager.extraSpecialArgs = { inherit inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [
      self.homeModules.cli # cli: git, bat, ghostty, etc.
      self.homeModules.git # git: worktrees, tools, claude integration
      self.homeModules.desktop # hyprland
      self.homeModules.devtools # zig, cpp
      self.homeModules.shells # shells: nushell, starship, zoxide
      self.homeModules.workspace # manages xdg workspace directories
    ];
    home.packages = [ pkgs.home-manager ];

    desktop.hyprland = {
      enable = true;
      bar.enable = false; # Waybar (disabled - using Fern)
      idle.enable = true; # hypridle
      lock.enable = true; # hyprlock

      # Fern shell (QuickShell-based bar)
      fern = {
        enable = true;
        obs.enable = false;
        themeWatcher.enable = false;
      };

      wallpaper = {
        enable = true;
        path = "/home/ada/wallpapers/shrine.png";
        monitor = "";

        transition = {
          type = "fade";
          duration = 1.2;
          fps = 60;
        };
      };

      style = {
        gapsIn = 6;
        gapsOut = 12;
        border = 2;
        rounding = 5;
      };
    };

    # Enable git suite with all features
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

    # Configure git identities
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

  # Fern fonts (system-wide)
  services.fern-fonts.enable = true;

  time.timeZone = "America/New_York";

  system.stateVersion = "25.11";
  networking.hostName = "oak";
}
