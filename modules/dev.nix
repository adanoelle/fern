# modules/dev.nix — development shell & formatter
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          mdbook
          nixfmt-rfc-style
          statix
          deadnix
          flake-checker
          nix-output-monitor
          nvd
          # secrets management (see book/src/security/sops-nix.md)
          sops
          ssh-to-age
          age
        ];
      };
    };
}
