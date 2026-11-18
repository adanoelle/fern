# modules/host-yarrow.nix — yarrow, Framework Laptop 13 Pro host aspect
#
# The portable art, game-development and playtesting machine. Like
# host-fern.nix this is composition only: roles, user layers and the
# facts that are true of this hardware alone.
{ den, inputs, ... }:
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

    # No Hyprland fallback, OBS (its build here assumes CUDA) or full
    # music layer: add them when they are wanted.
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
      den.aspects.niri
      # Built-in panel: backlight keys, and suspend when idle on battery
      den.aspects.brightness-backlight
      den.aspects.idle-suspend
      # What the machine is for
      den.aspects.art
      den.aspects.gamedev
      den.aspects.game-audio
      den.aspects.gaming-hm
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
