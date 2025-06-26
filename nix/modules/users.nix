{ pkgs, config, ... }:
{
  users.users.ada = {
    isNormalUser  = true;
    extraGroups   = [ "wheel" "networkmanager" ];
    shell         = pkgs.nushell;
  };

  networking.networkmanager.enable = true;
  services.openssh.enable = true;
}

