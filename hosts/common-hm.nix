# hosts/common-hm.nix
# Shared home-manager config for user ada across all x86_64 hosts.
# Per-host overrides (e.g. wallpaper monitors) live in each host's configuration.nix.
{ self, pkgs, ... }:

{
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
}
