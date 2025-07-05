{ pkgs, ... }:

{
  # --- Core runtimes & CLI tools                                        
  environment.systemPackages = with pkgs; [
    nodejs_24              # LTS – required by Next.js, CDK, etc.
    pnpm                   # fast, workspace‑friendly package manager
    nodePackages.yarn      # optional if some repos still use yarn
    deno                   # secure‑by‑default TS/JS runtime
    nodePackages.aws-cdk   # AWS CDK CLI for global use
    jq                     # JSON CLI (CDK synth output)
    parallel               # fast script loops
  ];

  # --- nix‑ld – lets Deno/uv etc. run pre‑built ELF binaries
  programs.nix-ld.enable = true;
}

