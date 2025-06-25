{ inputs, ... }:

{
  imports = [
    ./shells/nushell.nix
    ./shells/zoxide.nix
    ./shells/starship.nix
  ];
}
