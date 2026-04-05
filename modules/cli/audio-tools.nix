{ den, ... }:
{
  den.aspects.audio-tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ lsp-plugins ];
  };
}
