# modules/user-ada-work.nix — user ada, ORNL work-laptop layer
#
# Standalone-home layer for the Ubuntu work laptop: the full niri +
# garden desktop plus the dev toolchain, on top of the base ada aspect.
# Deliberately NOT ada-desktop — hyprland, DAW, and gaming don't belong
# on a work machine. garden.shell is included explicitly: on fern the
# garden QML/tooling arrives by other means, but a standalone home has
# to pull the whole bundle itself.
#
# Attached below via den.aspects.ada.provides."_work-host_", which
# den's mutual-provider routes into the standalone home (see
# ctx.home.includes in modules/dendritic.nix and the den.homes entry in
# modules/hosts.nix).
{ den, garden, ... }:
{
  den.aspects.ada-work = {
    includes = [
      den.aspects.ada-dev
      den.aspects.niri-standalone
      den.aspects.ubuntu-desktop
      garden.shell
      den.aspects.fonts
      den.aspects.imv
      den.aspects.screenshot
    ];

    homeManager =
      { pkgs, lib, ... }:
      {
        # Laptop panel brightness. The shared niri aspect binds ddcutil
        # (DDC/CI, external monitors only); on a laptop the internal
        # panel needs sysfs backlight via brightnessctl instead.
        # ddcutil remains available for docked external monitors.
        home.packages = [ pkgs.brightnessctl ];

        programs.niri.settings.binds = {
          "XF86MonBrightnessUp".action = lib.mkForce {
            spawn = [
              "brightnessctl"
              "set"
              "5%+"
            ];
          };
          "XF86MonBrightnessDown".action = lib.mkForce {
            spawn = [
              "brightnessctl"
              "set"
              "5%-"
            ];
          };
        };
      };
  };

  # Placeholder host name: replace _work-host_ (and _ornlid_ in
  # modules/hosts.nix) with the real values once the laptop's hostname
  # and ORNL user id are known.
  den.aspects.ada.provides."_work-host_".includes = [ den.aspects.ada-work ];
}
