{ pkgs, zig-overlay, ... }:

let
  zigPkgs = zig-overlay.packages.${pkgs.system};
in
{
  home.packages = [ zigPkgs.master ];  # tracks latest official Zig
}

