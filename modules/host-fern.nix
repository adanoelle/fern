# modules/host-fern.nix — fern workstation host aspect
{ den, inputs, ... }:
{
  den.aspects.fern = {
    includes = [
      den.aspects.core
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

    nixos = { pkgs, lib, ... }: {
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

      nix.settings.trusted-users = [ "root" "ada" ];
      time.timeZone = "America/New_York";
    };
  };
}
