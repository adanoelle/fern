{ inputs, ... }:

{
  imports = [
    ./devtools/cpp.nix
    ./devtools/csharp.nix
    ./devtools/zig.nix
  ];
}
