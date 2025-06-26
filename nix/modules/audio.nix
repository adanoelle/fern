{ pkgs, ... }: {
  services.pipewire = {
    enable  = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.desktop.easyeffects.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
}

