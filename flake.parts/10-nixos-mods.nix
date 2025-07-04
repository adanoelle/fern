{ self, ... }: {
  flake.nixosModules = {
    ada-dev   = import ../nix/modules/devtools/ada-toolchain.nix;
    audio     = import ../nix/modules/audio.nix;
    boot      = import ../nix/modules/boot.nix;
    core      = import ../nix/modules/core.nix;
    c-dev     = import ../nix/modules/devtools/c-toolchain.nix;
    graphics  = import ../nix/modules/graphics.nix;
    rust-dev  = import ../nix/modules/devtools/rust.nix;
    secrets   = import ../nix/modules/secrets.nix;
    users     = import ../nix/modules/users.nix;
  };
}

