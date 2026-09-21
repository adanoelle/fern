# modules/cli/herdr.nix — herdr terminal multiplexer with AI agent awareness
#
# Keybindings follow the Niri/Ghostty/tmux/vi-mode stack:
#   Prefix:  Ctrl+Space  (same as tmux)
#   Panes:   h/j/k/l     (navigate), v/s (split)
{ den, ... }:
{
  den.aspects.herdr.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.herdr ];

      xdg.configFile."herdr/config.toml".text = ''
        [keys]
        prefix = "ctrl+space"

        [keys.pane]
        navigate_left = "h"
        navigate_down = "j"
        navigate_up = "k"
        navigate_right = "l"
        split_vertical = "v"
        split_horizontal = "s"
        close = "x"

        [theme]
        name = "catppuccin-frappe"
      '';
    };
}
