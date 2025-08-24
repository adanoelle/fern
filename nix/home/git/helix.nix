# git/helix.nix - Helix-specific Git integration
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitHelix;
in
{
  options.programs.gitHelix = {
    enable = mkEnableOption "Helix-specific Git integration";

    editor = mkOption {
      type = types.str;
      default = "hx";
      description = "Helix command";
    };

    enableDifftastic = mkOption {
      type = types.bool;
      default = true;
      description = "Use difftastic for structural diffs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Helix-friendly diff tools
      difftastic
      git-absorb  # Automatically create fixup commits
    ] ++ optional cfg.enableDifftastic difftastic;

    programs.git = {
      aliases = {
        # Helix-specific workflows
        edit-modified = "!${cfg.editor} $(git diff --name-only)";
        edit-conflicts = "!${cfg.editor} $(git diff --name-only --diff-filter=U)";
        edit-staged = "!${cfg.editor} $(git diff --cached --name-only)";
        edit-last = "!${cfg.editor} $(git diff-tree --no-commit-id --name-only -r HEAD)";
        edit-untracked = "!${cfg.editor} $(git ls-files --others --exclude-standard)";
        
        # Quick edits
        em = "edit-modified";
        ec = "edit-conflicts";
        es = "edit-staged";
        el = "edit-last";
        eu = "edit-untracked";
        
        # Helix + diff
        difft = mkIf cfg.enableDifftastic "!GIT_EXTERNAL_DIFF=${pkgs.difftastic}/bin/difft git diff";
        showt = mkIf cfg.enableDifftastic "!GIT_EXTERNAL_DIFF=${pkgs.difftastic}/bin/difft git show";
        logt = mkIf cfg.enableDifftastic "!GIT_EXTERNAL_DIFF=${pkgs.difftastic}/bin/difft git log -p --ext-diff";
        
        # Absorb workflow (great with Helix)
        absorb = "!git-absorb --and-rebase";
        fixup = "commit --fixup";
      };
      
      extraConfig = mkIf cfg.enableDifftastic {
        diff.external = "${pkgs.difftastic}/bin/difft";
        diff.tool = "difftastic";
        difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft \"$LOCAL\" \"$REMOTE\"";
        pager.difftool = true;
      };
    };

    # Shell functions for Helix + Git workflows
    programs.bash.initExtra = ''
      # Open files from git grep in Helix
      hxgrep() {
        local pattern="$1"
        local files=$(git grep -l "$pattern" 2>/dev/null)
        if [ -n "$files" ]; then
          echo "$files" | xargs ${cfg.editor}
        else
          echo "No files found matching: $pattern"
        fi
      }
      
      # Open files changed between branches in Helix
      hxbranch() {
        local branch="''${1:-main}"
        local files=$(git diff --name-only "$branch"...HEAD)
        if [ -n "$files" ]; then
          echo "$files" | xargs ${cfg.editor}
        else
          echo "No files changed compared to $branch"
        fi
      }
      
      # Open files from specific commit in Helix
      hxcommit() {
        local commit="''${1:-HEAD}"
        local files=$(git diff-tree --no-commit-id --name-only -r "$commit")
        if [ -n "$files" ]; then
          echo "$files" | xargs ${cfg.editor}
        else
          echo "No files in commit: $commit"
        fi
      }
      
      # Interactive file selection with fzf (if available) and open in Helix
      hxfzf() {
        if command -v fzf > /dev/null; then
          local files=$(git ls-files | fzf --multi --preview 'bat --style=numbers --color=always {}' || true)
          if [ -n "$files" ]; then
            echo "$files" | xargs ${cfg.editor}
          fi
        else
          echo "fzf not found. Install it for interactive file selection."
        fi
      }
      
      # Open merge conflict files one by one with status
      hxconflicts() {
        local conflicts=$(git diff --name-only --diff-filter=U)
        if [ -z "$conflicts" ]; then
          echo "No merge conflicts found!"
          return 0
        fi
        
        echo "Opening conflict files in Helix..."
        echo "$conflicts" | while read -r file; do
          echo "Editing: $file"
          ${cfg.editor} "$file"
          
          # Check if still conflicted
          if git diff --check "$file" 2>/dev/null | grep -q conflict; then
            echo "  Still has conflicts"
          else
            echo "  ✓ Conflicts resolved"
            git add "$file"
          fi
        done
      }
    '';
    
    programs.zsh.initExtra = programs.bash.initExtra;

    # Shell aliases for quick access
    home.shellAliases = {
      # Quick Helix + Git commands
      hxm = "${cfg.editor} $(git ls-files -m 2>/dev/null)";  # Modified files
      hxc = "${cfg.editor} $(git diff --name-only --diff-filter=U 2>/dev/null)";  # Conflicts
      hxs = "${cfg.editor} $(git diff --cached --name-only 2>/dev/null)";  # Staged files
      hxu = "${cfg.editor} $(git ls-files --others --exclude-standard 2>/dev/null)";  # Untracked
      
      # Git with Helix
      geh = "git edit-modified";
      gec = "git edit-conflicts";
      
      # Difftastic shortcuts
    } // optionalAttrs cfg.enableDifftastic {
      gdt = "git difft";
      gdts = "git difft --staged";
    };

    # Create Helix-specific git config
    home.file.".config/helix/git-integration.toml" = {
      text = ''
        # Helix Git Integration Commands
        # Add these to your Helix config if desired
        
        # Example keybindings for git integration:
        # [keys.normal.space.g]
        # s = ":sh git status -sb"
        # d = ":sh git diff"
        # l = ":sh git log --oneline -10"
        # b = ":sh git blame %{filename}"
        # c = ":sh git commit"
        # p = ":sh git push"
      '';
    };
  };
}
