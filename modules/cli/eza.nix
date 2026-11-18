# modules/cli/eza.nix — eza (modern ls replacement)
#
# The listing shortcuts (l, la, lt, ll) are defined once, below, and
# applied to every shell. Home Manager's eza module ships its own
# ll/la/lt with different meanings; they are set at default priority, so
# the definitions here replace them in fish and bash.
#
# zsh is handled separately because ~/.zshrc is meant to be copied to
# machines without Nix (see shells/zsh.nix): there the eza integration
# is switched off and the aliases are written inside a `command -v eza`
# guard, so `ls` keeps working where eza is not installed.
_: {
  den.aspects.eza.homeManager =
    { lib, ... }:
    let
      listing = {
        l = "eza -l";
        la = "eza -la";
        lt = "eza -lT --level=2";
        ll = "eza -l --sort=modified --reverse";
      };
      # What the eza module would have added besides the four above.
      extras = {
        ls = "eza";
        lla = "eza -la";
      };
    in
    {
      programs.eza = {
        enable = true;
        icons = "auto";
        git = true;
        extraOptions = [
          "--group-directories-first"
        ];
        enableZshIntegration = false;
      };

      programs.fish = {
        shellAliases = listing;
        # Abbreviations too, so they expand in place as you type.
        shellAbbrs = listing;
      };

      programs.bash.shellAliases = listing;

      programs.zsh.initContent = ''
        # eza listings, only where eza exists (this file travels)
        command -v eza &>/dev/null && {
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "  alias ${name}=${lib.escapeShellArg value}") (extras // listing)
        )}
        }
      '';
    };
}
