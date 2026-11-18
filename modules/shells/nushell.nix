# modules/shells/nushell.nix — Nushell developer shell with prompt, zoxide, aliases
_: {
  den.aspects.nushell.homeManager =
    { pkgs, lib, ... }:

    ###############################################################################
    # Nushell – rock-solid developer profile
    #
    # • Starship prompt and zoxide: initialised by their own aspects
    #   (programs.starship / programs.zoxide Nushell integration), not here
    # • Git shortcuts: home.shellAliases from modules/git/aliases.nix
    # • Helix (hx) as editor, delta as pager
    ###############################################################################

    let
      inherit (pkgs) delta;

      # --- Helper for env vars block
      mkEnvBlock = env: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "$env.${k} = \"${v}\"") env);

      # --- Environment variables
      myEnv = {
        EDITOR = "hx";
        VISUAL = "hx";
        PAGER = "delta";
        GIT_PAGER = "delta";
        LESSHISTFILE = "-";
      };

      # --- Extra Nushell config string
      extraCfg = lib.concatStringsSep "\n\n" [
        "# ── Environment variables ───────────────────────────────────────"
        (mkEnvBlock myEnv)

        ''
          # ── Core Nushell settings ─────────────────────────────────────────
          $env.config = {
            show_banner: true
            completions: {
              algorithm: "prefix"
              case_sensitive: false
              quick: true
              external: {
                enable: false
              }
            }
          }
        ''
      ];
    in
    {

      programs.nushell = {
        enable = true;
        extraConfig = extraCfg;
      };

      home = {
        sessionVariables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

        packages = with pkgs; [
          nushell
          delta
          bat
          ripgrep
          fd
          git
        ];
      };
    };
}
