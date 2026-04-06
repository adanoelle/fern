# modules/shells/starship.nix — Starship cross-shell prompt
{ den, ... }:
{
  den.aspects.starship.homeManager = { pkgs, ... }:
  {
    home.packages = with pkgs; [starship];

    programs.starship = {
      enable = true;
      enableFishIntegration = false;
      settings = {
        add_newline = true;
        line_break.disabled = false;
        character = {
          success_symbol = "[➜](bold green)";
        };
        os = {
          format = "$symbol";
          style = "bold blue";
          disabled = false;
        };
        os.symbols = {
          NixOS = "❄️ ";
        };
      };
    };
  };
}
