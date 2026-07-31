# modules/bluetooth.nix — BlueZ + PipeWire bluetooth audio
#
# Enables the bluetooth stack with experimental features (battery
# reporting for AirPods) and configures WirePlumber to prefer AAC
# codec over SBC for bluetooth audio quality.
{ ... }:
{
  den.aspects.bluetooth.nixos =
    { pkgs, ... }:
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
            FastConnectable = true;
          };
        };
      };

      services.pipewire.wireplumber.extraConfig."20-bluetooth-codecs" = {
        "monitor.bluez.rules" = [
          {
            matches = [
              { "device.name" = "~bluez_card.*"; }
            ];
            actions.update-props = {
              "bluez5.auto-connect" = "[ a2dp_sink hfp_hf ]";
              "bluez5.codecs" = "[ aac sbc_xq sbc ]";
            };
          }
        ];
      };

      environment.systemPackages = [ pkgs.bluez ];
    };
}
