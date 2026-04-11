# modules/users.nix — user accounts and networking
{ den, ... }:
{
  den.aspects.users.nixos =
    { pkgs, ... }:
    {
      users.users.ada = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "i2c"
        ];
        shell = pkgs.fish;
      };

      programs.fish.enable = true;

      networking.networkmanager.enable = true;
      services.openssh.enable = true;
    };
}
