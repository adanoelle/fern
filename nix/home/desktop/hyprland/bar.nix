{ lib, pkgs, config, ... }:
let
  cfg = config.desktop.hyprland;
in
lib.mkIf (cfg.enable && cfg.bar.enable) {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 45;
      spacing = 6;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "network" "pulseaudio" "battery" "cpu" "memory" ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name}";
        format-icons = { active = ""; default = ""; };
      };

      "hyprland/window" = {
        format = "{title}";
        max-length = 56;
        separate-outputs = true;
      };

      clock = {
        format = "󱑆  {:%a %b %d  %I:%M %p}";
        tooltip-format = "<big>{:%A, %B %d, %Y}</big>\n<tt>{calendar}</tt>";
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "󰈀  {ifname}";
        format-disconnected = "  offline";
        tooltip-format = "{ifname} via {gwaddr}\n{ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-muted = "";
        format-icons = { default = [ "" "" "" ]; };
        tooltip-format = "{desc} at {volume}%";
      };

      battery = {
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-icons = [ "" "" "" "" "" ];
        states = { critical = 15; warning = 30; };
      };

      cpu = { format = " {usage}%"; };
      memory = { format = " {used:0.1f}G"; };
    };

    style = ''
      /* Catppuccin Frappé */
      @define-color base   #303446;
      @define-color mantle #292c3c;
      @define-color crust  #232634;
      @define-color text   #c6d0f5;
      @define-color mauve  #ca9ee6;
      @define-color blue   #8caaee;
      @define-color green  #a6d189;
      @define-color red    #e78284;
      @define-color yellow #e5c890;

      * {
        font-family: "FiraCode Nerd Font","JetBrainsMono Nerd Font",monospace;
        font-size: 10pt;
        color: @text;
      }

      /* Fully transparent bar; Hyprland adds blur via layerrule */
      window#waybar {
        background: transparent;
        border: none;
        box-shadow: none;
        padding: 6px 8px;
      }

      /* Workspaces */
      #workspaces { background: transparent; }
      #workspaces button {
        padding: 0 6px;
        margin: 0 4px 0 0;
        background: rgba(48,52,70,0.45); /* pill */
        border: none;
        border-radius: 8px;
      }
      #workspaces button.active {
        background: rgba(202,158,230,0.85); /* mauve pill */
        color: @mantle;
      }

      /* Pill modules */
      #clock, #network, #pulseaudio, #battery, #cpu, #memory {
        padding: 0 10px;
        margin: 0 4px;
        background: rgba(48,52,70,0.45);
        border-radius: 8px;
        border: none;
        box-shadow: none;
      }

      #pulseaudio.muted { color: @red; }
      #battery.warning  { color: @yellow; }
      #battery.critical { color: @red; }
    '';
  };

  # Ensure Waybar starts with the Hyprland session
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar";
      After = [ "graphical-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = { ExecStart = "${pkgs.waybar}/bin/waybar"; Restart = "on-failure"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}

