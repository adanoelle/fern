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

      keybind = [
        # Claude Code multi-line input (no collision)
        "shift+enter=text:\\n"
        
        # Terminal-specific bindings using Alt/Ctrl (avoids SUPER)
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        
        # Tab management (using Alt to avoid Hyprland's SUPER)
        "alt+t=new_tab"
        "alt+w=close_tab"
        "alt+1=goto_tab:1"
        "alt+2=goto_tab:2"
        "alt+3=goto_tab:3"
        "alt+4=goto_tab:4"
        "alt+5=goto_tab:5"
        
        # Pane splitting (using Alt+Shift)
        "alt+shift+v=new_split:right"
        "alt+shift+s=new_split:down"
        
        # Navigate splits with Alt (not SUPER)
        "alt+h=goto_split:left"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
        "alt+l=goto_split:right"
        
        # Resize with Ctrl+Alt
        "ctrl+alt+h=resize_split:left,10"
        "ctrl+alt+j=resize_split:down,10"
        "ctrl+alt+k=resize_split:up,10"
        "ctrl+alt+l=resize_split:right,10"
        
        # Scrolling
        "shift+page_up=scroll_page_up"
        "shift+page_down=scroll_page_down"
        
        # Font size adjustment
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };
  };

  # Optional: desktop entry is already provided by Ghostty’s package,
  # so no need to define xdg.desktopEntries unless you want overrides.
}

