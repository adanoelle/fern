# modules/desktop/wallpaper.nix — painted wallpapers for the niri session
#
# A "study" pairs a garden palette built from a painter's working
# colours with that painter's paintings. Whichever palette is active
# decides the study on the wall, so switching palette (garden Settings,
# or `garden-study`) changes both together; within a study,
# `garden-study painting` steps through its paintings. A palette
# without a study shows the default one.
#
# A painting whose colour departs from its painter's can name its own
# `palette`; choosing that painting applies it, and choosing that
# palette puts the painting on the wall. When the painting changes, its
# placard (title, painter, year, collection) is shown as a notification.
#
# This file is only the mechanism. The studies themselves are data,
# one file per palette in ./_studies/<palette>.nix (picked up
# automatically): the painter and a list of paintings, each with its
# attribution, a pinned open-access source image, where to crop it and
# optionally its own palette. The palettes' colours live in
# garden-shell's palettes.toml.
#
# Each painting gets two renditions:
#   - ultrawide.jpg: a 3440x1440 band of the canvas, chosen by hand so
#     heads stay clear of the bar. A plain centre crop usually doesn't.
#   - panel.jpg: for the 16:10 laptop panel and any other output.
#     Either a chosen 2400x1500 crop, or (no `panel` given) the whole
#     painting at 2400 px wide, which swaybg fills and lightly crops.
# Crops are given in thousandths of the source: `top` is where the crop
# starts, `left`/`right` its sides (default the full width); the height
# follows from the output's shape. A painting can instead bring `ready`
# images, already cropped by the museum's IIIF server.
#
# swaybg picks per output. It can only match the ultrawide by connector
# name ("DP-2"): its make/model matching parses a "(name)" suffix niri's
# wl_output description doesn't have. On another dock/port the monitor
# just gets the panel rendition centre-cropped.
#
# swaybg draws with wl_shm (no GL), so no nixGL wrapping on Ubuntu. It
# runs as a user service bound to graphical-session.target, which
# niri.service activates on NixOS and on the standalone-home laptop.
# Hyprland on fern keeps its own awww wallpaper (desktop/_hyprland).
_: {
  den.aspects.wallpaper.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      # The study shown when the active palette has none of its own.
      defaultStudy = "shitanuri";

      studies = lib.mapAttrs' (
        file: _:
        lib.nameValuePair (lib.removeSuffix ".nix" file) (pkgs.callPackage (./_studies + "/${file}") { })
      ) (builtins.readDir ./_studies);

      # The palette a painting is shown with: its own, or its study's.
      paletteOf = study: painting: painting.palette or study;

      # palette -> study. A palette can only belong to one study.
      paletteStudy = lib.foldl' (
        acc: study:
        lib.foldl' (
          acc: palette:
          if (acc.${palette} or study) != study then
            throw "wallpaper: palette '${palette}' is used by studies '${acc.${palette}}' and '${study}'"
          else
            acc // { ${palette} = study; }
        ) acc ([ study ] ++ map (paletteOf study) studies.${study}.paintings)
      ) { } (lib.attrNames studies);

      # crop <out> <width> <height> <left> <right> <top>
      render =
        study: painting:
        let
          region =
            r:
            toString [
              (r.left or 0)
              (r.right or 1000)
              r.top
            ];
          inherit (studies.${study}) painter;
          caption = "${painter}, ${painting.title} (${painting.year}). ${painting.collection}";
          # Three lines, as on a museum label.
          placard = "${painting.title}\n${painter}, ${painting.year}\n${painting.collection}\n";
        in
        pkgs.runCommand "study-${study}-${painting.name}" { nativeBuildInputs = [ pkgs.imagemagick ]; } (
          ''
            mkdir -p $out
            printf '%s\n' ${lib.escapeShellArg caption} > $out/caption
            printf ${lib.escapeShellArg placard} > $out/placard
            printf '%s\n' ${lib.escapeShellArg (paletteOf study painting)} > $out/palette
          ''
          + (
            if painting ? ready then
              ''
                ln -s ${painting.ready.ultrawide} $out/ultrawide.jpg
                ln -s ${painting.ready.panel} $out/panel.jpg
              ''
            else
              ''
                src=${painting.src}
                w=$(magick identify -format %w "$src")
                h=$(magick identify -format %h "$src")
                crop() {
                  local l=$((w * $4 / 1000)) r=$((w * $5 / 1000)) t=$((h * $6 / 1000))
                  local cw=$((r - l))
                  local ch=$((cw * $3 / $2))
                  if [ $((t + ch)) -gt "$h" ]; then
                    echo "$1: crop runs past the bottom of the image" >&2
                    exit 1
                  fi
                  magick "$src" -crop "''${cw}x''${ch}+''${l}+''${t}" +repage \
                    -resize "$2x$3!" -quality 92 "$1"
                }
                crop $out/ultrawide.jpg 3440 1440 ${region painting.ultrawide}
              ''
              + (
                if painting ? panel then
                  ''
                    crop $out/panel.jpg 2400 1500 ${region painting.panel}
                  ''
                else
                  ''
                    magick "$src" -resize '2400x>' -quality 92 $out/panel.jpg
                  ''
              )
          )
        );

      # <study>/<painting>/{ultrawide.jpg,panel.jpg,caption,placard,palette}, plus
      # <study>/order listing the paintings, first one the default.
      studiesDir = pkgs.linkFarm "garden-studies" (
        lib.mapAttrs (
          study: s:
          pkgs.linkFarm "study-${study}" (
            lib.listToAttrs (map (p: lib.nameValuePair p.name (render study p)) s.paintings)
            // {
              order = pkgs.writeText "order" (lib.concatMapStrings (p: "${p.name}\n") s.paintings);
            }
          )
        ) studies
      );

      themesDir = "${config.xdg.configHome}/garden/themes";
      # One file per study, holding the name of the painting chosen
      # for it (written by garden-study).
      stateDir = "${config.xdg.stateHome}/garden-study";

      # Shared by both scripts: which study and painting are on the wall.
      resolve = ''
        studies=${studiesDir}
        state=${stateDir}
        manifest=${themesDir}/.manifest.json

        active_palette() {
          jq -r '.palette // empty' "$manifest" 2>/dev/null || true
        }

        study_of_palette() {
          case "$1" in
            ${lib.concatStrings (
              lib.mapAttrsToList (palette: study: ''
                ${palette}) echo ${study} ;;
              '') paletteStudy
            )}
            *) ;;
          esac
        }

        active_study() {
          local study
          study=$(study_of_palette "$(active_palette)")
          echo "''${study:-${defaultStudy}}"
        }

        # chosen_painting <study>: the painting last picked for it.
        chosen_painting() {
          local painting
          painting=$(cat "$state/$1" 2>/dev/null || true)
          if [ -z "$painting" ] || [ ! -d "$studies/$1/$painting" ]; then
            painting=$(head -n 1 "$studies/$1/order")
          fi
          echo "$painting"
        }

        # current_painting <study>: the painting on the wall for it.
        # Normally the chosen one. But when the active palette belongs
        # to this study and is not the chosen painting's, the palette
        # was picked elsewhere (garden Settings), so the first painting
        # with that palette is shown. Unless the choice is newer than
        # the palette: then garden-study has just picked the painting
        # and the palette switch is still on its way.
        current_painting() {
          local chosen palette p
          chosen=$(chosen_painting "$1")
          palette=$(active_palette)
          if [ "$(study_of_palette "$palette")" = "$1" ] \
            && [ "$(cat "$studies/$1/$chosen/palette")" != "$palette" ] \
            && ! [ "$state/$1" -nt "$manifest" ]; then
            while read -r p; do
              if [ "$(cat "$studies/$1/$p/palette")" = "$palette" ]; then
                echo "$p"
                return
              fi
            done < "$studies/$1/order"
          fi
          echo "$chosen"
        }

        # placard <study> <painting>: the painting's label, as a
        # notification that leaves no trace in the history.
        placard() {
          local lines
          mapfile -t lines < "$studies/$1/$2/placard"
          notify-send --app-name "Study" --expire-time 8000 --transient \
            "''${lines[0]}" "''${lines[1]}"$'\n'"''${lines[2]}" || true
        }
      '';

      # Shows the active study's painting and follows changes, with a
      # placard for each new painting (not at startup).
      # garden-themes renames a new .manifest.json into the themes
      # directory on every apply, and garden-study writes the state
      # directory; inotifywait reports either. On a change the new
      # swaybg is started before the old one is stopped, so the screen
      # never falls back to the bare backdrop.
      garden-wallpaper = pkgs.writeShellApplication {
        name = "garden-wallpaper";
        runtimeInputs = [
          pkgs.swaybg
          pkgs.jq
          pkgs.inotify-tools
          pkgs.coreutils
          pkgs.libnotify
        ];
        text = ''
          ${resolve}
          themes=${themesDir}
          current=""
          pid=""
          mkdir -p "$state"

          show() {
            local study painting dir old
            study=$(active_study)
            painting=$(current_painting "$study")
            dir="$studies/$study/$painting"
            if [ "$dir" = "$current" ] && kill -0 "$pid" 2>/dev/null; then
              return
            fi
            old=$pid
            swaybg \
              --output '*' --mode fill --image "$dir/panel.jpg" \
              --output DP-2 --mode fill --image "$dir/ultrawide.jpg" &
            pid=$!
            current=$dir
            if [ -n "$old" ]; then
              placard "$study" "$painting"
              sleep 0.5
              kill "$old" 2>/dev/null || true
            fi
          }

          while true; do
            watch=("$state")
            watching_themes=0
            if [ -d "$themes" ]; then
              watch+=("$themes")
              watching_themes=1
            fi
            # One long-lived monitor, read line by line: waiting afresh
            # for each event would miss a palette change that lands
            # while the previous event is being handled.
            exec {events}< <(exec inotifywait -m -q -e moved_to -e close_write "''${watch[@]}")
            monitor=$!
            show
            while true; do
              rc=0
              read -r -t 60 -u "$events" _ || rc=$?
              if [ "$rc" -gt 128 ]; then
                # Quiet for a minute: restart a swaybg that died, and
                # start watching a themes directory created since.
                show
                if [ "$watching_themes" = 0 ] && [ -d "$themes" ]; then
                  break
                fi
              elif [ "$rc" -ne 0 ]; then
                break
              else
                # An apply writes many files: take the burst as one.
                while read -r -t 0.1 -u "$events" _; do :; done
                show
              fi
            done
            kill "$monitor" 2>/dev/null || true
            exec {events}<&-
            sleep 1
          done
        '';
      };

      # garden-study: switch study or painting from a terminal or keybind.
      #   garden-study                     list studies and their paintings
      #   garden-study next                the next study, wrapping around
      #   garden-study painting            the next painting in this study
      #   garden-study placard             show the current painting's label
      #   garden-study <study> [painting]  that study (and painting)
      # Palettes switch through the garden shell when it is running, so
      # its switcher and bar follow; otherwise straight to garden-themes.
      garden-study = pkgs.writeShellApplication {
        name = "garden-study";
        runtimeInputs = [
          pkgs.jq
          pkgs.coreutils
          pkgs.libnotify
        ];
        text = ''
          ${resolve}
          names=(${lib.concatStringsSep " " (lib.attrNames studies)})
          active=$(active_study)

          # next_after <current> <item>...
          next_after() {
            local cur=$1 first=$2 take=0 item
            shift
            for item in "$@"; do
              if [ "$take" = 1 ]; then
                echo "$item"
                return
              fi
              if [ "$item" = "$cur" ]; then take=1; fi
            done
            echo "$first"
          }

          # choose <study> <painting>: record the choice, then apply the
          # painting's palette if it is not the active one. The choice
          # is written first (and always rewritten) so that it is newer
          # than the palette: see current_painting.
          choose() {
            local palette
            if [ ! -d "$studies/$1/$2" ]; then
              echo "garden-study: no painting '$2' in study '$1'" >&2
              exit 1
            fi
            mkdir -p "$state"
            echo "$2" > "$state/$1.tmp"
            mv "$state/$1.tmp" "$state/$1"
            palette=$(cat "$studies/$1/$2/palette")
            if [ "$palette" != "$(active_palette)" ]; then
              if ! qs -c garden ipc call garden switchPalette "$palette" 2>/dev/null; then
                garden-themes apply --name "$palette"
              fi
            fi
          }

          case "''${1:-}" in
            "")
              for s in "''${names[@]}"; do
                if [ "$s" = "$active" ]; then
                  echo "* $s"
                  shown=$(current_painting "$s")
                else
                  echo "  $s"
                  shown=$(chosen_painting "$s")
                fi
                while read -r p; do
                  if [ "$p" = "$shown" ]; then mark="*"; else mark=" "; fi
                  palette=$(cat "$studies/$s/$p/palette")
                  if [ "$palette" = "$s" ]; then palette=""; else palette=" [$palette]"; fi
                  printf '    %s %-18s %s%s\n' "$mark" "$p" "$(cat "$studies/$s/$p/caption")" "$palette"
                done < "$studies/$s/order"
              done
              ;;
            next)
              s=$(next_after "$active" "''${names[@]}")
              choose "$s" "$(chosen_painting "$s")"
              ;;
            painting)
              mapfile -t paintings < "$studies/$active/order"
              choose "$active" \
                "$(next_after "$(current_painting "$active")" "''${paintings[@]}")"
              ;;
            placard)
              placard "$active" "$(current_painting "$active")"
              ;;
            *)
              if [ ! -d "$studies/$1" ]; then
                echo "garden-study: no study '$1' (try: ''${names[*]})" >&2
                exit 1
              fi
              choose "$1" "''${2:-$(chosen_painting "$1")}"
              ;;
          esac
        '';
      };
    in
    {
      home.packages = [ garden-study ];

      # G for gallery: the next study, with Shift the next painting in
      # the current one, and with Ctrl the placard of what is showing.
      programs.niri.settings.binds = {
        "Mod+G".action.spawn = [
          (lib.getExe garden-study)
          "next"
        ];
        "Mod+Shift+G".action.spawn = [
          (lib.getExe garden-study)
          "painting"
        ];
        "Mod+Ctrl+G".action.spawn = [
          (lib.getExe garden-study)
          "placard"
        ];
      };

      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Desktop wallpaper (swaybg): the active garden study";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          # Restart when the script or any painting changes on a switch.
          X-Restart-Triggers = [ "${garden-wallpaper}" ];
        };
        Service = {
          ExecStart = lib.getExe garden-wallpaper;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      # Put the wallpaper in niri's backdrop (swaybg's layer namespace is
      # "wallpaper") so it also shows behind the overview, and make the
      # workspace background transparent: each workspace otherwise
      # paints its own solid grey over the backdrop, hiding the painting
      # everywhere except the overview.
      programs.niri.settings.layout.background-color = "transparent";
      programs.niri.settings.layer-rules = [
        {
          matches = [ { namespace = "^wallpaper$"; } ];
          place-within-backdrop = true;
        }
      ];
    };
}
