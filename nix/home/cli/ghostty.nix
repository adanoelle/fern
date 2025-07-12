# nix/home/cli/ghostty.nix
{ pkgs, ... }: {
  programs.ghostty = {
    enable  = true;

    # ── Core settings ──────────────────────────────────────────
    settings = {
      theme        = "catppuccin-mocha";
      "font-family"= "Iosevka Term";

      # Cursor / selection colours (optional)
      "cursor-color"         = "ffffff";
      "cursor-style"         = "block";
      "selection-foreground" = "1d2021";
      "selection-background" = "d5c4a1";
    };
  };

  # Optional: desktop entry is already provided by Ghostty’s package,
  # so no need to define xdg.desktopEntries unless you want overrides.
}

