{ self, ... }: {
  flake.nixosModules = {
    ada-dev   = import ../nix/modules/devtools/ada-toolchain.nix;
    audio     = import ../nix/modules/audio.nix;
    aws       = import ../nix/modules/cloud/aws-cli.nix;
    boot      = import ../nix/modules/boot.nix;
    core      = import ../nix/modules/core.nix;
    c-dev     = import ../nix/modules/devtools/c-toolchain.nix;
    docker    = import ../nix/modules/devtools/docker.nix;
    graphics  = import ../nix/modules/graphics.nix;
    rust-dev  = import ../nix/modules/devtools/rust.nix;
    secrets   = import ../nix/modules/secrets.nix;
    typescript= import ../nix/modules/devtools/node-ts.nix;
    users     = import ../nix/modules/users.nix;
  };
}

