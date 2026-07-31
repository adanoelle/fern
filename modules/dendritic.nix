# modules/dendritic.nix — den bootstrap
{
  den,
  inputs,
  ...
}:
{
  imports = [
    (inputs.den.flakeModule or inputs.den.flakeModules.den)
  ];

  den = {
    ctx = {
      # Enable host→user aspect forwarding via provides.to-users
      user.includes = [ den._.mutual-provider ];

      # Same routing for standalone homes (den.homes."user@host"): the
      # home's aspect can declare provides.<hostName> layers, mirroring
      # what provides.to-users does for hosted users. Used by the ORNL
      # work laptop (see modules/user-ada-work.nix).
      home.includes = [ den._.mutual-provider ];

      # Home-manager bridge
      hm-host.nixos.home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };
      };
    };

    # Default user class
    schema.user.classes = [ "homeManager" ];
  };
}
