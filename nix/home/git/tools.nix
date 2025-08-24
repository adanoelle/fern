# git/tools.nix - Additional git tools for Home Manager
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
      
      package = mkOption {
        type = types.package;
        default = pkgs.lazygit;
        description = "Lazygit package to use";
      };
    };

    tig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tig - Text-mode interface for git";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.tig;
        description = "Tig package to use";
      };
    };

    gitui = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gitui - Fast terminal UI for git";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.gitui;
        description = "Gitui package to use";
      };
    };

    gitAbsorb = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git-absorb - Automatically create fixup commits";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.git-absorb;
        description = "Git-absorb package to use";
      };
    };

    gitSecrets = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable git-secrets - Prevent committing secrets";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.git-secrets;
        description = "Git-secrets package to use";
      };
    };

    gitFilterRepo = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git-filter-repo - Rewrite history";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.git-filter-repo;
        description = "Git-filter-repo package to use";
      };
    };

    gitLfs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git-lfs - Large file storage";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.git-lfs;
        description = "Git-lfs package to use";
      };
    };

    gitCrypt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable git-crypt - Transparent file encryption";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.git-crypt;
        description = "Git-crypt package to use";
      };
    };

    extras = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable extra utilities";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          git-extras     # Extra git commands
          git-recent     # View recent branches
          git-ignore     # Generate .gitignore files
          gitleaks       # Detect secrets in repos
        ];
        description = "Extra git-related packages";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = 
      (optional cfg.lazygit.enable cfg.lazygit.package) ++
      (optional cfg.tig.enable cfg.tig.package) ++
      (optional cfg.gitui.enable cfg.gitui.package) ++
      (optional cfg.gitAbsorb.enable cfg.gitAbsorb.package) ++
      (optional cfg.gitSecrets.enable cfg.gitSecrets.package) ++
      (optional cfg.gitFilterRepo.enable cfg.gitFilterRepo.package) ++
      (optional cfg.gitLfs.enable cfg.gitLfs.package) ++
      (optional cfg.gitCrypt.enable cfg.gitCrypt.package) ++
      (optionals cfg.extras.enable cfg.extras.packages);

    # Lazygit configuration
    programs.lazygit = mkIf cfg.lazygit.enable {
      enable = true;
      settings = {
        gui = {
          theme = {
            selectedLineBgColor = ["reverse"];
            selectedRangeBgColor = ["reverse"];
          };
          showFileTree = true;
          showRandomTip = false;
          showCommandLog = true;
          nerdFontsVersion = "3";
        };
        
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --paging=never";
          };
          commit = {
            signOff = false;
          };
        };
        
        os = {
          editCommand = config.programs.gitCore.editor or "vim";
          openCommand = "open";
        };
        
        keybinding = {
          universal = {
            quit = "q";
            quit-alt1 = "<c-c>";
            return = "<esc>";
            togglePanel = "<tab>";
            nextTab = "]";
            prevTab = "[";
          };
        };
      };
    };

    # Git configuration for tools
    programs.git.extraConfig = mkMerge [
      # Git LFS configuration
      (mkIf cfg.gitLfs.enable {
        filter.lfs = {
          clean = "${cfg.gitLfs.package}/bin/git-lfs clean -- %f";
          smudge = "${cfg.gitLfs.package}/bin/git-lfs smudge -- %f";
          process = "${cfg.gitLfs.package}/bin/git-lfs filter-process";
          required = true;
        };
      })
      
      # Git secrets configuration
      (mkIf cfg.gitSecrets.enable {
        init.templateDir = "~/.config/git/templates";
        secrets = {
          providers = "git secrets --aws-provider";
          patterns = [
            "(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}"
            "(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)(\"|')?\\s*[:=]\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?"
            "(\"|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?(\"|')?\\s*[:=]\\s*(\"|')?[0-9]{12}(\"|')?"
          ];
        };
      })
    ];

    # Git aliases for tools
    programs.git.aliases = mkMerge [
      (mkIf cfg.lazygit.enable {
        lg = "!lazygit";
        lazy = "!lazygit";
      })
      
      (mkIf cfg.tig.enable {
        t = "!tig";
        ts = "!tig status";
        tb = "!tig blame";
        tl = "!tig log";
        tr = "!tig refs";
      })
      
      (mkIf cfg.gitui.enable {
        ui = "!gitui";
      })
      
      (mkIf cfg.gitAbsorb.enable {
        absorb = "!git-absorb --and-rebase";
        abs = "!git-absorb --and-rebase";
      })
    ];

    # Shell aliases for tools
    home.shellAliases = mkMerge [
      (mkIf cfg.lazygit.enable {
        lg = "lazygit";
        lazy = "lazygit";
      })
      
      (mkIf cfg.tig.enable {
        tig = "tig";
      })
      
      (mkIf cfg.gitui.enable {
        gitui = "gitui";
      })
    ];

    # Tool-specific configurations
    home.file = mkMerge [
      # Tig configuration
      (mkIf cfg.tig.enable {
        ".config/tig/config" = {
          text = ''
            # Tig configuration
            set diff-options = -p
            set main-view-date = custom
            set main-view-date-format = "%Y-%m-%d %H:%M"
            set blame-view-date = custom
            set blame-view-date-format = "%Y-%m-%d"
            set show-changes = yes
            set wrap-lines = no
            set tab-size = 4
            set line-graphics = utf-8
            set truncation-delimiter = ~
            
            # Key bindings
            bind generic g none
            bind generic gg move-first-line
            bind generic G move-last-line
            bind main B !git rebase -i %(commit)
            bind main F !git fetch
            bind main P !git pull --rebase
            bind main M !git merge %(branch)
            bind status P !git push
            bind status F !git fetch
            
            # Colors
            color cursor white black bold
            color title-focus white blue bold
            color title-blur white black
            color diff-stat yellow default
            color date cyan default
            color author green default
          '';
        };
      })
      
      # Git secrets templates
      (mkIf cfg.gitSecrets.enable {
        ".config/git/templates/hooks/pre-commit" = {
          text = ''
            #!/usr/bin/env bash
            ${cfg.gitSecrets.package}/bin/git-secrets --pre_commit_hook -- "$@"
          '';
          executable = true;
        };
        
        ".config/git/templates/hooks/prepare-commit-msg" = {
          text = ''
            #!/usr/bin/env bash
            ${cfg.gitSecrets.package}/bin/git-secrets --prepare_commit_msg_hook -- "$@"
          '';
          executable = true;
        };
        
        ".config/git/templates/hooks/commit-msg" = {
          text = ''
            #!/usr/bin/env bash
            ${cfg.gitSecrets.package}/bin/git-secrets --commit_msg_hook -- "$@"
          '';
          executable = true;
        };
      })
    ];

    # Initialize git-secrets for existing repos
    home.activation = mkIf cfg.gitSecrets.enable {
      gitSecretsInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -d "$HOME/personal" ] || [ -d "$HOME/src/work" ]; then
          echo "Initializing git-secrets for existing repositories..."
          for dir in "$HOME/personal" "$HOME/src/work"; do
            if [ -d "$dir" ]; then
              find "$dir" -type d -name .git -not -path "*/worktrees/*" | while read -r gitdir; do
                repo_dir=$(dirname "$gitdir")
                if [ ! -f "$gitdir/hooks/pre-commit" ]; then
                  echo "  Setting up git-secrets in $repo_dir"
                  (cd "$repo_dir" && ${cfg.gitSecrets.package}/bin/git-secrets --install --force 2>/dev/null)
                fi
              done
            fi
          done
        fi
      '';
    };
  };
}
