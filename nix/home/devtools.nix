{ inputs, ... }:

{
  imports = [
    ./devtools/ada.nix
    ./devtools/cpp.nix
    ./devtools/csharp.nix
    ./devtools/zig.nix
  ];
}
