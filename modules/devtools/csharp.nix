{ den, ... }:
{
  den.aspects.csharp = {
    nixos =
      { pkgs, ... }:
      {
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
