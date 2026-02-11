{ pkgs, config, ... }:

{
  # --- Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
    extraPackages = with pkgs; [
      gamescope
      mangohud
    ];
  };

  # --- GameScope (Valve micro-compositor for Wayland gaming)
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # --- GameMode (Feral Interactive CPU/GPU optimizer)
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };

  # --- Controller kernel modules
  boot.kernelModules = [
    "xpad" # Xbox controllers
    "hid_playstation" # PS4 DualShock 4 / PS5 DualSense
    "hid_nintendo" # Switch Pro Controller / Joy-Cons
  ];

  # --- Controller udev rules + services
  hardware.steam-hardware.enable = true;
  services.joycond.enable = true;

  # --- User groups
  users.users.ada.extraGroups = [ "gamemode" ];
}
