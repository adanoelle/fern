{ self, ... }: {
  flake.nixosModules = {
    audio     = import ../nix/modules/audio.nix;
    boot      = import ../nix/modules/boot.nix;
    core      = import ../nix/modules/core.nix;
    graphics  = import ../nix/modules/graphics.nix;
    rust-dev  = import ../nix/modules/devtools/rust.nix;
    secrets   = import ../nix/modules/secrets.nix;
    users     = import ../nix/modules/users.nix;
  };
}

