{ den, ... }:
{
  den.aspects.cursor.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ code-cursor ];
  };
}
