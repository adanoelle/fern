{ self, ... }: {
  flake.nixosModules = {
    audio     = import ../nix/modules/audio.nix;
    boot      = import ../nix/modules/bootloader.nix;
    graphics  = import ../nix/modules/graphics.nix;
    rust-dev  = import ../nix/modules/devtools/rust.nix;
    users     = import ../nix/modules/users.nix;
  };
}

