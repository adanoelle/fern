# modules/desktop/brightness-backlight.nix — brightness keys for a laptop panel
#
# The built-in panel has a sysfs backlight, which brightnessctl sets
# through logind (no group membership needed). The garden shell watches
# the same sysfs value and shows its OSD when it changes, so unlike
# den.aspects.brightness-ddc there is no IPC call here.
#
# Forward it to users from the host (provides.to-users): it sets
# programs.niri.settings binds, so the host must carry the niri module.
_: {
  den.aspects.brightness-backlight.homeManager =
    { pkgs, lib, ... }:
    let
      brightnessctl = lib.getExe pkgs.brightnessctl;
    in
    {
      home.packages = [ pkgs.brightnessctl ];

      programs.niri.settings.binds = {
        "XF86MonBrightnessUp".action.spawn = [
          brightnessctl
          "set"
          "5%+"
        ];
        # Never below 1%, so the panel cannot be turned fully dark
        "XF86MonBrightnessDown".action.spawn = [
          brightnessctl
          "--min-value=1%"
          "set"
          "5%-"
        ];
      };
    };
}
