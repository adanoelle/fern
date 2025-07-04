# nix/hm-modules/devtools/ada.nix (corrected)
{ pkgs, ... }:

{
  # User‑level tools
  home.packages = with pkgs; [
    alire                 # Ada/SPARK package manager → provides `alr`
    # gnatstudio is not in nixpkgs; you can install it later through Alire or a custom derivation
  ];

  # Helix LSP hook
  programs.helix.languages = {
    language-server.ada_ls = { command = "ada_language_server"; };
    language = [
      { name = "ada"; language-servers = [ "ada_ls" ]; }
    ];
  };
}

