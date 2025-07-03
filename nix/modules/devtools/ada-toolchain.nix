# nix/modules/devtools/ada-toolchain.nix
{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    gnat13        # GNAT Ada compiler (GCC 13 build) :contentReference[oaicite:6]{index=6}
    gprbuild      # multi‑project build tool :contentReference[oaicite:7]{index=7}
    alire         # Ada package manager :contentReference[oaicite:8]{index=8}
  ];

  # Make GNAT default 'ada' compiler for path consistency
  environment.variables.ADA_PROJECT_PATH = "$HOME/.config/ada_project_path";
}

