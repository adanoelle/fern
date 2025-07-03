# nix/modules/devtools/csharp-toolchain.nix
{ pkgs, ... }: {

  # .NET 8.0 SDK + runtime – combines ASP.NET & tools :contentReference[oaicite:1]{index=1}
  environment.systemPackages = [
    (with pkgs.dotnetCorePackages; combinePackages [ sdk_8_0 aspnetcore_8_0 ])
  ];

  # Make msbuild & Mono available for older projects :contentReference[oaicite:2]{index=2}
  environment.systemPackages = [
    pkgs.mono pkgs.msbuild
  ];

  # Ensure dotnet finds its CLI tools
  environment.variables.DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}";
}

