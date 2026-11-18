# modules/user-ada-hyprland.nix — user ada, Hyprland fallback session layer
#
# The Hyprland session and ada's settings for it. Separate from
# ada-desktop so a host can have the desktop apps without carrying a
# second compositor; hosts that keep the fallback session forward this
# layer alongside ada-desktop (and enable programs.hyprland themselves).
{ den, ... }:
{
  den.aspects.ada-hyprland = {
    includes = [ den.aspects.hyprland ];

    homeManager =
      { config, ... }:
      {
        desktop.hyprland = {
          enable = true;
          idle.enable = true;
          lock.enable = true;

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
