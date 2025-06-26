{ pkgs, lib, ... }: {

  services.pipewire = {
    enable  = lib.mkForce true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.alsa.enable = true;
  hardware.pulseaudio.enable = false;
}

