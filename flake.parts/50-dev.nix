{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        just
        mdbook
        nixpkgs-fmt
      ];
    };
  };
}
