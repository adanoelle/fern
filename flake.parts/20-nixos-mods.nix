{ self, ... }: {
  flake.nixosModules = {
    ada-dev = import ../nix/modules/devtools/ada-toolchain.nix;
    audio = import ../nix/modules/audio.nix;
    aws = import ../nix/modules/cloud/aws-cli.nix;
    azure-cli = import ../nix/modules/azure-cli.nix;
    boot = import ../nix/modules/boot.nix;
    boot-asahi = import ../nix/modules/boot-asahi.nix;
    core = import ../nix/modules/core.nix;
    c-dev = import ../nix/modules/devtools/c-toolchain.nix;
    claude = import ../nix/modules/desktop/claude.nix;
    cursor = import ../nix/modules/desktop/cursor.nix;
    docker = import ../nix/modules/devtools/docker.nix;
    fonts = import ../nix/modules/fonts.nix;
    gaming = import ../nix/modules/gaming.nix;
    graphics = import ../nix/modules/graphics.nix;
    graphics-asahi = import ../nix/modules/graphics-asahi.nix;
    greet = import ../nix/modules/desktop/greetd.nix;
    localstack = import ../nix/modules/devtools/localstack.nix;
    lmstudio = import ../nix/modules/desktop/lmstudio.nix;
    rust-dev = import ../nix/modules/devtools/rust.nix;
    secrets = import ../nix/modules/secrets.nix;
    guard = import ../nix/modules/secrets-guard.nix;
    teams = import ../nix/modules/desktop/teams.nix;
    typescript = import ../nix/modules/devtools/node-ts.nix;
    users = import ../nix/modules/users.nix;
    vscode = import ../nix/modules/desktop/vscode.nix;
    sqlserver = import ../nix/modules/desktop/sqlserver.nix;
  };
}
