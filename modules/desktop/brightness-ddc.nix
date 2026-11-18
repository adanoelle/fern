# modules/desktop/brightness-ddc.nix — brightness keys for external monitors
#
# DDC/CI control through ddcutil, for desktops whose displays have no
# sysfs backlight. A laptop panel wants a backlight-based aspect instead,
# which is why this is separate from den.aspects.niri.
#
# Forward it to users from the host (provides.to-users): the home side
# sets programs.niri.settings binds, so it needs a host that carries the
# niri module, and the nixos side then reaches the host through the same
# include. "i2c" group membership is granted in modules/users.nix.
_: {
  den.aspects.brightness-ddc = {
    nixos =
      { pkgs, ... }:
      {
        # DDC/CI needs i2c-dev
        hardware.i2c.enable = true;
        environment.systemPackages = [ pkgs.ddcutil ];
      };

    homeManager =
      { pkgs, ... }:
      let
        # Store path so binds survive quickshell not being on PATH
        qs = "${pkgs.quickshell}/bin/qs";
      in
      {
        # The IPC call first shows the garden OSD optimistically
        # (ddcutil takes ~200ms and the poll is 3s).
        programs.niri.settings.binds = {
          "XF86MonBrightnessUp".action.spawn = [
            "sh"
            "-c"
            "${qs} -c garden ipc call garden stepBrightnessOsd 5; exec ddcutil setvcp 10 + 5"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "sh"
            "-c"
            "${qs} -c garden ipc call garden stepBrightnessOsd -5; exec ddcutil setvcp 10 - 5"
          ];
        };
      };
  };
}
