# modules/desktop/niri.nix — Niri scrollable-tiling compositor (garden stack)
#
# NOTE: The niri-flake NixOS module must be imported once at the host level
# (see host-fern.nix) to avoid duplicate option declarations. This aspect
# only enables it and provides the Home Manager settings.
{ den, inputs, ... }:
let
  palette = inputs.garden-shell.lib.palette.colors;
in
{
  den.aspects.niri = {
    nixos =
      { pkgs, ... }:
      {
        programs.niri.enable = true;

        # DDC/CI monitor brightness control (requires i2c-dev + i2c group)
        hardware.i2c.enable = true;

        # Battery/power state on D-Bus for the garden bar (Phase E)
        services.upower.enable = true;

        # XWayland support via xwayland-satellite + DDC/CI tool.
        # quickshell lives here (not in greetd): the garden shell and its
        # IPC binds below belong to the niri session.
        environment.systemPackages = with pkgs; [
          xwayland-satellite
          ddcutil
          quickshell
        ];

        # Portal support for Niri
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
          ];
        };
      };

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        # Store path so binds survive quickshell not being on PATH
        qs = "${pkgs.quickshell}/bin/qs";
      in
      {
        programs.niri.settings = {
          # Built-in Print action target (default would resurrect ~/Pictures/Screenshots)
          screenshot-path = "~/media/screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png";

          # ── Named workspaces (channels) ──────────────────────
          workspaces = {
            "1-studio" = {
              name = "studio";
            };
            "2-research" = {
              name = "research";
            };
            "3-writing" = {
              name = "writing";
            };
            "4-music" = {
              name = "music";
            };
            "5-system" = {
              name = "system";
            };
          };

          # ── Startup programs ─────────────────────────────────
          spawn-at-startup = [
            { command = [ "xwayland-satellite" ]; }
            # Garden shell (quickshell) — receives the Mod+Slash/Tab/Comma
            # IPC binds below; without it those binds silently do nothing.
            {
              command = [
                qs
                "-c"
                "garden"
              ];
            }
            { command = [ "kitty" ]; }
            {
              command = [
                "kitty"
                "-e"
                "btop"
              ];
            }
          ];

          # ── Layout ───────────────────────────────────────────
          layout = {
            gaps = 2;
            center-focused-column = "on-overflow";
            default-column-width.proportion = 0.5;

            border = {
              enable = true;
              width = 1;
              active.color = palette.border;
              inactive.color = palette.border-sub;
            };

            focus-ring.enable = false;

            preset-column-widths = [
              { proportion = 0.5; }
              { proportion = 0.75; }
              { proportion = 1.0; }
            ];
          };

          # ── Animations ───────────────────────────────────────
          animations = {
            workspace-switch.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 800;
              epsilon = 0.0001;
            };

            horizontal-view-movement.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 1000;
              epsilon = 0.0001;
            };

            window-open = {
              kind.easing = {
                duration-ms = 150;
                curve = "ease-out-expo";
              };
              custom-shader = ''
                vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                    vec3 coords_tex = niri_geo_to_tex * coords_geo;
                    vec4 color = texture2D(niri_tex, coords_tex.st);
                    color *= niri_clamped_progress;
                    return color;
                }
              '';
            };

            window-close.kind.easing = {
              duration-ms = 100;
              curve = "ease-out-cubic";
            };

            config-notification-open-close.kind.easing = {
              duration-ms = 150;
              curve = "ease-out-cubic";
            };
          };

          # ── Keybinds ─────────────────────────────────────────
          binds =
            let
              mod = "Mod";
            in
            {
              # Channel switching (Super+1-5)
              "${mod}+1".action.focus-workspace = "studio";
              "${mod}+2".action.focus-workspace = "research";
              "${mod}+3".action.focus-workspace = "writing";
              "${mod}+4".action.focus-workspace = "music";
              "${mod}+5".action.focus-workspace = "system";

              # Move window to channel (Super+Shift+1-5)
              "${mod}+Shift+1".action.move-window-to-workspace = "studio";
              "${mod}+Shift+2".action.move-window-to-workspace = "research";
              "${mod}+Shift+3".action.move-window-to-workspace = "writing";
              "${mod}+Shift+4".action.move-window-to-workspace = "music";
              "${mod}+Shift+5".action.move-window-to-workspace = "system";

              # Column navigation (Super+H/L)
              "${mod}+H".action.focus-column-left = [ ];
              "${mod}+L".action.focus-column-right = [ ];

              # Column scroll (Super + mouse wheel)
              "${mod}+WheelScrollDown" = {
                action.focus-column-right = [ ];
                cooldown-ms = 25;
              };
              "${mod}+WheelScrollUp" = {
                action.focus-column-left = [ ];
                cooldown-ms = 25;
              };

              # Window navigation (Super+J/K)
              "${mod}+J".action.focus-window-down = [ ];
              "${mod}+K".action.focus-window-up = [ ];

              # Move column (Super+Shift+H/L)
              "${mod}+Shift+H".action.move-column-left = [ ];
              "${mod}+Shift+L".action.move-column-right = [ ];

              # Move window (Super+Shift+J/K)
              "${mod}+Shift+J".action.move-window-down = [ ];
              "${mod}+Shift+K".action.move-window-up = [ ];

              # Spawn & close
              "${mod}+N".action.spawn = [ "kitty" ];
              "${mod}+B".action.spawn = [ "firefox" ];
              "${mod}+Shift+Q".action.close-window = [ ];

              # Fullscreen & overview
              "${mod}+F".action.maximize-column = [ ];
              "${mod}+A".action.toggle-overview = [ ];

              # Column width cycling
              "${mod}+R".action.switch-preset-column-width = [ ];
              "${mod}+Minus".action.set-column-width = "-10%";
              "${mod}+Equal".action.set-column-width = "+10%";

              # Floating
              "${mod}+V".action.toggle-window-floating = [ ];

              # Screenshot
              "Print".action.screenshot = [ ];
              "${mod}+Print".action.screenshot-window = [ ];

              # Volume (XF86 media keys)
              "XF86AudioRaiseVolume".action.spawn = [
                "wpctl"
                "set-volume"
                "-l"
                "1.0"
                "@DEFAULT_AUDIO_SINK@"
                "5%+"
              ];
              "XF86AudioLowerVolume".action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%-"
              ];
              "XF86AudioMute".action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];

              # Brightness — DDC/CI via ddcutil (external monitor, no sysfs
              # backlight). The IPC call first shows the garden OSD
              # optimistically (ddcutil takes ~200ms and the poll is 3s).
              "XF86MonBrightnessUp".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden stepBrightnessOsd 5; exec ddcutil setvcp 10 + 5"
              ];
              "XF86MonBrightnessDown".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden stepBrightnessOsd -5; exec ddcutil setvcp 10 - 5"
              ];

              # Garden shell overlays
              "${mod}+Slash".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden toggleLauncher"
              ];
              "${mod}+Tab".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden toggleSwitcher"
              ];
              "${mod}+Comma".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden toggleSettings"
              ];
              "${mod}+Shift+N".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden toggleNotifications"
              ];
              "${mod}+Shift+M".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden toggleNotificationCenter"
              ];
              "${mod}+Escape".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden togglePowerMenu"
              ];
              "${mod}+Alt+L".action.spawn = [
                "sh"
                "-c"
                "${qs} -c garden ipc call garden lock"
              ];

              # Session
              "${mod}+Shift+E".action.quit = [ ];
              "${mod}+Shift+Slash".action.show-hotkey-overlay = [ ];

              # Workspace navigation (prev/next)
              "${mod}+Shift+Tab".action.focus-workspace-up = [ ];

              # Consume/expel (tabbed columns)
              "${mod}+BracketLeft".action.consume-or-expel-window-left = [ ];
              "${mod}+BracketRight".action.consume-or-expel-window-right = [ ];
            };

          # ── Window rules ─────────────────────────────────────
          window-rules = [
            # Startup: kitty → research (btop rule below overrides for btop)
            {
              matches = [
                {
                  at-startup = true;
                  app-id = "^kitty$";
                }
              ];
              open-on-workspace = "research";
            }
            {
              matches = [
                {
                  at-startup = true;
                  app-id = "^kitty$";
                  title = "btop";
                }
              ];
              open-on-workspace = "system";
            }

            # Floating rules (scratchpads)
            {
              matches = [ { app-id = "^garden$"; } ];
              open-floating = true;
            }
            {
              matches = [ { title = "scratchpad-terminal"; } ];
              open-floating = true;
            }
            {
              matches = [ { app-id = "^lazygit$"; } ];
              open-floating = true;
            }

            # Host tier borders — HPC (urgent red)
            {
              matches = [
                { title = "frontier"; }
                { title = "andes"; }
                { title = "summit"; }
              ];
              border.active.color = palette.urgent;
            }

            # Host tier borders — GPU (accent gold)
            {
              matches = [ { title = "dgx-"; } ];
              border.active.color = palette.accent;
            }

            # Host tier borders — Homelab (ok green)
            {
              matches = [ { title = "homelab"; } ];
              border.active.color = palette.ok;
            }
          ];

          # ── Input ────────────────────────────────────────────
          input = {
            keyboard.xkb = { };
            touchpad = {
              tap = true;
              natural-scroll = true;
            };
            focus-follows-mouse.enable = true;
          };

          # ── Misc ─────────────────────────────────────────────
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;
        };

        # ── Idle + before-sleep locking (garden lock screen) ───
        # niri implements ext-idle-notify-v1; swayidle drives the garden
        # session lock via IPC. before-sleep holds a logind inhibitor so
        # the lock engages before suspend.
        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 600;
              command = "${qs} -c garden ipc call garden lock";
            }
          ];
          events."before-sleep" = "${qs} -c garden ipc call garden lock";
        };
      };
  };
}
