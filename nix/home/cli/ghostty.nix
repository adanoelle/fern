# nix/home/cli/ghostty.nix
{ pkgs, ... }: {
  programs.ghostty = {
    enable  = true;

    # ── Core settings ──────────────────────────────────────────
    #
    settings = {
      font-family = "FiraCode Nerd Font";  # match the installed font
      font-size   = 11;
      # add other Ghostty settings here, e.g. theme, opacity, etc.
      theme = "catppuccin-frappe";  
    };
  };

  # Optional: desktop entry is already provided by Ghostty’s package,
  # so no need to define xdg.desktopEntries unless you want overrides.
}

