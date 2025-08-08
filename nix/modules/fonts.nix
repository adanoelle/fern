# nix/modules/fonts.nix
{ pkgs, lib, ... }: {
  # Install your chosen Nerd Fonts system‑wide
  fonts = {
    packages = with pkgs; [
      # On nixpkgs ≥ 25.05, use the subpackages under `nerd-fonts.*`
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;

      # Configure font fallback for monospace text.  These names must match the
      # "family" names registered in the font files; adjust if necessary.
      defaultFonts = {
        monospace = [
          "FiraCode Nerd Font"       # primary monospace font
          "JetBrainsMono Nerd Font"  # secondary monospace fallback
          "DejaVu Sans Mono"         # final fallback for missing glyphs
        ];
        # You can also customise serif/sansSerif lists here if desired.
      };
    };
  };

  # Optionally make fonts available in /run/current-system/sw/share/X11/fonts
  # for Flatpak apps and other consumers.  See the NixOS wiki for details:contentReference[oaicite:2]{index=2}.
  # fonts.fontDir.enable = true;
}

