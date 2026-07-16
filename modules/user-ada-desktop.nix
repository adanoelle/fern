# modules/user-ada-desktop.nix — user ada, desktop layer
#
# Graphical environment preferences: compositor settings, wallpaper,
# and the desktop application bundle. Only hosts with a graphical
# session forward this layer (via provides.to-users); a headless host
# simply never applies it.
{ den, ... }:
{
  den.aspects.ada-desktop = {
    includes = [
      den.aspects.desktop-apps
    ];

    homeManager =
      { config, ... }:
      {
        desktop.hyprland = {
          enable = true;
          bar.enable = false;
          idle.enable = true;
          lock.enable = true;

          fern = {
            enable = false;
            obs.enable = false;
            themeWatcher.enable = false;
          };

          wallpaper = {
            enable = true;
            path = "${config.home.homeDirectory}/media/wallpapers/shrine.png";

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
      };
  };
}
