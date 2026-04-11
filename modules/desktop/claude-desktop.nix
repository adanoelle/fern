{ den, inputs, ... }:
{
  den.aspects.claude-desktop.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
      ];
    };
}
