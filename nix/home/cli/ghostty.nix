{ pkgs, ... }:

let
  # Example text-based configuration. Adjust colors, fonts, etc.
  ghosttyCfg = ''
    # --- Appearance 
    theme       = catppuccin-frappe
    font-family = JetBrains Mono

    # --- Cursor / selection 
    cursor-color       = ffffff
    cursor-style       = block
    selection-foreground = 1d2021
    selection-background = d5c4a1

    # --- Keybindings 
    # Copy / paste (match Ghostty defaults but explicit)
    keybind = ctrl+shift+c = copy
    keybind = ctrl+shift+v = paste

    # Split pane shortcuts
    keybind = ctrl+shift+e = new_split:right
    keybind = ctrl+shift+o = new_split:down

    # Open the config in $EDITOR and reload at runtime
    keybind = ctrl+shift+, = open_config
    keybind = ctrl+shift+r = reload_config
  '';
in
{
  # 1. install ghostty binary
  home.packages = [ pkgs.ghostty ];

  # 2. put config at XDG path (~/.config/ghostty/config)
  home.file.".config/ghostty/config".text = ghosttyCfg;

  # 3. optional desktop entry (so it shows up in launchers)
  xdg.desktopEntries.ghostty = {
    name        = "Ghostty";
    exec        = "${pkgs.ghostty}/bin/ghostty";
    terminal    = false;
    categories  = [ "System" "Utility" ];
    comment     = "GPU-accelerated terminal emulator";
  };
}

