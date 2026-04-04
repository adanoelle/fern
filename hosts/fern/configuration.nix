{ self, inputs, pkgs, lib, ... }:

{
  # Allow dynamic linking for Python
  programs.nix-ld.enable = true;

  imports = [
    ./hardware.nix

    # --- NixOS modules
    # self.nixosModules.boot  # fern uses systemd-boot (firmware resets EFI boot order)
    self.nixosModules.core
    self.nixosModules.c-dev
    self.nixosModules.aws
    self.nixosModules.azure-cli
    # self.nixosModules.cursor  # TODO: update claude-desktop flake input (hash mismatch)
    # self.nixosModules.claude  # TODO: update claude-desktop flake input (hash mismatch)
    self.nixosModules.docker
    self.nixosModules.lmstudio
    self.nixosModules.users
    self.nixosModules.audio
    self.nixosModules.monitoring
    self.nixosModules.greet
    self.nixosModules.localstack
    self.nixosModules.rust-dev
    self.nixosModules.teams
    self.nixosModules.typescript
    # self.nixosModules.secrets  # TODO: add fern's host key to .sops.yaml first
    self.nixosModules.guard
    self.nixosModules.vscode
    self.nixosModules.sqlserver

    # --- Home-Manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # --- Boot (systemd-boot — Minisforum firmware resets EFI boot order)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --- AMD GPU (uses Mesa/AMDGPU, no proprietary driver needed)
  hardware.graphics.enable = true;
  programs.hyprland.enable = true;

  # --- Disable LightDM (auto-enabled when xserver is on);
  #     use greetd from the greet module instead.
  services.xserver.displayManager.lightdm.enable = false;

  # --- Disable regreet (GTK greeter renders with corruption on Granite Ridge iGPU);
  #     use tuigreet as a lightweight TTY-based greeter instead.
  programs.regreet.enable = lib.mkForce false;
  services.greetd.settings.default_session = {
    command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
    user = "greeter";
  };

  environment.systemPackages = with pkgs; [
    mesa-demos # glxinfo, glxgears
    vulkan-tools # vulkaninfo, vkcube
    firefox
  ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  home-manager.extraSpecialArgs = { inherit self inputs; };

  # --- User imports
  home-manager.users.ada = {
    imports = [ ../common-hm.nix ];
  };

  nix.settings.trusted-users = [ "root" "ada" ];

  # Fern fonts (system-wide)
  services.fern-fonts.enable = true;

  time.timeZone = "America/New_York";

  system.stateVersion = "25.11";
  networking.hostName = "fern";
}
