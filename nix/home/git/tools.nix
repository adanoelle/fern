# git/tools.nix - Additional git tools (no scripts)
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitTools;
in
{
  options.programs.gitTools = {
    enable = mkEnableOption "Additional Git tools";

    lazygit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable lazygit - Terminal UI for git";
      };
    };

    tig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tig - Text-mode interface for git";
      };
    };

    gitAbsorb = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git-absorb - Automatically create fixup commits";
      };
    };

    gitFilterRepo = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable git-filter-repo - Rewrite history";
      };
    };

    gitLfs = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable git-lfs - Large file storage";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install selected tools
    home.packages = with pkgs;
      (optional cfg.lazygit.enable lazygit) ++
      (optional cfg.tig.enable tig) ++
      (optional cfg.gitAbsorb.enable git-absorb) ++
      (optional cfg.gitFilterRepo.enable git-filter-repo) ++
      (optional cfg.gitLfs.enable git-lfs);

    # LazyGit configuration (if enabled)
    programs.lazygit = mkIf cfg.lazygit.enable {
      enable = true;
      settings = {
        gui = {
          theme = "auto";
          showFileTree = true;
          showCommandLog = false;
          showRandomTip = false;
        };
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --paging=never";
          };
        };
        keybinding = {
          universal = {
            quit = "q";
            quit-alt1 = "<c-c>";
            return = "<esc>";
            togglePanel = "<tab>";
            prevItem = "<up>";
            nextItem = "<down>";
          };
        };
      };
    };

    # Git configuration for LFS
    programs.git.extraConfig = mkIf cfg.gitLfs.enable {
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };

    # Git aliases for tools
    programs.git.aliases = mkMerge [
      # LazyGit
      (mkIf cfg.lazygit.enable {
        lg = "!lazygit";
        visual = "!lazygit";
      })
      
      # Tig
      (mkIf cfg.tig.enable {
        t = "!tig";
        ta = "!tig --all";
        ts = "!tig status";
        tb = "!tig blame";
      })
      
      # Git absorb
      (mkIf cfg.gitAbsorb.enable {
        absorb = "!git-absorb";
        fix = "!git-absorb --and-rebase";
      })
    ];

    # Shell aliases
    home.shellAliases = mkMerge [
      (mkIf cfg.lazygit.enable {
        lg = "lazygit";
        lgs = "lazygit status";
        lgf = "lazygit log";
      })
      
      (mkIf cfg.tig.enable {
        tig = "tig";
        tiga = "tig --all";
        tigs = "tig status";
      })
      
      (mkIf cfg.gitAbsorb.enable {
        absorb = "git absorb";
        gafix = "git absorb --and-rebase";
      })
    ];
  };
}