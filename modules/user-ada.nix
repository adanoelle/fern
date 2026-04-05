# modules/user-ada.nix — user ada aspect
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

    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.home-manager ];

      desktop.hyprland = {
        enable = true;
        bar.enable = false;
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
      };

      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
      };

      services.ssh-agent.enable = true;
    };
  };
}
