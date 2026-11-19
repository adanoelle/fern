# modules/desktop/cursor.nix — the chrome key pointer
#
# A cursor theme drawn for this configuration: a chrome skeleton key
# with a red bow and a heart charm. The art is vector drawings in
# ./_cursor: `key.svg`, and `key-small.svg`, a plainer key without the
# charm for the sizes where the charm would be a smudge. They are
# rendered to PNG at each size and packed with xcursorgen.
#
# The arrow, the text beam (`text.svg`), the pointing hand (`hand.svg`),
# the open hand (`open.svg`), the closed fist for dragging (`fist.svg`),
# the two busy pointers (`wait.svg`, and the key with `spin.svgfrag`
# over it), the padlock for "not allowed" (`lock.svg`) and the resize
# arrows (`resize.svg`, turned four ways), the crosshair (`cross.svg`)
# and the move arrows (`move.svg`) are drawn so far. Every other shape
# (help, zoom, ...) comes from Adwaita through the theme's `Inherits`.
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

        # The shapes drawn so far. Each lists its sizes with the drawing
        # used and the click point, given in the drawing's own 96-unit
        # square; `names` are the other names clients ask for it by.
        # A moving shape also gives `frames`, each a set of values for
        # the `@token@`s in its drawing, and the `delay` between them in
        # milliseconds; `overlay` is a fragment laid over the drawing.
        # The frames of the turning star. It has four points, so a
        # quarter turn brings it back to the start; the two small
        # sparkles swell and shrink in turn.
        spin = [
          {
            turn = "0";
            a = "1.0";
            b = "0.2";
          }
          {
            turn = "11.25";
            a = "0.85";
            b = "0.35";
          }
          {
            turn = "22.5";
            a = "0.6";
            b = "0.6";
          }
          {
            turn = "33.75";
            a = "0.35";
            b = "0.85";
          }
          {
            turn = "45";
            a = "0.2";
            b = "1.0";
          }
          {
            turn = "56.25";
            a = "0.35";
            b = "0.85";
          }
          {
            turn = "67.5";
            a = "0.6";
            b = "0.6";
          }
          {
            turn = "78.75";
            a = "0.85";
            b = "0.35";
          }
        ];

        # A resize arrow: the one drawing turned to `turn` degrees. The
        # click point is its middle.
        resize = turn: names: {
          inherit names;
          frames = [ { inherit turn; } ];
          sizes =
            map
              (size: {
                inherit size;
                art = "resize";
                x = 48;
                y = 48;
              })
              [
                24
                32
                48
                64
                96
              ];
        };

        shapes = rec {
          # The key: the click point is its tip. The two smallest
          # sizes use the plainer drawing.
          default = {
            names = [
              "left_ptr"
              "arrow"
              "top_left_arrow"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = if size < 48 then "key-small" else "key";
                  x = if size < 48 then 6 else 5;
                  y = if size < 48 then 6 else 5;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # A ringed hand for links and buttons: the click point is the
          # fingertip.
          pointer = {
            names = [
              "hand"
              "hand1"
              "hand2"
              "pointing_hand"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "hand";
                  x = 34;
                  y = 6;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # The same hand open, shown over things that can be dragged. The
          # click point is the middle of the palm.
          grab = {
            names = [ "openhand" ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "open";
                  x = 48;
                  y = 52;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # The same hand closed, for dragging: four rings across the
          # knuckles. The click point is the middle of the fist.
          grabbing = {
            names = [
              "closedhand"
              "dnd-move"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "fist";
                  x = 48;
                  y = 46;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # Busy: a chrome star turning around a red heart.
          wait = {
            names = [ "watch" ];
            frames = spin;
            delay = 80;
            sizes =
              map
                (size: {
                  inherit size;
                  art = "wait";
                  x = 48;
                  y = 48;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # Working, but still clickable: the key with a sparkle turning
          # beside it.
          progress = {
            names = [
              "left_ptr_watch"
              "half-busy"
            ];
            overlay = "spin.svgfrag";
            frames = spin;
            delay = 80;
            inherit (default) sizes;
          };
          # Not allowed: a heart-shaped padlock. The click point is the
          # keyhole.
          not-allowed = {
            names = [
              "forbidden"
              "crossed_circle"
              "circle"
              "no-drop"
              "dnd-no-drop"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "lock";
                  x = 48;
                  y = 62;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # The four resize arrows, for window edges and corners.
          ew-resize = resize "0" [
            "e-resize"
            "w-resize"
            "col-resize"
            "left_side"
            "right_side"
            "sb_h_double_arrow"
            "h_double_arrow"
            "size_hor"
            "split_h"
          ];
          ns-resize = resize "90" [
            "n-resize"
            "s-resize"
            "row-resize"
            "top_side"
            "bottom_side"
            "sb_v_double_arrow"
            "v_double_arrow"
            "size_ver"
            "split_v"
          ];
          nwse-resize = resize "45" [
            "nw-resize"
            "se-resize"
            "top_left_corner"
            "bottom_right_corner"
            "size_fdiag"
            "bd_double_arrow"
          ];
          nesw-resize = resize "-45" [
            "ne-resize"
            "sw-resize"
            "top_right_corner"
            "bottom_left_corner"
            "size_bdiag"
            "fd_double_arrow"
          ];
          # A long thin sparkle with an open middle, for picking an exact
          # spot.
          crosshair = {
            names = [
              "cross"
              "tcross"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "cross";
                  x = 48;
                  y = 48;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # Arrows four ways from a heart, for moving and for scrolling
          # in every direction.
          move = {
            names = [
              "fleur"
              "size_all"
              "all-scroll"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "move";
                  x = 48;
                  y = 48;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
          # A slim beam with a red bead: the click point is its centre.
          text = {
            names = [
              "xterm"
              "ibeam"
            ];
            sizes =
              map
                (size: {
                  inherit size;
                  art = "text";
                  x = 48;
                  y = 48;
                })
                [
                  24
                  32
                  48
                  64
                  96
                ];
          };
        };

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
              ${lib.concatStrings (
                lib.mapAttrsToList (shape: def: ''
                  ${lib.concatMapStrings (
                    s:
                    let
                      n = toString s.size;
                      art = "${./_cursor}/${s.art}.svg";
                      frames = def.frames or [ { } ];
                    in
                    lib.concatImapStrings (
                      i: frame:
                      let
                        png = "${shape}-${n}-${toString i}.png";
                        fill = lib.concatStrings (lib.mapAttrsToList (token: value: " -e 's/@${token}@/${value}/g'") frame);
                      in
                      ''
                        ${
                          if def ? overlay then
                            "{ head -n -1 ${art}; cat ${./_cursor}/${def.overlay}; echo '</svg>'; }"
                          else
                            "cat ${art}"
                        } | sed -e 's/@@/@@/'${fill} > frame.svg
                        resvg -w ${n} -h ${n} frame.svg ${png}
                        echo "${n} ${toString (s.x * s.size / 96)} ${toString (s.y * s.size / 96)} ${png}${
                          lib.optionalString (def ? delay) " ${toString def.delay}"
                        }" >> ${shape}.cfg
                      ''
                    ) frames
                  ) def.sizes}
                  xcursorgen ${shape}.cfg $theme/cursors/${shape}
                  ${lib.concatMapStrings (name: ''
                    ln -s ${shape} $theme/cursors/${name}
                  '') def.names}
                '') shapes
              )}
              cat > $theme/index.theme <<THEME
              [Icon Theme]
              Name=Chrome Key
              Comment=A chrome key with a red bow and a heart charm
              Inherits=Adwaita
              THEME
            '';

        niri = lib.getExe config.programs.niri.package;
        niriConfig = "${config.xdg.configHome}/niri/config.kdl";
        inherit (config.home.pointerCursor) size;

        # niri re-reads the cursor theme only when its cursor settings
        # change. When the theme's files change under the same name it
        # keeps the old pointer, so this loads a copy of the config
        # with another size and then the real one again.
        cursorReload = pkgs.writeShellApplication {
          name = "cursor-reload";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.gnused
          ];
          text = ''
            if [ -z "''${NIRI_SOCKET:-}" ] || ! ${niri} msg version >/dev/null 2>&1; then
              echo "cursor-reload: no running niri session" >&2
              exit 0
            fi
            nudge=$(mktemp --suffix=.kdl)
            trap 'rm -f "$nudge"' EXIT
            sed 's/xcursor-size ${toString size}$/xcursor-size ${toString (size - 1)}/' \
              ${niriConfig} > "$nudge"
            ${niri} msg action load-config-file --path "$nudge"
            sleep 0.5
            ${niri} msg action load-config-file --path ${niriConfig}
          '';
        };
      in
      {
        home.pointerCursor = {
          enable = true;
          name = themeName;
          package = theme;
          # Large enough for the drawing with the charm.
          size = lib.mkDefault 48;
          gtk.enable = true;
        };

        # The shapes the theme does not draw yet.
        home.packages = [
          pkgs.adwaita-icon-theme
          cursorReload
        ];

        # A switch links niri's config before the theme, and does not
        # touch the config at all when only the drawing changed. Either
        # way a running niri is left with a stale pointer, so reload it
        # whenever the theme is not the one last activated.
        home.activation.cursorReload = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          seen="${config.xdg.stateHome}/cursor-theme"
          if [ "$(cat "$seen" 2>/dev/null)" != "${theme}" ]; then
            run ${lib.getExe cursorReload} || true
            run mkdir -p "$(dirname "$seen")"
            run sh -c 'echo "${theme}" > "$0"' "$seen"
          fi
        '';

        programs.niri.settings.cursor = {
          theme = themeName;
          inherit size;
        };
      };
  };
}
