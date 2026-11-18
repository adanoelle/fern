# modules/devtools/zig.nix — Zig compiler and language server
#
# zls must match the compiler's minor version; both come from the same
# nixpkgs pin, which keeps them in step. Helix's built-in `zig` entry
# finds `zls` on PATH, formats with `zig fmt` and debugs with lldb-dap,
# so no editor configuration is needed here.
_: {
  den.aspects.zig.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.zig
        pkgs.zls
      ];
    };
}
