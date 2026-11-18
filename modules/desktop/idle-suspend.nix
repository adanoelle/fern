# modules/desktop/idle-suspend.nix — suspend an idle laptop on battery
#
# Adds a second swayidle timeout to the one den.aspects.niri sets (lock
# after 10 minutes): after 20 idle minutes the machine suspends, but
# only when no mains supply is online, so a long build on the charger is
# never interrupted. The niri aspect's before-sleep hook locks first.
_: {
  den.aspects.idle-suspend.homeManager =
    { pkgs, lib, ... }:
    let
      suspend-on-battery = pkgs.writeShellApplication {
        name = "suspend-on-battery";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          for supply in /sys/class/power_supply/*; do
            if [ "$(cat "$supply/type" 2>/dev/null)" = "Mains" ] \
              && [ "$(cat "$supply/online" 2>/dev/null)" = "1" ]; then
              exit 0
            fi
          done
          exec systemctl suspend
        '';
      };
    in
    {
      services.swayidle.timeouts = [
        {
          timeout = 1200;
          command = lib.getExe suspend-on-battery;
        }
      ];
    };
}
