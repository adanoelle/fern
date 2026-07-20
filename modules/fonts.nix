# modules/fonts.nix — system fonts (garden typography)
_: {
  den.aspects.fonts.nixos =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          # Garden typography
          mplus-outline-fonts.githubRelease # M PLUS 1p (UI sans-serif)
          ibm-plex # IBM Plex Mono (terminal, data)

          # Nerd Font fallbacks (icons)
          nerd-fonts.fira-code
          nerd-fonts.jetbrains-mono
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [
              "IBM Plex Mono"
              "FiraCode Nerd Font"
              "JetBrainsMono Nerd Font"
              "DejaVu Sans Mono"
            ];
            sansSerif = [
              "M PLUS 1p"
              "DejaVu Sans"
            ];
            serif = [
              "M PLUS 1p"
              "DejaVu Serif"
            ];
          };
        };
      };
    };
}
