{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;

    # Optional: global config
    extraConfig = ''
      $env.config.history.size = 5000
    '';
    # Optional: enable completions for Cargo etc.
    envFile.text = ''
      use ${pkgs.starship}/share/starship/init.nu
    '';
  };
}

