# modules/users.nix — user accounts and networking
{ den, ... }:
{
  den.aspects.users.nixos = { pkgs, ... }: {
    users.users.ada = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.nushell;
    };

    networking.networkmanager.enable = true;
    services.openssh.enable = true;
  };
}
