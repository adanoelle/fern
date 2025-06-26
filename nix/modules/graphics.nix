{ pkgs, config, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable     = true;   # needed for Wayland / Hyprland
    powerManagement.enable = true;   # runtime power savings
    open  = false;                   # ← choose: true = open source, false = proprietary
    package = config.boot.kernelPackages.nvidiaPackages.production;  # default 560.xx
  };

  
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "Hyprland";
      user    = "ada";
    };
  };
}
