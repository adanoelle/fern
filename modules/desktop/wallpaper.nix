# modules/desktop/wallpaper.nix — painted wallpapers for the niri session
#
# A "study" pairs a garden palette built from a painter's working
# colours with one of their paintings. Whichever palette is active
# decides the painting on the wall, so switching palette (garden
# Settings, or `garden-study`) changes both together. A palette without
# a study shows the default one.
#
#   shitanuri  John Singer Sargent, "Nonchaloir (Repose)" (1911).
#              National Gallery of Art, Washington, object 35080.
#   nocturne   James McNeill Whistler, "Nocturne: Blue and Gold —
#              Southampton Water" (1872). Art Institute of Chicago,
#              artwork 56905.
#   tenebroso  Caravaggio, "The Denial of Saint Peter" (1610).
#              The Metropolitan Museum of Art, object 437986.
#
# All three are open access (public domain / CC0), fetched from the
# museums and pinned by hash. Each study has two renditions:
#   - ultrawide.jpg: a 3440x1440 band of the canvas, chosen by hand so
#     heads stay clear of the bar. A plain centre crop usually doesn't.
#   - panel.jpg: the whole painting at 2400 px wide, filled (lightly
#     cropped) onto the 16:10 laptop panel and any other output.
# The Sargent comes ready-cropped from the NGA's IIIF server. The Art
# Institute only serves a few fixed sizes and the Met has no IIIF, so
# those two are cropped here from one pinned source image.
#
# swaybg picks per output. It can only match the ultrawide by connector
# name ("DP-2"): its make/model matching parses a "(name)" suffix niri's
# wl_output description doesn't have. On another dock/port the monitor
# just gets the full painting centre-cropped.
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

      # A study from one source image. `top` is where the ultrawide band
      # starts, as a percentage of the canvas height.
      cropped =
        {
          name,
          src,
          top,
        }:
        pkgs.runCommand "study-${name}" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
          mkdir -p $out
          w=$(magick identify -format %w ${src})
          h=$(magick identify -format %h ${src})
          magick ${src} -crop "''${w}x$((w * 1440 / 3440))+0+$((h * ${toString top} / 100))" \
            +repage -resize '3440x1440!' -quality 92 $out/ultrawide.jpg
          magick ${src} -resize '2400x>' -quality 92 $out/panel.jpg
        '';

      nga = "https://api.nga.gov/iiif/718e014f-fb5f-4702-a95a-db496abefeb7";

      studies = {
        # Ultrawide: a 2.4:1 band from ~18% to ~68% of the canvas height
        # (master is 18332x15338). It keeps her head clear of the bar
        # plus the clasped hands, shawl and gilt table.
        shitanuri = pkgs.linkFarm "study-shitanuri" {
          "ultrawide.jpg" = pkgs.fetchurl {
            name = "sargent-nonchaloir-ultrawide.jpg";
            url = "${nga}/0,2760,18332,7673/3440,1440/0/default.jpg";
            hash = "sha256-KkYKXQip0BPY4Lej3MS6u1jNZbnihJRNCbd6d6B1iyQ=";
          };
          "panel.jpg" = pkgs.fetchurl {
            name = "sargent-nonchaloir-panel.jpg";
            url = "${nga}/full/2400,/0/default.jpg";
            hash = "sha256-Ib87L3l9H1H/dttAcSuk7MCFlOpc7+d5XYnWu2B0HeU=";
          };
        };

        # 3000 px is the largest size the Art Institute serves. The band
        # keeps the moon in the upper third and the boats below it.
        nocturne = cropped {
          name = "nocturne";
          src = pkgs.fetchurl {
            name = "whistler-nocturne-southampton-water.jpg";
            url = "https://www.artic.edu/iiif/2/50034c7f-ce51-00f1-430e-a6f7efc233fc/full/3000,/0/default.jpg";
            hash = "sha256-aoIr5lgw917p32b1kMv3MY0vFCJ7uZVsBZ3hGKx0+M4=";
          };
          top = 8;
        };

        # The band holds the three heads and the pointing hands.
        tenebroso = cropped {
          name = "tenebroso";
          src = pkgs.fetchurl {
            name = "caravaggio-denial-of-saint-peter.jpg";
            url = "https://images.metmuseum.org/CRDImages/ep/original/DP-12413-001.jpg";
            hash = "sha256-VmYWhyymiqkwGpH06OvXYxQzzEI1j5Y+MjDL5t2RPeo=";
          };
          top = 10;
        };
      };

      studiesDir = pkgs.linkFarm "garden-studies" studies;
      themesDir = "${config.xdg.configHome}/garden/themes";

      # Shows the active palette's study and follows palette switches.
      # garden-themes renames a new .manifest.json into the themes
      # directory on every apply, which is what inotifywait wakes on.
      # On a switch the new swaybg is started before the old one is
      # stopped, so the screen never falls back to the bare backdrop.
      garden-wallpaper = pkgs.writeShellApplication {
        name = "garden-wallpaper";
        runtimeInputs = [
          pkgs.swaybg
          pkgs.jq
          pkgs.inotify-tools
          pkgs.coreutils
        ];
        text = ''
          themes=${themesDir}
          studies=${studiesDir}
          current=""
          pid=""

          show() {
            local palette dir old
            palette=$(jq -r '.palette // empty' "$themes/.manifest.json" 2>/dev/null || true)
            dir="$studies/$palette"
            if [ -z "$palette" ] || [ ! -d "$dir" ]; then
              dir="$studies/${defaultStudy}"
            fi
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
            # The timeout also restarts a swaybg that died.
            if [ -d "$themes" ]; then
              inotifywait -qq -t 60 -e moved_to -e close_write "$themes" || true
            else
              sleep 5
            fi
          done
        '';
      };

      # garden-study: switch study from a terminal or a keybind.
      #   garden-study            list studies, marking the active one
      #   garden-study next       the next study, wrapping around
      #   garden-study <name>     that study
      # Goes through the garden shell when it is running, so its
      # switcher and bar follow; otherwise straight to garden-themes.
      garden-study = pkgs.writeShellApplication {
        name = "garden-study";
        runtimeInputs = [
          pkgs.jq
          pkgs.coreutils
        ];
        text = ''
          studies=(${lib.concatStringsSep " " (lib.attrNames studies)})
          active=$(jq -r '.palette // empty' ${themesDir}/.manifest.json 2>/dev/null || true)

          case "''${1:-}" in
            "")
              for s in "''${studies[@]}"; do
                if [ "$s" = "$active" ]; then echo "* $s"; else echo "  $s"; fi
              done
              exit 0
              ;;
            next)
              target=''${studies[0]}
              for i in "''${!studies[@]}"; do
                if [ "''${studies[$i]}" = "$active" ]; then
                  target=''${studies[$(((i + 1) % ''${#studies[@]}))]}
                fi
              done
              ;;
            *)
              target=$1
              ;;
          esac

          if ! qs -c garden ipc call garden switchPalette "$target" 2>/dev/null; then
            garden-themes apply --name "$target"
          fi
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
