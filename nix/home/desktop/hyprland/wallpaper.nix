# hyprland/wallpaper.nix - Advanced version with workspace support
{ lib, pkgs, config, ... }:

let 
  cfg = config.desktop.hyprland;
  
  # Helper to get wallpaper command with transitions
  swwwCmd = path: monitor: ''
    ${pkgs.swww}/bin/swww img "${path}" \
      ${lib.optionalString (monitor != "") "--outputs \"${monitor}\""} \
      --transition-type ${cfg.wallpaper.transition.type} \
      --transition-duration ${toString cfg.wallpaper.transition.duration} \
      --transition-fps ${toString cfg.wallpaper.transition.fps}
  '';
in
{
  config = lib.mkIf (cfg.enable && cfg.wallpaper.enable) {
    home.packages = with pkgs; [ swww ];

    # Add swww daemon initialization
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.swww}/bin/swww-daemon"
    ];

    # Main wallpaper service
    systemd.user.services.swww-wallpaper = {
      Unit = {
        Description = "Set wallpapers with swww";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "set-wallpapers" ''
          # Start swww daemon if it's not running
          if ! ${pkgs.swww}/bin/swww query &>/dev/null; then
            echo "Starting swww daemon..."
            ${pkgs.swww}/bin/swww-daemon &
            daemon_pid=$!
          fi
          
          # Wait for swww daemon with timeout
          timeout=30
          while ! ${pkgs.swww}/bin/swww query &>/dev/null && [ $timeout -gt 0 ]; do
            sleep 1
            ((timeout--))
          done
          
          if [ $timeout -eq 0 ]; then
            echo "Timeout waiting for swww daemon"
            exit 1
          fi

          echo "swww daemon is ready"

          # Set wallpapers based on configuration
          ${if cfg.wallpaper.monitors != {} then
            # Use per-monitor configuration
            lib.concatStringsSep "\n" (lib.mapAttrsToList (monitor: path: 
              "echo \"Setting wallpaper for ${monitor}: ${path}\"\n" + (swwwCmd path monitor)
            ) cfg.wallpaper.monitors)
          else
            # Use legacy single wallpaper configuration
            "echo \"Setting wallpaper for ${cfg.wallpaper.monitor}: ${cfg.wallpaper.path}\"\n" + (swwwCmd cfg.wallpaper.path cfg.wallpaper.monitor)
          }

          echo "Wallpapers set successfully"
        '';
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Workspace wallpaper listener (only if workspace wallpapers are configured)
    systemd.user.services.swww-workspace-listener = lib.mkIf (cfg.wallpaper.workspaces != {}) {
      Unit = {
        Description = "Hyprland workspace wallpaper switcher";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;
        ExecStart = pkgs.writeShellScript "workspace-wallpaper-listener" ''
          set_workspace_wallpaper() {
            local workspace_id="$1"
            local wallpaper_path=""
            
            case "$workspace_id" in
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (ws: path: ''
              ${ws})
                wallpaper_path="${path}"
                ;;'') cfg.wallpaper.workspaces)}
              *)
                wallpaper_path="${if cfg.wallpaper.monitors != {} then 
                  (builtins.head (builtins.attrValues cfg.wallpaper.monitors)) 
                else 
                  cfg.wallpaper.path}"
                ;;
            esac
            
            if [[ -f "$wallpaper_path" ]]; then
              ${swwwCmd "$wallpaper_path" ""}
            fi
          }
          
          # Set initial wallpaper
          current_workspace=$(${pkgs.hyprland}/bin/hyprctl activewindow -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.workspace.id // "1"' 2>/dev/null || echo "1")
          set_workspace_wallpaper "$current_workspace"
          
          # Listen for workspace changes
          ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
            if [[ "$line" == workspace\>\>* ]]; then
              workspace_id="''${line#*>>}"
              set_workspace_wallpaper "$workspace_id"
            fi
          done
        '';
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Wallpaper keybinds
    wayland.windowManager.hyprland.settings.bind = [
      # Cycle workspace wallpaper (if workspace wallpapers are configured)
      "${cfg.modKey}, W, exec, ${pkgs.writeShellScript "cycle-wallpaper" ''
        current_workspace=$(${pkgs.hyprland}/bin/hyprctl activewindow -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.workspace.id // "1"' 2>/dev/null || echo "1")
        wallpaper_path="${if cfg.wallpaper.workspaces != {} then ''
          case "$current_workspace" in
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (ws: path: ''
            ${ws}) echo "${path}" ;;'') cfg.wallpaper.workspaces)}
            *) echo "${if cfg.wallpaper.monitors != {} then 
              (builtins.head (builtins.attrValues cfg.wallpaper.monitors)) 
            else 
              cfg.wallpaper.path}" ;;
          esac
        '' else 
          cfg.wallpaper.path
        }"
        ${swwwCmd "$wallpaper_path" ""}
      ''}"
      
      # Random wallpaper from directory
      "${cfg.modKey} SHIFT, W, exec, ${pkgs.writeShellScript "random-wallpaper" ''
        wallpaper_dir="$(dirname "${cfg.wallpaper.path}")"
        if [[ -d "$wallpaper_dir" ]]; then
          random_wallpaper=$(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
          if [[ -n "$random_wallpaper" ]]; then
            ${swwwCmd "$random_wallpaper" ""}
          fi
        fi
      ''}"
    ];
  };
}
