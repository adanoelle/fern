# modules/cli/rbw.nix — Bitwarden CLI client
{ den, ... }:
{
  den.aspects.rbw.homeManager =
    { pkgs, ... }:
    {
      programs.rbw = {
        enable = true;
        settings = {
          email = "adanoelleyoung@gmail.com";
          # Headless-safe; rbw is invoked from a terminal anyway.
          pinentry = pkgs.pinentry-curses;
          # base_url unset -> vault.bitwarden.com. When the homelab
          # vaultwarden exists, set base_url here (one line).
        };
      };
    };
}
