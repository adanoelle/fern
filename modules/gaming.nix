# modules/gaming.nix — Steam, GameScope, GameMode
{ den, ... }:
{
  den.aspects.gaming.nixos = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [ gamescope mangohud ];
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

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

    boot.kernelModules = [
      "xpad"
      "hid_playstation"
      "hid_nintendo"
    ];

    hardware.steam-hardware.enable = true;
    services.joycond.enable = true;
    users.users.ada.extraGroups = [ "gamemode" ];
  };
}
