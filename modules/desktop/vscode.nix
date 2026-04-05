{ den, ... }:
{
  den.aspects.vscode.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ vscode ];
  };
}
