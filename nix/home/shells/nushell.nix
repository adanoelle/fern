{ pkgs, lib, ... }:

###############################################################################
# Nushell – rock‑solid developer profile
#
# • Starship prompt
# • zoxide directory jumper
# • Git‑friendly aliases & delta pager
# • Helix (hx) as editor, bat as pager
# • Generated init files live in ~/.cache/*   (created at activation time)
###############################################################################

let
  # ---------- Packages we rely on -------------------------------------------
  starship = pkgs.starship;
  zoxide   = pkgs.zoxide;
  delta    = pkgs.gitAndTools.delta;

  # ---------- Where we’ll store generated scripts ---------------------------
  starshipInit = "$HOME/.cache/starship/init.nu";
  zoxideInit   = "$HOME/.cache/zoxide.nu";

  # ---------- Helper to turn an attr‑set into Nushell alias lines ----------
  mkAliasBlock = aliases:
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: "alias ${n} = ${v}") aliases);

  # ---------- Helper for env vars block ------------------------------------
  mkEnvBlock = env:
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (k: v: "$env.${k} = \"${v}\"") env);

  # ---------- Git / general dev aliases ------------------------------------
  gitAliases = {
    gst = "git status -sb";
    gaa = "git add --all";
    gcm = "git commit -m";
    gco = "git checkout";
    gp  = "git push";
    gl  = "git pull";
    gg  = "git log --graph --decorate --oneline --all";
    gds = "git diff --staged";
    gdc = "git diff --cached";
  };

  # ---------- Environment variables ----------------------------------------
  myEnv = {
    EDITOR    = "hx";
    VISUAL    = "hx";
    PAGER     = "delta";
    GIT_PAGER = "delta";
    LESSHISTFILE = "-";
  };

  # ---------- Extra Nushell config string ----------------------------------
  extraCfg = lib.concatStringsSep "\n\n" [
    "# ── Starship prompt ───────────────────────────────────────────────"
    "source ~/.cache/starship/init.nu"

    "# ── zoxide integration ───────────────────────────────────────────"
    "source ~/.cache/zoxide.nu"

    "# ── Aliases ──────────────────────────────────────────────────────"
    (mkAliasBlock gitAliases)

    "# ── Environment variables ───────────────────────────────────────"
    (mkEnvBlock myEnv)

    ''
    # ── Core Nushell settings ─────────────────────────────────────────
    $env.config = {
      show_banner: false
      completions: {
        algorithm: "fuzzy"
        case_sensitive: false
        quick: true
      }
      edit_mode: "emacs"
    }
    ''
  ];
in
{
  ###########################################################################
  ##  Programs                                                              ##
  ###########################################################################
  programs.nushell = {
    enable       = true;
    extraConfig  = extraCfg;
  };

  ###########################################################################
  ##  Packages                                                              ##
  ###########################################################################
  home.packages = with pkgs; [
    nushell
    starship
    zoxide
    delta
    bat
    ripgrep
    fd
    git
  ];

  ###########################################################################
  ##  Activation hooks – generate init scripts before Nushell runs         ##
  ###########################################################################
  home.activation.starshipInit =
    lib.hm.dag.entryAfter [ "installPackages" ] ''
      mkdir -p ~/.cache/starship
      ${starship}/bin/starship init nu > ${starshipInit}
    '';

  home.activation.zoxideInit =
    lib.hm.dag.entryAfter [ "starshipInit" ] ''
      mkdir -p ~/.cache
      ${zoxide}/bin/zoxide init nushell > ${zoxideInit}
    '';
}

