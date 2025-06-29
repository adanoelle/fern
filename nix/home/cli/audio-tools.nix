{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # High‑level helpers
    lsp-plugins            # LV2 plugin suite
  ];
}

