{ inputs, ... }:

{
  imports = [
    ./devtools/ada.nix
    ./devtools/cpp.nix
    ./devtools/csharp.nix
    ./devtools/python.nix
    ./devtools/typescript.nix
    ./devtools/zig.nix
  ];
}
