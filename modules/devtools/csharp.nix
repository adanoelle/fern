{ den, ... }:
{
  den.aspects.csharp = {
    nixos =
      { pkgs, ... }:
      {
        # Parts of the .NET toolchain here still pull in EOL dotnet 6;
        # scope the insecure-package exception to hosts that actually
        # carry this aspect instead of the whole fleet (was in core.nix).
        nixpkgs.config.permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "dotnet-runtime-6.0.36"
        ];

        environment.systemPackages = [
          (
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_8_0
              aspnetcore_8_0
            ]
          )
          pkgs.mono
          pkgs.msbuild
        ];

        environment.variables.DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}";
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          omnisharp-roslyn
          dotnet-sdk_8
          nuget-to-nix
        ];

        programs.helix.languages = {
          language-server.omnisharp = {
            command = "omnisharp";
            args = [ "-lsp" ];
          };
          language = [
            {
              name = "c-sharp";
              language-servers = [ "omnisharp" ];
            }
          ];
        };
      };
  };
}
