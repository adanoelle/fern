{ pkgs, config, ... }:
{
  users.users.ada = {
    isNormalUser  = true;
    extraGroups   = [ "wheel" "networkmanager" ];
    shell         = pkgs.nushell;
  };
  services.openssh.enable = true;
  services.networkmanager.enable = true;
}

