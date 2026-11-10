# modules/desktop/wallpaper.nix — painted wallpapers for the niri session
#
# A "study" pairs a garden palette built from a painter's working
# colours with that painter's paintings. Whichever palette is active
# decides the study on the wall, so switching palette (garden Settings,
# or `garden-study`) changes both together; within a study,
# `garden-study painting` steps through its paintings. A palette
# without a study shows the default one.
#
# This file is only the mechanism. The studies themselves are data,
# one file per palette in ./_studies/<palette>.nix (picked up
# automatically): the painter and a list of paintings, each with its
# attribution, a pinned open-access source image and where to crop it.
# The palette's colours live in garden-shell's palettes.toml.
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
          caption = "${studies.${study}.painter}, ${painting.title} (${painting.year}). ${painting.collection}";
        in
        pkgs.runCommand "study-${study}-${painting.name}" { nativeBuildInputs = [ pkgs.imagemagick ]; } (
          ''
            mkdir -p $out
            printf '%s\n' ${lib.escapeShellArg caption} > $out/caption
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

      # <study>/<painting>/{ultrawide.jpg,panel.jpg,caption}, plus
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

      # Shared by both scripts: the active study and its chosen painting.
      resolve = ''
        studies=${studiesDir}
        state=${stateDir}

        active_study() {
          local palette
          palette=$(jq -r '.palette // empty' ${themesDir}/.manifest.json 2>/dev/null || true)
          if [ -n "$palette" ] && [ -d "$studies/$palette" ]; then
            echo "$palette"
          else
            echo ${defaultStudy}
          fi
        }

        # chosen_painting <study>
        chosen_painting() {
          local painting
          painting=$(cat "$state/$1" 2>/dev/null || true)
          if [ -z "$painting" ] || [ ! -d "$studies/$1/$painting" ]; then
            painting=$(head -n 1 "$studies/$1/order")
          fi
          echo "$painting"
        }
      '';

      # Shows the active study's chosen painting and follows changes.
      # garden-themes renames a new .manifest.json into the themes
      # directory on every apply, and garden-study writes the state
      # directory; inotifywait wakes on either. On a change the new
      # swaybg is started before the old one is stopped, so the screen
      # never falls back to the bare backdrop.
      garden-wallpaper = pkgs.writeShellApplication {
        name = "garden-wallpaper";
        runtimeInputs = [
          pkgs.swaybg
          pkgs.jq
          pkgs.inotify-tools
          pkgs.coreutils
        ];
        text = ''
          ${resolve}
          themes=${themesDir}
          current=""
          pid=""
          mkdir -p "$state"

          show() {
            local study dir old
            study=$(active_study)
            dir="$studies/$study/$(chosen_painting "$study")"
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
              sleep 0.5
              kill "$old" 2>/dev/null || true
            fi
          }

          while true; do
            show
            watch=("$state")
            if [ -d "$themes" ]; then
              watch+=("$themes")
            fi
            # The timeout also restarts a swaybg that died, and picks up
            # a themes directory created after startup.
            inotifywait -qq -t 60 -e moved_to -e close_write "''${watch[@]}" || true
          done
        '';
      };

      # garden-study: switch study or painting from a terminal or keybind.
      #   garden-study                     list studies and their paintings
      #   garden-study next                the next study, wrapping around
      #   garden-study painting            the next painting in this study
      #   garden-study <study> [painting]  that study (and painting)
      # Studies switch through the garden shell when it is running, so
      # its switcher and bar follow; otherwise straight to garden-themes.
      garden-study = pkgs.writeShellApplication {
        name = "garden-study";
        runtimeInputs = [
          pkgs.jq
          pkgs.coreutils
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

          set_painting() {
            if [ ! -d "$studies/$1/$2" ]; then
              echo "garden-study: no painting '$2' in study '$1'" >&2
              exit 1
            fi
            mkdir -p "$state"
            echo "$2" > "$state/$1.tmp"
            mv "$state/$1.tmp" "$state/$1"
          }

          switch_study() {
            if ! qs -c garden ipc call garden switchPalette "$1" 2>/dev/null; then
              garden-themes apply --name "$1"
            fi
          }

          case "''${1:-}" in
            "")
              for s in "''${names[@]}"; do
                if [ "$s" = "$active" ]; then echo "* $s"; else echo "  $s"; fi
                chosen=$(chosen_painting "$s")
                while read -r p; do
                  if [ "$p" = "$chosen" ]; then mark="*"; else mark=" "; fi
                  printf '    %s %-18s %s\n' "$mark" "$p" "$(cat "$studies/$s/$p/caption")"
                done < "$studies/$s/order"
              done
              ;;
            next)
              switch_study "$(next_after "$active" "''${names[@]}")"
              ;;
            painting)
              mapfile -t paintings < "$studies/$active/order"
              set_painting "$active" \
                "$(next_after "$(chosen_painting "$active")" "''${paintings[@]}")"
              ;;
            *)
              if [ ! -d "$studies/$1" ]; then
                echo "garden-study: no study '$1' (try: ''${names[*]})" >&2
                exit 1
              fi
              if [ -n "''${2:-}" ]; then
                set_painting "$1" "$2"
              fi
              if [ "$1" != "$active" ]; then
                switch_study "$1"
              fi
              ;;
          esac
        '';
      };
    in
    {
      home.packages = [ garden-study ];

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
