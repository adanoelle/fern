# modules/host-moss.nix — moss Apple Silicon host aspect
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

    nixos = { pkgs, ... }: {
      imports = [
        ../hosts/moss/hardware.nix
        inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
      ];

      programs.nix-ld.enable = true;
      nix.settings.trusted-users = [ "root" "ada" ];
      time.timeZone = "America/New_York";
    };
  };
}
