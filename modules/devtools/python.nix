# TEMPORARY: uv comes from inputs.nixpkgs-uv (a fresh nixos-unstable pin)
# because the shared nixpkgs pin still carries 0.11, older than projects
# require. Once `just update` moves the shared pin to uv >= 0.13.1, go back
# to `pkgs.uv` and delete the input in flake.nix.
{ inputs, ... }:
let
  freshUv = pkgs: inputs.nixpkgs-uv.legacyPackages.${pkgs.stdenv.hostPlatform.system}.uv;
in
{
  den.aspects.python = {
    nixos =
      { pkgs, ... }:
      let
        python = pkgs.python313;
      in
      {
        environment.systemPackages = [
          python
          (freshUv pkgs)
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          (freshUv pkgs)
          rye
          ruff
          black
          pyright
          pkgs.python313Packages.ipython
          pkgs.python313Packages.jupyterlab
        ];

        programs.helix.languages = {
          language-server.pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
          };
          language = [
            {
              name = "python";
              language-servers = [ "pyright" ];
              formatter = {
                command = "blackd";
                args = [ "-" ];
              };
            }
          ];
        };

        programs.zsh.enableCompletion = true;
      };
  };
}
