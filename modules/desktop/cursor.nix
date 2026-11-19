# modules/desktop/cursor.nix — the chrome key pointer
#
# A cursor theme drawn for this configuration: a chrome skeleton key
# with a red bow and a heart charm. The art is two vector drawings in
# ./_cursor: `key.svg`, and `key-small.svg`, a plainer key without the
# charm for the sizes where the charm would be a smudge. They are
# rendered to PNG at each size and packed with xcursorgen.
#
# Only the arrow is drawn so far. Every other shape (text, resize,
# busy, ...) comes from Adwaita through the theme's `Inherits`.
_: {
  den.aspects.cursor = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        themeName = "chrome-key";

        # size, drawing, and the click point: the tip of the key, in
        # the drawing's own 96-unit square.
        sizes = [
          {
            size = 24;
            art = "key-small";
            tip = 6;
          }
          {
            size = 32;
            art = "key-small";
            tip = 6;
          }
          {
            size = 48;
            art = "key";
            tip = 5;
          }
          {
            size = 64;
            art = "key";
            tip = 5;
          }
          {
            size = 96;
            art = "key";
            tip = 5;
          }
        ];

        theme =
          pkgs.runCommand "chrome-key-cursor"
            {
              nativeBuildInputs = [
                pkgs.resvg
                pkgs.xcursorgen
              ];
            }
            ''
              theme=$out/share/icons/${themeName}
              mkdir -p $theme/cursors
              ${lib.concatMapStrings (s: ''
                resvg -w ${toString s.size} -h ${toString s.size} \
                  ${./_cursor}/${s.art}.svg arrow-${toString s.size}.png
                echo "${toString s.size} ${toString (s.tip * s.size / 96)} ${toString (s.tip * s.size / 96)} arrow-${toString s.size}.png" >> arrow.cfg
              '') sizes}
              xcursorgen arrow.cfg $theme/cursors/default
              for name in left_ptr arrow top_left_arrow; do
                ln -s default $theme/cursors/$name
              done
              cat > $theme/index.theme <<THEME
              [Icon Theme]
              Name=Chrome Key
              Comment=A chrome key with a red bow and a heart charm
              Inherits=Adwaita
              THEME
            '';
      in
      {
        home.pointerCursor = {
          name = themeName;
          package = theme;
          # Large enough for the drawing with the charm.
          size = lib.mkDefault 48;
          gtk.enable = true;
        };

        # The shapes the theme does not draw yet.
        home.packages = [ pkgs.adwaita-icon-theme ];

        programs.niri.settings.cursor = {
          theme = themeName;
          inherit (config.home.pointerCursor) size;
        };
      };
  };
}
