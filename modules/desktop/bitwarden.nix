# modules/desktop/bitwarden.nix — Bitwarden desktop app
_: {
  den.aspects.bitwarden = {
    # bitwarden-desktop currently ships an EOL electron in nixpkgs; scope
    # the insecure-package exception to hosts carrying this aspect (same
    # pattern as csharp.nix's dotnet 6 exception).
    nixos = {
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.bitwarden-desktop ];
      };
  };
}
