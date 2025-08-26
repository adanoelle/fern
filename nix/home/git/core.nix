# git/core.nix - Core Git configuration (script-free)
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
      default = pkgs.git;
      description = "Git package to use";
    };

    userName = mkOption {
      type = types.str;
      default = "adanoelle";
      description = "Default git user name";
    };

    userEmail = mkOption {
      type = types.str;
      default = "adanoelleyoung@gmail.com";
      description = "Default git user email";
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
      default = "";
      description = "SSH key to use for signing (defaults to \${HOME}/.ssh/github if not set)";
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
    # Don't add to home.packages - programs.git handles it
    
    programs.git = {
      enable = true;
      package = cfg.package;
      
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      
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
          
          # Performance optimizations (no fsmonitor - Linux incompatible)
          preloadIndex = true;
          multiPackIndex = true;
          commitGraph = true;
          untrackedCache = true;
          # fsmonitor = false; # Explicitly disabled for Linux
        };
        
        # SSH signing configuration
        commit.gpgsign = cfg.signCommits;
        gpg.format = mkIf cfg.signCommits "ssh";
        user.signingkey = mkIf cfg.signCommits (
          if cfg.signingKey != "" then cfg.signingKey
          else "${config.home.homeDirectory}/.ssh/github"
        );
        gpg.ssh.allowedSignersFile = mkIf cfg.signCommits "${config.home.homeDirectory}/.config/git/allowed_signers";
        
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
        
        # Performance
        pack.threads = 0; # Use all CPU cores
        gc.auto = 256; # Auto gc threshold
        
        # Worktree settings
        worktree.guessRemote = true;
        
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
      ];
    };
  };
}
