# modules/audio.nix — PipeWire audio stack
{ den, ... }:
{
  den.aspects.audio.nixos = { pkgs, ... }: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      extraConfig.pipewire."10-lowlatency.conf" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 64;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 128;
        };
      };
    };

    security.rtkit.enable = true;

    security.pam.loginLimits = [
      { domain = "ada"; item = "rtprio"; type = "-"; value = "95"; }
      { domain = "ada"; item = "memlock"; type = "-"; value = "unlimited"; }
    ];

    services.udev.extraRules = ''
      # Audient iD24
      ATTR{idVendor}=="2708", ATTR{idProduct}=="4002", \
        SYMLINK+="audio/audient_id24"
    '';

    environment.etc."wireplumber/conf.d/90-default-nodes.lua".text = ''
      rule = {
        matches = {
          { { "node.nick", "matches", "Audient iD24*" } },
          { { "node.nick", "matches", "USB-Audio - Topping*" } },
        },
        apply_properties = { ["priority.session"] = 2000 }
      }
      table.insert(alsa_monitor.rules, rule)
    '';

    environment.systemPackages = with pkgs; [
      audacity
      qpwgraph
      helvum
      pavucontrol
      easyeffects
      pulsemixer
    ];
  };
}
