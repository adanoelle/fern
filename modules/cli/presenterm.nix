# modules/cli/presenterm.nix — presenterm terminal slideshows, PC-98 flavoured
#
# presenterm renders a markdown deck in the terminal (step-through code
# highlighting, live snippets, columns, speaker notes, PDF/HTML export).
# The look comes from the terminal, not the tool, so this aspect ships
# three pieces that only make sense together:
#
#   ~/.config/presenterm/themes/pc98.yaml   deck theme (colours, prefixes)
#   ~/.config/ghostty/pc98                  Ghostty overlay: pixel font + palette
#   ~/.config/kitty/pc98.conf               same for Kitty (has text sizing)
#
# and a `present` launcher that opens a deck fullscreen in one of them.
# Static assets live in _presenterm/ (underscore: not auto-imported).
_: {
  den.aspects.presenterm.homeManager =
    { pkgs, lib, ... }:
    let
      assets = ./_presenterm;

      present = pkgs.writeShellApplication {
        name = "present";
        runtimeInputs = [ pkgs.presenterm ];
        # Terminals are resolved from the user's PATH on purpose: on the
        # foreign (Ubuntu) home they are nixGL-wrapped, on NixOS they are not.
        text = ''
          # present [--kitty|--here] [presenterm args...] [deck.md]
          #   default   open the deck in a fullscreen PC-98 styled Ghostty
          #   --kitty   same, in Kitty (2x pixel headings via text sizing)
          #   --here    run presenterm in the current terminal, no new window
          # With no deck argument the bundled demo deck is shown.
          cfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
          data="''${XDG_DATA_HOME:-$HOME/.local/share}"

          term=ghostty
          case "''${1:-}" in
            --kitty) term=kitty; shift ;;
            --here) term=here; shift ;;
          esac

          if [ "$#" -eq 0 ]; then
            set -- "$data/presenterm/pc98-demo.md"
          fi

          case "$term" in
            ghostty)
              exec ghostty --config-file="$cfg/ghostty/pc98" -e presenterm "$@"
              ;;
            kitty)
              exec kitty --start-as fullscreen \
                --config "$cfg/kitty/kitty.conf" \
                --config "$cfg/kitty/pc98.conf" \
                presenterm "$@"
              ;;
            here)
              exec presenterm "$@"
              ;;
          esac
        '';
      };
    in
    {
      home.packages = [
        pkgs.presenterm
        present
        pkgs.ark-pixel-font # "Ark Pixel 16px M latin/ja" — 16px pixel font, PC-98 JIS feel
      ];

      # Fonts installed via home.packages are only visible to fontconfig
      # when the home-manager fontconfig hook is on (fonts.nix enables it
      # for foreign homes only).
      fonts.fontconfig.enable = lib.mkDefault true;

      xdg.configFile = {
        "presenterm/config.yaml".source = assets + /config.yaml;
        "presenterm/themes/pc98.yaml".source = assets + /pc98.yaml;
        "ghostty/pc98".source = assets + /ghostty-pc98;
        "kitty/pc98.conf".source = assets + /kitty-pc98.conf;
      };

      xdg.dataFile."presenterm/pc98-demo.md".source = assets + /pc98-demo.md;

      # User-level Claude Code skill so agents in any repo know how to write
      # and run a deck against this setup.
      home.file.".claude/skills/pc98-deck/SKILL.md".source = assets + /SKILL.md;
    };
}
