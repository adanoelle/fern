# modules/fonts.nix — system fonts
{ den, ... }:
{
  den.aspects.fonts.nixos = { pkgs, ... }: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            "FiraCode Nerd Font"
            "JetBrainsMono Nerd Font"
            "DejaVu Sans Mono"
          ];
        };
      };
    };
  };
}
