# nix/hm-modules/shells/nushell.nix
#
# Home-Manager module: enables Nushell, adds aliases, Starship prompt,
# zoxide & git completions, and several QoL settings.

{ pkgs, lib, ... }:

let
  starshipInit = ''
    # Initialise Starship prompt for Nushell
    mkdir ~/.cache/starship || true
    starship init nu | save --force ~/.cache/starship/init.nu
    source ~/.cache/starship/init.nu
  '';

  myAliases = {
    l  = "ls -lah";
    g  = "git";
    c  = "clear";
    d  = "docker";
    k  = "kubectl";
    gg = "git graph --all --decorate --oneline --graph";
  };

  myEnv = {
    EDITOR    = "hx";
    LESSHISTFILE = "-";          # disable less history file
    PAGER     = "bat --paging always";
  };

  # turn alias {key: value} into Nushell alias commands
  mkAliasBlock = aliases:
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: cmd: "alias " + name + " = " + cmd) aliases);

  # turn env table into let-env lines
  mkEnvBlock = env:
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (k: v: "$env." + k + " = \"" + v + "\"") env);
in
{
  programs.nushell = {
    enable = true;

    # Include Nushell completions/built-in plugins
    extraConfig = lib.concatStringsSep "\n\n" [
      starshipInit
      (mkAliasBlock myAliases)
      (mkEnvBlock myEnv)

      ''
      # ─── QoL settings ──────────────────────────────────────────
      $env.config = {
        show_banner: false
        history: {
          file: "~/.local/share/nushell/history.txt"
          max_size: 50000
        }
        completions: {
          algorithm: "fuzzy"
          case_sensitive: false
          quick: true
        }
        edit_mode: "emacs"
      }
      ''
    ];

    # Auto-load completions for cargo, git, etc.
    envFile.text = ''
      use ${pkgs.git}/share/git-core/completion/git-completion.bash *
      use ${pkgs.cargo}/share/zsh/site-functions/_cargo *
      use ${pkgs.zoxide}/share/zoxide/init.nu
    '';
  };

  # Ensure required packages are present
  home.packages = with pkgs; [
    nushell
    starship
    zoxide
    bat
    ripgrep
    fd
  ];
}

