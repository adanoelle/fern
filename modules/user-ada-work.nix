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
    ];

    homeManager =
      { pkgs, lib, ... }:
      let
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

        programs.niri.settings.binds = {
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
      };
  };

  # Forward the ada-work layer into the ORNL work laptop's standalone home.
  den.aspects.ada.provides."LAP155464".includes = [ den.aspects.ada-work ];
}
