# modules/user-ada-work.nix — user ada, ORNL work-laptop layer
#
# Standalone-home layer for the Ubuntu work laptop: the full niri +
# garden desktop plus the dev toolchain, on top of the base ada aspect.
# Deliberately NOT ada-desktop — hyprland, DAW, and gaming don't belong
# on a work machine. garden.shell is included explicitly: on fern the
# garden QML/tooling arrives by other means, but a standalone home has
# to pull the whole bundle itself.
#
# Attached below via den.aspects.ada.provides."LAP155464", which
# den's mutual-provider routes into the standalone home (see
# ctx.home.includes in modules/dendritic.nix and the den.homes entry in
# modules/hosts.nix).
{ den, garden, ... }:
{
  den.aspects.ada-work = {
    includes = [
      den.aspects.ada-dev
      den.aspects.niri-standalone
      den.aspects.ubuntu-desktop
      den.aspects.docker-rootless
      garden.shell
      den.aspects.fonts
      den.aspects.imv
      den.aspects.pdf
      den.aspects.obsidian
      den.aspects.screenshot
      den.aspects.teams
      # Browsers: Zen is the daily driver; Chrome (system apt package,
      # isolated profile) is for the REPD enclave portal only.
      den.aspects.zen
      den.aspects.repd-chrome
      # Mail: Thunderbird against the ORNL Exchange Online mailbox via
      # the Microsoft Graph API. Work-laptop only for now.
      den.aspects.thunderbird
      # Data: DuckDB + dpeek + harlequin for inspecting the research
      # group's Parquet files and small datastores outside any project env.
      den.aspects.duckdb
      # Sargent's "Nonchaloir (Repose)" behind the niri session.
      den.aspects.wallpaper
    ];

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        # Zen mode toggle (Mod+Z). Moves the focused window to the "zen"
        # workspace, where it is the only column and sits centred on the
        # wallpaper; pressing it again sends the window back to the
        # workspace it came from. One window at a time: zen-ing another
        # window sends the current occupant home first. Origins live in
        # $XDG_RUNTIME_DIR/niri-zen/<window id> (workspace ids are stable
        # for a workspace's lifetime). If the origin workspace is gone
        # (niri drops an unnamed workspace once its last window leaves),
        # the window goes to the first workspace on zen's monitor.
        niri-zen = pkgs.writeShellApplication {
          name = "niri-zen";
          runtimeInputs = [
            config.programs.niri.package
            pkgs.jq
            pkgs.coreutils
          ];
          text = ''
            state="''${XDG_RUNTIME_DIR:-/tmp}/niri-zen"
            mkdir -p "$state"

            workspaces=$(niri msg -j workspaces)
            zen_id=$(jq -r '.[] | select(.name == "zen") | .id' <<<"$workspaces")
            [ -n "$zen_id" ] || { echo "niri-zen: no workspace named zen" >&2; exit 1; }

            # Send a window back to where it came from.
            #   send_home <window id> <focus: true|false>
            send_home() {
              local win="$1" focus="$2" origin ref
              origin=$(cat "$state/$win" 2>/dev/null || true)
              ref=$(jq -r --argjson id "''${origin:-0}" \
                '.[] | select(.id == $id) | (.name // (.idx | tostring))' <<<"$workspaces")
              if [ -n "$ref" ] && [ "$origin" != "$zen_id" ]; then
                local out
                out=$(jq -r --argjson id "$origin" '.[] | select(.id == $id) | .output' <<<"$workspaces")
                niri msg action move-window-to-monitor --id "$win" "$out" 2>/dev/null || true
                niri msg action move-window-to-workspace --window-id "$win" --focus "$focus" "$ref"
              else
                niri msg action move-window-to-workspace --window-id "$win" --focus "$focus" 1
              fi
              rm -f "$state/$win"
            }

            focused=$(niri msg -j focused-window)
            win=$(jq -r '.id // empty' <<<"$focused")
            [ -n "$win" ] || exit 0
            ws=$(jq -r '.workspace_id' <<<"$focused")

            if [ "$ws" = "$zen_id" ]; then
              send_home "$win" true
              exit 0
            fi

            # Evict whatever is already in zen (single pane of glass).
            for other in $(niri msg -j windows | jq -r --argjson z "$zen_id" \
                '.[] | select(.workspace_id == $z) | .id'); do
              send_home "$other" false
            done

            printf '%s\n' "$ws" > "$state/$win"
            niri msg action move-window-to-workspace --window-id "$win" --focus true zen
          '';
        };

        olcfSshDefaults = {
          User = "adanoelle";
          ControlMaster = "no";
          PreferredAuthentications = "keyboard-interactive,password";
          ServerAliveInterval = "300";
          ServerAliveCountMax = "3";
          SetEnv = {
            TERM = "xterm-256color";
          };
        };
      in
      {
        # Laptop panel brightness. The shared niri aspect binds ddcutil
        # (DDC/CI, external monitors only); on a laptop the internal
        # panel needs sysfs backlight via brightnessctl instead.
        # ddcutil remains available for docked external monitors.
        home.packages = [
          pkgs.brightnessctl
          pkgs.pandoc
          pkgs.glow
          pkgs.zotero
        ];

        # Desk layout: the LG ultrawide on the dock sits behind and above
        # the laptop, so stack them vertically with the laptop panel
        # centred under the monitor (x = (3440 - 1920) / 2). Without this
        # niri appends new outputs to the right at (1920, 0); the two
        # screens then share only the top 1200 px of one vertical edge
        # and the cursor gets trapped on the ultrawide.
        # The monitor is matched by make/model/serial, not "DP-2": dock
        # connector names change between docks and ports.
        # Lid-closed docking needs nothing here: logind ignores the lid
        # while an external display is attached (HandleLidSwitchDocked),
        # and niri turns eDP-1 off on lid close, leaving the ultrawide
        # as the only output.
        programs.niri.settings.outputs = {
          "LG Electronics LG ULTRAWIDE 602RMJF9M948" = {
            position = {
              x = 0;
              y = 0;
            };
            focus-at-startup = true;
          };
          "eDP-1".position = {
            x = 760;
            y = 1440;
          };
        };

        # Docked, the ultrawide is the main screen: pin the five named
        # channels to it. niri moves a named workspace to its
        # open-on-output when that output connects and back to a
        # remaining output when it disconnects, so undocked everything
        # lands on the laptop panel as before. "laptop" is reserved for
        # the panel when it's used as a second screen (lid open).
        programs.niri.settings.workspaces =
          let
            ultrawide = "LG Electronics LG ULTRAWIDE 602RMJF9M948";
          in
          {
            "1-studio".open-on-output = ultrawide;
            "2-research".open-on-output = ultrawide;
            "3-writing".open-on-output = ultrawide;
            "4-music".open-on-output = ultrawide;
            "5-system".open-on-output = ultrawide;
            "6-laptop" = {
              name = "laptop";
              open-on-output = "eDP-1";
            };
            # Zen mode's workspace (Mod+Z, niri-zen below): holds at most
            # one window, which always-center-single-column puts in the
            # middle of the wallpaper.
            "7-zen" = {
              name = "zen";
              open-on-output = ultrawide;
            };
          };

        # Keep the work in the middle of the screen. On the 3440 px
        # ultrawide a left-anchored column means looking off to the left
        # all day; instead the focused column is always centred (other
        # columns peek in from the sides and slide to centre when
        # focused), and a column alone on a workspace sits centred on
        # the wallpaper. New columns open at 50% (the shared default);
        # Mod+R still cycles the 50/75/100% presets. Laptop-only: fern's
        # desktop keeps the shared "on-overflow" behaviour.
        programs.niri.settings.layout = {
          center-focused-column = lib.mkForce "always";
          always-center-single-column = true;
        };

        programs.niri.settings.binds = {
          # Zen mode: a single centred pane on the wallpaper.
          "Mod+Z".action.spawn = [ (lib.getExe niri-zen) ];
          "Mod+6".action.focus-workspace = "laptop";
          "Mod+Shift+6".action.move-window-to-workspace = "laptop";
          "XF86MonBrightnessUp".action = lib.mkForce {
            spawn = [
              "brightnessctl"
              "set"
              "5%+"
            ];
          };
          "XF86MonBrightnessDown".action = lib.mkForce {
            spawn = [
              "brightnessctl"
              "set"
              "5%-"
            ];
          };
          # Lock: Ctrl+Alt+F1 (VT-switch to GDM greeter) is the only
          # working lock on the ORNL laptop — garden lock and swaylock
          # both fail with the YubiKey/PKCS#11 PAM stack. Unbind
          # Mod+Alt+L so it can't accidentally fire a broken locker.
          # See book/src/operations/work-laptop-preflight.md (BLOCKER).
          "Mod+Alt+L".action = lib.mkForce { spawn = [ "true" ]; };
        };

        programs.ssh.settings."code-int code-int.ornl.gov" = {
          User = "git";
          IdentityFile = "~/.ssh/code-int";
          IdentitiesOnly = "yes";
        };

        programs.ssh.settings."code-ornl code.ornl.gov" = {
          User = "git";
          IdentityFile = "~/.ssh/code-ornl";
          IdentitiesOnly = "yes";
        };

        # OLCF HPC systems — RSA SecurID two-factor auth, no multiplexing.
        # After connecting, run `tmux` on home and SSH to internal systems
        # from there — inner hops don't require another token.
        # Sync tmux config: scp ~/.tmux.conf olcf-home:.tmux.conf
        programs.ssh.settings."olcf-home" = olcfSshDefaults // {
          HostName = "home.ccs.ornl.gov";
        };
        programs.ssh.settings."frontier" = olcfSshDefaults // {
          HostName = "frontier.olcf.ornl.gov";
        };
        programs.ssh.settings."andes" = olcfSshDefaults // {
          HostName = "andes.olcf.ornl.gov";
        };
        programs.ssh.settings."olcf-dtn" = olcfSshDefaults // {
          HostName = "dtn.ccs.ornl.gov";
        };
        programs.ssh.settings."*.ccs.ornl.gov *.olcf.ornl.gov" = olcfSshDefaults;

        # Disable swayidle entirely. Neither garden lock nor swaylock
        # can authenticate with ORNL's YubiKey PAM stack.
        # Lock manually with Ctrl+Alt+F1 (VT-switch to GDM greeter).
        # TODO: automate via `sudo chvt 1` if a sudoers rule becomes
        # possible, or find a non-root VT-switch mechanism.
        services.swayidle.enable = lib.mkForce false;

        # ORNL GlobalProtect VPN (Ubuntu's /usr/bin/globalprotect CLI).
        # The kdi-vpn portal fronts the enclave and OLCF access.
        programs.fish.shellAbbrs = {
          vpn = "globalprotect connect -p kdi-vpn.ornl.gov";
          vpnoff = "globalprotect disconnect";
          vpns = "globalprotect show --status";
        };
      };
  };

  # Forward the ada-work layer into the ORNL work laptop's standalone home.
  den.aspects.ada.provides."LAP155464".includes = [ den.aspects.ada-work ];
}
