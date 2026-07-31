# modules/foreign/ubuntu-desktop.nix — Nix-managed desktop on Ubuntu
#
# Everything a standalone home needs to run the niri + garden session on
# a foreign distro (the ORNL work laptop, Ubuntu 24.04): nixGL wrapping
# for GL access, the session packages fern's niri nixos side would have
# provided as systemPackages, systemd user units for the session tree,
# and portal routing to Ubuntu's system xdg-desktop-portal backends.
#
# nixGL strategy — session-level wrap: only programs.niri.package is
# wrapped (mesa). The compositor is the root of the session process
# tree, so quickshell, kitty, xwayland-satellite, firefox etc. inherit
# the GL environment. nixGLMesa (installScripts) covers ad-hoc wrapping
# of anything launched outside the session tree.
#
# The one root-owned file on the Ubuntu side is
# /usr/share/wayland-sessions/niri.desktop, whose Exec points at the
# stable ~/.local/bin/niri-session-shim below — GDM runs it without any
# Nix env, so the shim bootstraps PATH/XDG_DATA_DIRS itself. See
# book/src/operations/work-laptop.md for the full root checklist.
{ inputs, ... }:
{
  den.aspects.ubuntu-desktop.homeManager =
    { pkgs, config, ... }:
    {
      targets.genericLinux = {
        enable = true;
        nixGL = {
          packages = inputs.nixgl.packages;
          defaultWrapper = "mesa";
          installScripts = [ "mesa" ];
        };
      };

      # Wrapped compositor. The wrapper rewrites the package's systemd
      # user units to point at the wrapped binary, so niri.service below
      # starts niri with GL configured. If niri-flake's sandboxed
      # `niri validate` ever chokes on the wrapped package, fall back to
      # pkgs.niri here and override niri.service ExecStart with
      # `nixGLMesa niri --session` instead.
      programs.niri.package = config.lib.nixGL.wrap pkgs.niri;

      # What fern's niri nixos side provides via systemPackages
      # (modules/desktop/niri.nix + host-fern.nix), plus mesa-demos for
      # GL verification (`nixGLMesa glxinfo`).
      home.packages = with pkgs; [
        xwayland-satellite
        ddcutil
        quickshell
        firefox
        mesa-demos
      ];

      # systemd user units for the session. On NixOS these come from
      # the system profile's unit dirs; on Ubuntu the systemd user
      # manager doesn't search the Nix profile, so link the (wrapped)
      # package's units into ~/.config/systemd/user explicitly.
      # niri-session activates niri.service against graphical-session
      # targets and niri-shutdown.target tears it down.
      xdg.configFile = {
        "systemd/user/niri.service".source =
          "${config.programs.niri.package}/share/systemd/user/niri.service";
        "systemd/user/niri-shutdown.target".source =
          "${config.programs.niri.package}/share/systemd/user/niri-shutdown.target";
      };

      # Stable Exec target for the root-owned GDM session file. GDM
      # starts this with a clean environment: source the nix profile
      # scripts (single- and multi-user installer layouts), make the
      # home profile win PATH, and expose its share/ for .desktop files
      # and portal definitions before handing over to niri-session.
      home.file.".local/bin/niri-session-shim" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Root of the "Niri (garden)" GDM session on Ubuntu. Referenced
          # by /usr/share/wayland-sessions/niri.desktop; do not rename.
          for profile in /etc/profile.d/nix.sh \
            /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; do
            if [ -e "$profile" ]; then
              . "$profile"
            fi
          done
          export PATH="$HOME/.nix-profile/bin:$PATH"
          export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
          exec niri-session
        '';
      };

      # Route portal requests to Ubuntu's system xdg-desktop-portal
      # (≥ 1.17 reads ~/.config/xdg-desktop-portal/niri-portals.conf):
      # gtk first for file choosers, gnome for screencast.
      xdg.portal.config.niri.default = [
        "gtk"
        "gnome"
      ];
    };
}
