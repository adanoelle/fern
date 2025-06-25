{ inputs, ... }: {
  imports = [
    ./hardware.nix
    inputs.self.modules.base.bootloader
    inputs.self.modules.base.users
    inputs.self.modules.audio
  ];
  networking.hostName = "fern";
}

