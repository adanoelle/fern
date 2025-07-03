# nix/hm-modules/devtools/csharp.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    omnisharp-roslyn          # LSP server for C# :contentReference[oaicite:4]{index=4}
    dotnet-sdk_8              # local tool‑use without sudo
    nuget-to-nix              # helper to vendor NuGet deps (optional)
  ];

  programs.helix.languages = {
    language-server.omnisharp = {
      command = "omnisharp";
      args    = [ "-lsp" ];
    };
    language = [
      { name = "c-sharp"; language-servers = [ "omnisharp" ]; }
    ];
  };
}

