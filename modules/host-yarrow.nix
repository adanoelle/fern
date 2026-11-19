# modules/host-yarrow.nix — yarrow, Framework Laptop 13 Pro host aspect
#
# The portable art, game-development and playtesting machine. Like
# host-fern.nix this is composition only: roles, user layers and the
# facts that are true of this hardware alone.
{
  den,
  garden,
  inputs,
  ...
}:
{
  den.aspects.yarrow = {
    includes = [
      den.aspects.boot
      den.aspects.workstation
      den.aspects.laptop
      den.aspects.dev-machine
      den.aspects.tailscale
      den.aspects.audio-laptop
      den.aspects.gaming
      den.aspects.niri
    ];

    # No full music layer: add it when it is wanted.
    provides.to-users.includes = [
      # The desktop core, taken as its two halves instead of through
      # ada-desktop: the applications, and the whole garden shell (QML,
      # settings, screenshot tools) rather than only garden.terminal.
      # garden.shell already includes garden.terminal, and including
      # both doubles kitty's theme include. The niri aspect only
      # launches the shell; nothing else on this host brings it in.
      den.aspects.desktop-apps
      garden.shell
      den.aspects.ada-dev
      den.aspects.niri
      # The chrome key pointer
      den.aspects.cursor
      # Painted wallpapers: the active palette picks the painter
      den.aspects.wallpaper
      # Built-in panel: backlight keys, and suspend when idle on battery
      den.aspects.brightness-backlight
      den.aspects.idle-suspend
      # What the machine is for
      den.aspects.art
      den.aspects.gamedev
      den.aspects.game-audio
      den.aspects.gaming-hm
      # Recording playtests and process videos
      den.aspects.obs
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          ../hosts/yarrow/hardware.nix
          inputs.niri.nixosModules.niri
          inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
        ];

        # Frozen at the release yarrow was installed with. NEVER bump this:
        # it gates stateful data migrations, not features.
        system.stateVersion = "26.11";

        # The users' Home Manager state version, frozen like the system
        # one at the release this machine was installed with.
        home-manager.sharedModules = [ { home.stateVersion = "26.11"; } ];

        # Use nixpkgs niri (avoids niri-flake fetchGit evaluation issue with Smithay)
        programs.niri.package = pkgs.niri;

        # Newest kernel: this platform's graphics, audio and power
        # support is still landing upstream.
        boot.kernelPackages = pkgs.linuxPackages_latest;

        hardware.graphics.enable = true;

        # nixos-hardware turns the fingerprint reader on. Off until it
        # has been tried with tuigreet and the garden lock screen, where
        # PAM would wait on the reader before accepting a password.
        services.fprintd.enable = false;

        environment.systemPackages = with pkgs; [
          mesa-demos
          vulkan-tools
        ];
      };
  };
}
