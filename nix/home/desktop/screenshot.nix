# nix/home/desktop/screenshot.nix
{ lib, pkgs, config, ... }:
let
  cfg = config.desktop.hyprland;

  screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";

  screenshotSh = pkgs.writeShellScriptBin "hyprshot" ''
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p "${screenshotsDir}"
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

    case "''${1:-}" in
      full-to-file)
        file="${screenshotsDir}/screenshot-''${timestamp}.png"
        ${pkgs.grim}/bin/grim "''${file}"
        ${pkgs.libnotify}/bin/notify-send "Screenshot" "Saved full screen to ''${file}"
        ;;
      region-to-clipboard)
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
          | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
        ${pkgs.libnotify}/bin/notify-send "Screenshot" "Region copied to clipboard"
        ;;
      region-annotate)
        file="${screenshotsDir}/annotated-''${timestamp}.png"
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
          | ${pkgs.satty}/bin/satty -f - --filename "''${file}" --output-filename "''${file}" \
              --copy-command '${pkgs.wl-clipboard}/bin/wl-copy --type image/png'
        ${pkgs.libnotify}/bin/notify-send "Screenshot" "Annotated screenshot saved to ''${file}"
        ;;
      *)
        echo "Usage: hyprshot {full-to-file|region-to-clipboard|region-annotate}" >&2
        exit 1
        ;;
    esac
  '';
in
lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    satty
    libnotify      # notify-send
    screenshotSh   # installs the 'hyprshot' helper
  ];

  # Bindings (Super+S family)
  wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
    # Super+S = save full screen to file
    "${cfg.modKey}, S, exec, hyprshot full-to-file"
    # Super+Shift+S = region to clipboard
    "${cfg.modKey} SHIFT, S, exec, hyprshot region-to-clipboard"
    # Super+Alt+S = annotate region, save + copy
    "${cfg.modKey} ALT, S, exec, hyprshot region-annotate"
  ];
}

