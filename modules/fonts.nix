# modules/fonts.nix — garden typography (system + home sides)
#
# nixos side: system-wide fonts for NixOS hosts.
# homeManager side: the same fonts via home.packages + user-level
# fontconfig, for standalone homes on foreign distros (the ORNL work
# laptop). NixOS hosts include only the nixos side, so fern is
# unaffected by the homeManager half.
_:
let
  fontPackages =
    pkgs: with pkgs; [
      # Garden typography
      mplus-outline-fonts.githubRelease # M PLUS 1p (UI sans-serif)
      ibm-plex # IBM Plex Mono (terminal, data)

      # Nerd Font fallbacks (icons)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

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
in
{
  den.aspects.fonts = {
    nixos =
      { pkgs, ... }:
      {
        fonts = {
          packages = fontPackages pkgs;
          fontconfig = {
            enable = true;
            inherit defaultFonts;
          };
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = fontPackages pkgs;
        fonts.fontconfig = {
          enable = true;
          inherit defaultFonts;
        };
      };
  };
}
