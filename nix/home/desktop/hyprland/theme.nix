{ lib, pkgs, config, ... }:

let
  cfg = config.desktop.hyprland;

  wallpaperApply = pkgs.writeText "wallpaper-apply.nu" ''
    #!/usr/bin/env nu
    use std log

    def pick_file_from_dir [dir: string] {
      if (not ($dir | path exists)) { return null }
      let files = (ls $dir | where type == "file" | where name =~ '\.(png|jpg|jpeg|webp)$' | get name)
      if ($files | is-empty) { null } else { $files | shuffle | first }
    }

    let ws_map   = ${builtins.toJSON cfg.theme.perWorkspace}
    let rot_dir  = "${cfg.theme.rotate.directory}"
    let trans_dur = ${toString cfg.theme.transition.duration}
    let trans_type = "${cfg.theme.transition.type}"

    # Current workspace
    let cur_ws = ( ^hyprctl activeworkspace -j | from json | get id | into string )
    let ws_path = ($ws_map | get -i $cur_ws | default "")

    # choose: workspace-specific -> random from rotate dir
    let chosen  = (if $ws_path != "" { $ws_path } else { (pick_file_from_dir $rot_dir) })

    if ($chosen == null) or ($chosen == "") or (not ($chosen | path exists)) {
      log warn "No wallpaper found; aborting theme update"
      exit 0
    }

    # 1) set wallpaper with swww
    ^${pkgs.swww}/bin/swww img $chosen --transition-type $trans_type --transition-duration $trans_dur

    # 2) generate palette with pywal (no xrdb)
    ^${pkgs.python3Packages.pywal}/bin/wal -n -i $chosen

    # 3) read wal colors
    let wal = (open "~/.cache/wal/colors.json" | from json)
    let base   = ($wal.special.background)
    let text   = ($wal.special.foreground)
    let mauve  = ($wal.colors.color5)
    let blue   = ($wal.colors.color4)
    let green  = ($wal.colors.color2)
    let red    = ($wal.colors.color1)
    let yellow = ($wal.colors.color3)
    let mantle = ($wal.colors.color0)
    let crust  = ($wal.colors.color8)

    # 4) write Waybar color vars (used by @import "colors.css")
    let css = $"/* generated from ($chosen) */\n:root {\n  --base:   ($base);\n  --mantle: ($mantle);\n  --crust:  ($crust);\n  --text:   ($text);\n  --mauve:  ($mauve);\n  --blue:   ($blue);\n  --green:  ($green);\n  --red:    ($red);\n  --yellow: ($yellow);\n}\n"
    $css | save --force ~/.config/waybar/colors.css

    # 5) live-update Hyprland border colors (safe quoting for Nix+Nu)
    let mauve_hex = ($mauve | str replace "#" "")
    let base_hex  = ($base  | str replace "#" "")
    ^hyprctl keyword "col.active_border"   $"rgba(($mauve_hex)ff)"
    ^hyprctl keyword "col.inactive_border" $"rgba(($base_hex)ff)"


    # 6) refresh Waybar CSS
    ^pkill -SIGUSR2 waybar | ignore
  '';
in
lib.mkIf (cfg.enable && cfg.theme.enable) {
  home.packages = with pkgs; [
    swww
    nushell
    socat
    jq
    imagemagick
    python3Packages.pywal
  ];

  # seed colors file for Waybar on first boot (then overwritten)
  xdg.configFile."waybar/colors.css".text = ''
    :root {
      --base:   #303446; --mantle: #292c3c; --crust: #232634; --text: #c6d0f5;
      --mauve:  #ca9ee6; --blue:   #8caaee; --green: #a6d189; --red:  #e78284; --yellow: #e5c890;
    }
  '';

  # write the apply script
  home.file.".config/hypr/wallpaper-apply.nu" = {
    source = wallpaperApply;
    executable = true;
  };


  # swww daemon
  systemd.user.services."swww-init" = {
    Unit = { Description = "Initialize swww daemon"; PartOf = [ "hyprland-session.target" ]; After = [ "graphical-session.target" ]; };
    Service = { ExecStart = "${pkgs.swww}/bin/swww init"; Restart = "on-failure"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # listen to workspace changes and re-apply theme
  systemd.user.services."wallpaper-workspace" = {
    Unit = { Description = "Switch wallpaper on workspace change (swww + wal)"; PartOf = [ "hyprland-session.target" ]; After = [ "swww-init.service" ]; };
    Service = {
      Environment = [ "PATH=${lib.makeBinPath [ pkgs.socat pkgs.coreutils pkgs.hyprland pkgs.nushell pkgs.swww pkgs.python3Packages.pywal ]}" ];
      ExecStart = "${pkgs.nushell}/bin/nu -c ''"
        + "let rt = ($env.XDG_RUNTIME_DIR); "
        + "let sig = ($env.HYPRLAND_INSTANCE_SIGNATURE); "
        + "let sock = $\"($rt)/hypr/($sig)/.socket2.sock\"; "
        + "^${pkgs.socat}/bin/socat - UNIX-CONNECT:$sock "
        + "| lines | each {|l| if ($l | str starts-with 'workspace>>') { ^${pkgs.nushell}/bin/nu ~/.config/hypr/wallpaper-apply.nu } }";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # periodic rotation (optional)
  systemd.user.services."wallpaper-rotate" = lib.mkIf cfg.theme.rotate.enable {
    Unit = { Description = "Periodic wallpaper rotation (swww + wal)"; };
    Service = { ExecStart = "${pkgs.nushell}/bin/nu ~/.config/hypr/wallpaper-apply.nu"; };
  };
  systemd.user.timers."wallpaper-rotate" = lib.mkIf cfg.theme.rotate.enable {
    Unit = { Description = "Every ${toString cfg.theme.rotate.minutes} minutes: rotate wallpaper"; };
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "${toString cfg.theme.rotate.minutes}min";
      Unit = "wallpaper-rotate.service";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}

