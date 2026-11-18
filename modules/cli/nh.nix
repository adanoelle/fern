# modules/cli/nh.nix — nh: NixOS rebuild helper with smart clean
_: {
  den.aspects.nh = {
    # Default flake location: the fern checkout in the home directory of
    # the host's (single) topology user. Same single-user assumption as
    # modules/secrets.nix.
    includes = [
      (
        { host, ... }:
        let
          user = (builtins.head (builtins.attrValues host.users)).userName;
        in
        {
          nixos =
            { config, lib, ... }:
            {
              # mkDefault is safe here (cf. the trusted-users note in
              # core.nix): upstream declares programs.nh.flake as
              # `nullOr str` with an OPTION default of null and never
              # defines it, so nothing competes at normal priority. Hosts
              # where the checkout lives elsewhere just set
              # programs.nh.flake plainly.
              programs.nh.flake = lib.mkDefault "${config.users.users.${user}.home}/src/fern";
            };
        }
      )
    ];

    nixos.programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 7d";
      };
    };
  };
}
