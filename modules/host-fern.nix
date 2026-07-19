# modules/host-fern.nix — fern workstation host aspect
#
# Composition only: roles + user layers + genuinely fern-specific
# hardware config. Anything another machine could want belongs in a
# role (modules/roles/) or a shared aspect.
{ den, inputs, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.boot
      den.aspects.workstation
      den.aspects.dev-machine
      den.aspects.monitoring
      den.aspects.gaming
      den.aspects.niri
      den.aspects.lmstudio
      den.aspects.teams
    ];

    # Forward user layers: fern is a graphical dev machine, so its
    # users get the desktop and dev toolchain layers on top of the
    # base ada aspect. Niri is forwarded here (not from desktop-apps)
    # because its homeManager options only exist on hosts importing
    # the niri-flake NixOS module, which fern does below.
    provides.to-users.includes = [
      den.aspects.ada-desktop
      den.aspects.ada-dev
      den.aspects.niri
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          ../hosts/fern/hardware.nix
          inputs.niri.nixosModules.niri
        ];

        # Frozen at the release fern was installed with. NEVER bump this:
        # it gates stateful data migrations, not features.
        system.stateVersion = "25.11";

        # Use nixpkgs niri (avoids niri-flake fetchGit evaluation issue with Smithay)
        programs.niri.package = pkgs.niri;

        # Low-latency kernel for the pro-audio workstation role
        boot.kernelPackages = pkgs.linuxPackages_zen;

        # AMD IOMMU passthrough — prevents DMA interference with USB audio
        boot.kernelParams = [ "iommu=pt" ];

        # USB audio device rules (fern-specific hardware)
        # NOTE: Topping DAC ID (152a:8750) is unverified — check with lsusb when connected
        services.udev.extraRules = ''
          # Audient iD24 — symlink + disable USB autosuspend
          SUBSYSTEM=="usb", ATTRS{idVendor}=="2708", ATTRS{idProduct}=="4002", \
            SYMLINK+="audio/audient_id24"
          ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2708", ATTRS{idProduct}=="4002", \
            ATTR{power/autosuspend}="-1"

          # Topping DAC — disable USB autosuspend
          SUBSYSTEM=="usb", ATTRS{idVendor}=="152a", ATTRS{idProduct}=="8750", \
            SYMLINK+="audio/topping_dac"
          ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="152a", ATTRS{idProduct}=="8750", \
            ATTR{power/autosuspend}="-1"
        '';

        # USB audio interrupt priority tuning (requires den.aspects.audio for musnix import)
        musnix.rtirq = {
          enable = true;
          nameList = "usb snd";
          prioHigh = 90;
        };

        # AMD GPU (uses Mesa/AMDGPU, no proprietary driver needed)
        hardware.graphics.enable = true;

        # Hyprland (fallback session during Niri transition)
        programs.hyprland.enable = true;

        # Disable LightDM (auto-enabled when xserver is on);
        # use greetd from the greet module instead.
        services.xserver.displayManager.lightdm.enable = false;

        environment.systemPackages = with pkgs; [
          mesa-demos
          vulkan-tools
          firefox
        ];
      };
  };
}
