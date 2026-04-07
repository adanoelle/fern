# modules/cli/kitty.nix — Kitty terminal emulator (garden stack)
{ den, ... }:
{
  den.aspects.kitty.homeManager = { pkgs, lib, ... }:
    let
      # Mokume palette (hardcoded — will be generated from palettes.json later)
      mokume = {
        base-deep = "#252d3b";
        base = "#2c3444";
        base-raised = "#343d4f";
        base-hl = "#3d4759";
        border-sub = "#3a4456";
        border = "#4a5568";
        text-4 = "#505e70";
        text-3 = "#6b7a8d";
        text-2 = "#8b9bb0";
        text-1 = "#d4c5a9";
        accent = "#c9b88c";
        urgent = "#c4796b";
        ok = "#7c9a7c";
      };
    in
    {
      programs.kitty = {
        enable = true;

        font = {
          name = "IBM Plex Mono";
          size = 11;
        };

        settings = {
          # Mokume palette
          background = mokume.base;
          foreground = mokume.text-1;
          cursor = mokume.text-1;
          cursor_shape = "beam";
          selection_background = mokume.base-hl;
          selection_foreground = mokume.text-1;

          # ANSI 16 — mapped to garden semantic roles
          color0 = mokume.base-deep; # black
          color1 = mokume.urgent; # red
          color2 = mokume.ok; # green
          color3 = mokume.accent; # yellow
          color4 = mokume.text-3; # blue
          color5 = "#8b7a8d"; # muted purple
          color6 = "#6b8a8d"; # muted cyan
          color7 = mokume.text-2; # white
          color8 = mokume.text-4; # bright black
          color9 = mokume.urgent; # bright red
          color10 = mokume.ok; # bright green
          color11 = mokume.accent; # bright yellow
          color12 = mokume.text-2; # bright blue
          color13 = "#9b8a9d"; # lighter purple
          color14 = "#7b9a9d"; # lighter cyan
          color15 = mokume.text-1; # bright white

          # Window — no decoration, Niri handles borders
          hide_window_decorations = "yes";
          window_padding_width = "12 16 12 16";

          # Typography
          modify_font = "cell_height 120%";

          # Shell — fish for garden stack
          shell = "${pkgs.fish}/bin/fish";

          # Remote control — allows `kitty @ set-colors` from inside this instance
          allow_remote_control = "yes";

          # Behavior
          confirm_os_window_close = 0;
          copy_on_select = "clipboard";
          mouse_hide_wait = "3.0";
          enable_audio_bell = "no";
        };
      };

      # Both Kitty and Ghostty need their terminfo; combine both paths
      home.sessionVariables.TERMINFO_DIRS = lib.mkForce
        "${pkgs.kitty}/share/terminfo:${pkgs.ghostty}/share/terminfo";
    };
}
