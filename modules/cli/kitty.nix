# modules/cli/kitty.nix — Kitty terminal emulator (garden stack)
{ den, inputs, ... }:
{
  den.aspects.kitty.homeManager = { pkgs, lib, ... }:
    let
      gardenThemes = inputs.garden-shell.packages.${pkgs.system}.garden-themes-output;
    in
    {
      programs.kitty = {
        enable = true;

        font = {
          name = "IBM Plex Mono";
          size = 11;
        };

        settings = {
          # Window — no decoration, Niri handles borders
          hide_window_decorations = "yes";
          window_padding_width = "12 16 12 16";

          # Typography
          modify_font = "cell_height 120%";

          # Shell — fish for garden stack
          shell = "${pkgs.fish}/bin/fish";

          # Remote control — allows `kitty @ set-colors` from inside this instance
          allow_remote_control = "yes";

          # Cursor
          cursor_shape = "beam";

          # Behavior
          confirm_os_window_close = 0;
          copy_on_select = "clipboard";
          mouse_hide_wait = "3.0";
          enable_audio_bell = "no";
        };

        extraConfig = ''
          include ${gardenThemes}/kitty/garden-theme.conf
        '';
      };

      # Both Kitty and Ghostty need their terminfo; combine both paths
      home.sessionVariables.TERMINFO_DIRS = lib.mkForce
        "${pkgs.kitty}/share/terminfo:${pkgs.ghostty}/share/terminfo";
    };
}
