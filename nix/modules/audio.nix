{ pkgs, lib, ... }:

{
  # --- PipeWire core (JACK + Pulse)                                   
  services.pipewire = {
    enable = true;

    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;

    # Low‑latency settings for all nodes – works on unstable
    extraConfig.pipewire."10-lowlatency.conf" = {
      "context.properties" = {
        "default.clock.rate"    = 48000;  # Hz
        "default.clock.quantum" = 64;     # frames
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 128;
      };
    };
  };

  # ---  Realtime priority                                              
  security.rtkit.enable = true;

  security.pam.loginLimits = [
    { domain = "ada"; item = "rtprio"; type = "-"; value = "95"; }
    { domain = "ada"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  # --- Udev rule for Audient iD24
  services.udev.extraRules = ''
    # Audient iD24
    ATTR{idVendor}=="2708", ATTR{idProduct}=="4002", \
      SYMLINK+="audio/audient_id24"
  '';

  # --- WirePlumber rule: prefer iD24 in / out, Topping for playback
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

  # --- GUI / CLI utilities                                            
  environment.systemPackages = with pkgs; [
    # Patch‑bay & monitor
    audacity
    qpwgraph
    helvum
    pavucontrol
    easyeffects
    pulsemixer
  ];
}

