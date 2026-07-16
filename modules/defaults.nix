# modules/defaults.nix — global defaults applied to all hosts/users
{ den, ... }:
{
  den.default = {
    # Fallbacks for hosts/users that haven't pinned their own. Each host
    # must pin system.stateVersion at whatever release it was installed
    # with (see host-*.nix); a fleet-wide value only happens to be
    # correct while every machine was installed on the same release.
    nixos =
      { lib, ... }:
      {
        system.stateVersion = lib.mkDefault "25.11";
      };
    homeManager =
      { lib, ... }:
      {
        home.stateVersion = lib.mkDefault "25.11";
      };

    includes = [
      den._.define-user
      den._.primary-user
      den._.hostname
    ];
  };
}
