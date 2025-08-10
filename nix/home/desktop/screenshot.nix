# nix/home/desktop/screenshot.nix
{ lib, pkgs, config, ... }:
let
  cfg = config.desktop.hyprland;
  shotsDir = "${config.home.homeDirectory}/media/screenshots";

  hyprshot_region_annotate = pkgs.writeShellScriptBin "hyprshot-region-annotate" ''
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${shotsDir}"
    file="${shotsDir}/screenshot-$(date +%F_%H-%M-%S).png"
    "${pkgs.grim}/bin/grim" -g "$(${pkgs.slurp}/bin/slurp)" - \
      | "${pkgs.satty}/bin/satty" -f - \
          --output-filename "''${file}" \
          --copy-command '${pkgs.wl-clipboard}/bin/wl-copy --type image/png' \
          --early-exit
  '';

  hyprshot_full_annotate = pkgs.writeShellScriptBin "hyprshot-full-annotate" ''
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${shotsDir}"
    file="${shotsDir}/screenshot-$(date +%F_%H-%M-%S).png"
    "${pkgs.grim}/bin/grim" - \
      | "${pkgs.satty}/bin/satty" -f - \
          --output-filename "''${file}" \
          --copy-command '${pkgs.wl-clipboard}/bin/wl-copy --type image/png' \
          --early-exit
  '';

  hyprshot_region_clip = pkgs.writeShellScriptBin "hyprshot-region-clip" ''
    #!/usr/bin/env bash
    set -euo pipefail
    "${pkgs.grim}/bin/grim" -g "$(${pkgs.slurp}/bin/slurp)" - \
      | "${pkgs.wl-clipboard}/bin/wl-copy" --type image/png
    ${pkgs.libnotify}/bin/notify-send "Screenshot" "Region copied to clipboard"
  '';

  hyprshot_full_file = pkgs.writeShellScriptBin "hyprshot-full-file" ''
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${shotsDir}"
    file="${shotsDir}/screenshot-$(date +%F_%H-%M-%S).png"
    "${pkgs.grim}/bin/grim" "''${file}"
    ${pkgs.libnotify}/bin/notify-send "Screenshot" "Saved to ''${file}"
  '';
in
lib.mkIf cfg.enable {
  home.packages = with pkgs; [
    grim slurp satty wl-clipboard libnotify
    hyprshot_region_annotate hyprshot_full_annotate
    hyprshot_region_clip hyprshot_full_file
  ];

  home.file."Pictures/Screenshots/.keep".text = "";

  xdg.configFile."satty/config.toml".text = ''
    [general]
    save-after-copy = true
    early-exit = true
    corner-roundness = 12
    initial-tool = "brush"
    primary-highlighter = "block"
    copy-command = "/run/current-system/sw/bin/wl-copy --type image/png"

    # Font to use for text annotations
    [font]
    family = "Roboto"

    # Custom colours for the colour palette
    [color-palette]
    # These will be shown in the toolbar for quick selection
    palette = [
        "#00ffff",
        "#a52a2a",
        "#dc143c",
        "#ff1493",
        "#ffd700",
        "#008000",
    ]
  '';

  wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
    "${cfg.modKey}, S, exec, hyprshot-region-annotate"
    "${cfg.modKey} SHIFT, S, exec, hyprshot-full-annotate"
    "${cfg.modKey} ALT, S, exec, hyprshot-region-clip"
    "${cfg.modKey} CTRL, S, exec, hyprshot-full-file"
  ];
}

