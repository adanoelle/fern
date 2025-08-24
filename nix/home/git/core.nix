# git/core.nix - Core Git configuration for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitCore;
in
{
  options.programs.gitCore = {
    enable = mkEnableOption "Core Git configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.gitFull;
      description = "Git package to use";
    };

    editor = mkOption {
      type = types.str;
      default = "hx";
      description = "Default editor for Git operations";
    };

    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };

    signCommits = mkOption {
      type = types.bool;
      default = true;
      description = "Sign commits with SSH key";
    };

    signingKey = mkOption {
      type = types.str;
      default = "~/.ssh/github";
      description = "SSH key to use for signing";
    };

    delta = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable delta for better diffs";
      };

      options = mkOption {
        type = types.attrs;
        default = {
          navigate = true;
          light = false;
          line-numbers = true;
          side-by-side = true;
          syntax-theme = "Monokai Extended";
          hyperlinks = true;
        };
        description = "Delta configuration options";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.git = {
      enable = true;
      
      package = cfg.package;
      
      delta = mkIf cfg.delta.enable {
        enable = true;
        options = cfg.delta.options // {
          # Helix-specific hyperlink format if editor is hx
          hyperlinks-file-link-format = mkIf (cfg.editor == "hx") "hx://{path}:{line}";
        };
      };
      
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
        core = {
          editor = cfg.editor;
          autocrlf = "input";
          whitespace = "trailing-space,space-before-tab";
          
          # Performance optimizations
          preloadIndex = true;
          multiPackIndex = true;
          commitGraph = true;
          untrackedCache = true;
          fsmonitor = true;
        };
        
        # SSH signing configuration
        commit.gpgsign = cfg.signCommits;
        gpg.format = mkIf cfg.signCommits "ssh";
        user.signingkey = mkIf cfg.signCommits cfg.signingKey;
        gpg.ssh.allowedSignersFile = mkIf cfg.signCommits "~/.config/git/allowed_signers";
        
        # Essential settings
        pull.rebase = true;
        push = {
          default = "current";
          autoSetupRemote = true;
          followTags = true;
        };
        
        fetch = {
          prune = true;
          pruneTags = true;
          parallel = 3;
          writeCommitGraph = true;
        };
        
        merge = {
          conflictStyle = "diff3";
          tool = "${cfg.editor}diff";
          stat = true;
        };
        
        rebase = {
          autoStash = true;
          autoSquash = true;
          abbreviateCommands = true;
          updateRefs = true;
        };
        
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWs = "allow-indentation-change";
          mnemonicPrefix = true;
          renames = "copies";
        };
        
        status = {
          showUntrackedFiles = "all";
          submoduleSummary = true;
          showStash = true;
        };
        
        log = {
          date = "relative";
          abbrevCommit = true;
          follow = true;
          decorate = true;
        };
        
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        
        help.autocorrect = 10;
        
        color = {
          ui = "auto";
          branch = "auto";
          diff = "auto";
          interactive = "auto";
          status = "auto";
        };
        
        # Worktree settings
        worktree.guessRemote = true;
        
        # GitHub CLI credential helper
        credential."https://github.com".helper = 
          "!${pkgs.gh}/bin/gh auth git-credential";
        
        # URL rewrites for SSH
        url."ssh://git@github.com/".insteadOf = "https://github.com/";
        url."ssh://git@gist.github.com/".insteadOf = "https://gist.github.com/";
      };
      
      ignores = [
        # OS files
        ".DS_Store"
        "Thumbs.db"
        "desktop.ini"
        "._*"
        ".Spotlight-V100"
        ".Trashes"
        
        # Editor files
        "*.swp"
        "*.swo"
        "*~"
        ".idea/"
        ".vscode/"
        "*.sublime-*"
        ".helix/"
        
        # Language/Framework specific
        "node_modules/"
        "*.pyc"
        "__pycache__/"
        "target/"
        "dist/"
        "build/"
        "*.egg-info/"
        "vendor/"
        ".bundle/"
        
        # Environment
        ".env"
        ".env.*"
        "!.env.example"
        
        # Logs
        "*.log"
        "logs/"
        
        # Temporary files
        "*.tmp"
        "*.temp"
        "*.bak"
        "*.backup"
        ".cache/"
        
        # Nix
        "result"
        "result-*"
        
        # AI/Claude
        ".claude/"
        ".claude-code/"
        ".ai/"
      ];
    };
  };
}
