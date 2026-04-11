# modules/dendritic.nix — den bootstrap
{
  den,
  inputs,
  lib,
  ...
}:
{
  imports = [
    (inputs.den.flakeModule or inputs.den.flakeModules.den)
  ];

  den = {
    # Enable host→user aspect forwarding via provides.to-users
    ctx.user.includes = [ den._.mutual-provider ];

    # Home-manager bridge
    ctx.hm-host.nixos.home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
    };

    # Default user class
    schema.user.classes = [ "homeManager" ];
  };
}
