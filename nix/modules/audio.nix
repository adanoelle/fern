{ pkgs, ... }: {

  services.pipewire = {
    enable  = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.alsa.enable = true;
  hardware.pulseaudio.enable = false;
}

