# modules/host-fern.nix — fern workstation host aspect
{ den, inputs, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.core
      den.aspects.nh
      den.aspects.audio
      den.aspects.monitoring
      den.aspects.users
      den.aspects.secrets-guard
      den.aspects.greetd
      den.aspects.fonts
      den.aspects.niri
      den.aspects.docker
      den.aspects.c-cpp
      den.aspects.localstack
      den.aspects.rust
      den.aspects.node-ts
      den.aspects.aws-cli
      den.aspects.lmstudio
      den.aspects.teams
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        imports = [
          ../hosts/fern/hardware.nix
          inputs.niri.nixosModules.niri
        ];

        # Use nixpkgs niri (avoids niri-flake fetchGit evaluation issue with Smithay)
        programs.niri.package = pkgs.niri;

        programs.nix-ld.enable = true;

        # Boot (systemd-boot — Minisforum firmware resets EFI boot order)
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
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

        # Disable regreet (GTK greeter renders with corruption on Granite Ridge iGPU);
        # use tuigreet as a lightweight TTY-based greeter instead.
        # Offer both Niri (default) and Hyprland sessions.
        programs.regreet.enable = lib.mkForce false;
        services.greetd.settings.default_session = {
          command = builtins.concatStringsSep " " [
            "${pkgs.greetd.tuigreet}/bin/tuigreet"
            "--time"
            "--remember"
            "--sessions ${pkgs.writeTextDir "share/wayland-sessions/niri.desktop" ''
              [Desktop Entry]
              Name=Niri
              Exec=niri-session
              Type=Application
            ''}/share/wayland-sessions:${pkgs.writeTextDir "share/wayland-sessions/hyprland.desktop" ''
              [Desktop Entry]
              Name=Hyprland
              Exec=Hyprland
              Type=Application
            ''}/share/wayland-sessions"
          ];
          user = "greeter";
        };

        environment.systemPackages = with pkgs; [
          mesa-demos
          vulkan-tools
          firefox
        ];

        nix.settings.trusted-users = [
          "root"
          "ada"
        ];
        time.timeZone = "America/New_York";
      };
  };
}
