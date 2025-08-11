{ inputs, ... }:

{
  imports = [
    ./shells/devenv.nix
    ./shells/nushell.nix
    ./shells/zoxide.nix
    ./shells/starship.nix
  ];
}
