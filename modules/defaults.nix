# modules/defaults.nix — global defaults applied to all hosts/users
{ den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";

    includes = [
      den._.define-user
      den._.primary-user
      den._.hostname
    ];
  };
}
