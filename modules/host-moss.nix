# modules/host-moss.nix — moss Apple Silicon host aspect
#
# moss keeps an explicit aspect list rather than the workstation role:
# adopting the role would add nh and fonts, and Asahi hardware makes it
# quirky enough to compose by hand. Revisit once the role settles.
{ den, inputs, ... }:
{
  den.aspects.moss = {
    includes = [
      den.aspects.boot-asahi
      den.aspects.core
      den.aspects.docker
      den.aspects.users
      den.aspects.audio
      den.aspects.graphics-asahi
      den.aspects.greetd
      den.aspects.secrets
      den.aspects.secrets-guard
    ];

    # moss is a portable workstation: its users get the same desktop
    # and dev layers as on fern.
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
    ];

    nixos = {
      imports = [
        ../hosts/moss/hardware.nix
        inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
      ];

      # Frozen at the release moss was installed with. NEVER bump this:
      # it gates stateful data migrations, not features.
      system.stateVersion = "25.11";
    };
  };
}
