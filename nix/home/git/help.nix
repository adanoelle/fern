# git/help.nix - Git help system using tldr and references (no scripts)
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitHelp;
in
{
  options.programs.gitHelp = {
    enable = mkEnableOption "Git help system";

    enableTldr = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tldr for command examples";
    };
  };

  config = mkIf cfg.enable {
    # Install help tools
    home.packages = with pkgs;
      optional cfg.enableTldr tldr;

    # Git aliases for help
    programs.git.aliases = {
      # Help commands
      h = "help";
      help-config = "config --list --show-origin";
      help-aliases = "config --get-regexp '^alias\\.'";
      help-commands = "help -a";
      help-guides = "help -g";
      
      # Quick reference (renamed to avoid conflict)
      list-aliases = "!git config --get-regexp '^alias\\.' | sed 's/alias\\.//g' | sort";
      la = "!git list-aliases";  # List aliases shortcut
    };

    # Create quick reference file
    home.file.".config/git/quick-ref.txt".text = ''
      GIT QUICK REFERENCE
      ===================
      
      COMMON COMMANDS
      ---------------
      g       - git status
      ga      - git add
      gaa     - git add -A
      gc      - git commit
      gcm     - git commit -m
      gp      - git push
      gpu     - git push -u origin HEAD
      gpl     - git pull
      gl      - git log --oneline
      gd      - git diff
      gco     - git checkout
      gb      - git branch
      
      WORKTREES
      ---------
      wtn <name>  - Create new worktree
      wtl         - List worktrees  
      git wt-new  - Create worktree with branch
      
      IDENTITY
      --------
      gid         - Show current identity
      git id      - Show name and email
      git id-list - List configured identities
      
      GITHUB
      ------
      pr          - GitHub PR commands
      prc         - Create PR
      prl         - List PRs
      prw         - View PR in browser
      issue       - GitHub issue commands
      myprs       - List your PRs
      
      SAFETY
      ------
      git pushf   - Safe force push (--force-with-lease)
      git undo    - Undo last commit (keep changes)
      git amend   - Amend last commit
      git cleanup - Remove merged branches
      
      TOOLS
      -----
      lg          - LazyGit UI
      tig         - Tig interface
      git absorb  - Auto-fixup commits
      
      HELP
      ----
      git list-aliases - List all git aliases
      git h            - Git help
      tldr git         - Show examples (if tldr installed)
      
      For more: cat ~/.config/git/quick-ref.txt
    '';

    # Shell aliases for help
    home.shellAliases = mkMerge [
      {
        # Quick help
        "g-help" = "cat ~/.config/git/quick-ref.txt";
        "g-aliases" = "git list-aliases";
        "g-ref" = "echo 'Common: g (status), ga (add), gc (commit), gp (push), gl (log)'";
      }
      
      (mkIf cfg.enableTldr {
        "git-help" = "tldr git";
        "g-examples" = "tldr git";
      })
    ];
  };
}