# modules/dev.nix — development shell & formatter
_: {
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          mdbook
          nixfmt
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
