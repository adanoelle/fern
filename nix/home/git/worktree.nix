# git/worktree.nix - Enhanced worktree management for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitWorktree;
  
  # Worktree helper script
  wtScript = pkgs.writeShellScriptBin "wt" ''
    #!/usr/bin/env bash
    set -e

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    # Get the main worktree directory
    get_main_dir() {
      git worktree list 2>/dev/null | head -n1 | awk '{print $1}'
    }

    # Get the worktree base directory (parent of main)
    get_worktree_base() {
      local main_dir=$(get_main_dir)
      if [ -n "$main_dir" ]; then
        echo "$(dirname "$main_dir")"
      else
        echo ""
      fi
    }

    # Check if we're in a git repository
    check_git_repo() {
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "''${RED}Error: Not in a git repository''${NC}"
        exit 1
      fi
    }

    case "$1" in
      new|add)
        check_git_repo
        shift
        branch_name="$1"
        if [ -z "$branch_name" ]; then
          echo -e "''${RED}Error: Branch name required''${NC}"
          echo "Usage: wt new <branch-name> [<commit-ish>]"
          exit 1
        fi
        
        base_dir="${cfg.defaultLocation}"
        if [ "$base_dir" = "auto" ]; then
          base_dir="$(get_worktree_base)"
          if [ -z "$base_dir" ]; then
            base_dir="$(dirname "$(pwd)")"
          fi
        fi
        
        worktree_dir="$base_dir/$branch_name"
        
        # Check if we're creating from an existing branch or a new one
        if git show-ref --verify --quiet "refs/heads/$branch_name"; then
          echo -e "''${BLUE}Creating worktree for existing branch: $branch_name''${NC}"
          git worktree add "$worktree_dir" "$branch_name"
        else
          commit_ish="''${2:-HEAD}"
          echo -e "''${GREEN}Creating new branch and worktree: $branch_name from $commit_ish''${NC}"
          git worktree add -b "$branch_name" "$worktree_dir" "$commit_ish"
        fi
        
        echo -e "''${GREEN}✓ Worktree created at: $worktree_dir''${NC}"
        
        if [ "${toString cfg.autoSwitch}" = "true" ]; then
          echo -e "''${CYAN}Switching to new worktree...''${NC}"
          cd "$worktree_dir"
          exec $SHELL
        fi
        ;;
        
      list|ls)
        check_git_repo
        echo -e "''${BLUE}Git Worktrees:''${NC}"
        git worktree list | while IFS= read -r line; do
          dir=$(echo "$line" | awk '{print $1}')
          sha=$(echo "$line" | awk '{print $2}')
          branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
          
          # Check if we're currently in this worktree
          if [ "$PWD" = "$dir" ] || [[ "$PWD" == "$dir"/* ]]; then
            echo -e "''${GREEN}→''${NC} ''${GREEN}$branch''${NC} at $dir ''${CYAN}(current)''${NC}"
          else
            echo -e "  ''${YELLOW}$branch''${NC} at $dir"
          fi
        done
        ;;
        
      switch|sw)
        check_git_repo
        shift
        target="$1"
        if [ -z "$target" ]; then
          # Interactive selection using fzf if available
          if command -v fzf > /dev/null 2>&1; then
            target=$(git worktree list | fzf --ansi --header="Select worktree" --preview 'echo {}' | awk '{print $1}')
            if [ -z "$target" ]; then
              echo "No worktree selected"
              exit 0
            fi
          else
            echo -e "''${RED}Error: Branch name or path required''${NC}"
            echo "Usage: wt switch <branch-name-or-path>"
            echo "Install fzf for interactive selection"
            exit 1
          fi
        fi
        
        # Find worktree by branch name or path
        if [ -d "$target" ]; then
          worktree_dir="$target"
        else
          worktree_dir=$(git worktree list | grep -E "\\[$target\\]" | awk '{print $1}' | head -n1)
        fi
        
        if [ -z "$worktree_dir" ] || [ ! -d "$worktree_dir" ]; then
          echo -e "''${RED}Error: Worktree not found for: $target''${NC}"
          exit 1
        fi
        
        echo -e "''${BLUE}Switching to worktree: $worktree_dir''${NC}"
        cd "$worktree_dir"
        exec $SHELL
        ;;
        
      remove|rm)
        check_git_repo
        shift
        target="$1"
        if [ -z "$target" ]; then
          echo -e "''${RED}Error: Branch name or path required''${NC}"
          echo "Usage: wt remove <branch-name-or-path>"
          exit 1
        fi
        
        # Find worktree by branch name or path
        if [ -d "$target" ]; then
          worktree_dir="$target"
        else
          worktree_dir=$(git worktree list | grep -E "\\[$target\\]" | awk '{print $1}' | head -n1)
        fi
        
        if [ -z "$worktree_dir" ]; then
          echo -e "''${RED}Error: Worktree not found for: $target''${NC}"
          exit 1
        fi
        
        echo -e "''${YELLOW}Removing worktree: $worktree_dir''${NC}"
        git worktree remove "$worktree_dir"
        echo -e "''${GREEN}✓ Worktree removed''${NC}"
        ;;
        
      clean|prune)
        check_git_repo
        echo -e "''${YELLOW}Pruning worktree administrative files...''${NC}"
        git worktree prune
        echo -e "''${GREEN}✓ Worktrees pruned''${NC}"
        ;;
        
      pr)
        check_git_repo
        shift
        pr_number="$1"
        if [ -z "$pr_number" ]; then
          echo -e "''${RED}Error: PR number required''${NC}"
          echo "Usage: wt pr <pr-number>"
          exit 1
        fi
        
        branch_name="pr-$pr_number"
        base_dir="${cfg.defaultLocation}"
        if [ "$base_dir" = "auto" ]; then
          base_dir="$(get_worktree_base)"
          if [ -z "$base_dir" ]; then
            base_dir="$(dirname "$(pwd)")"
          fi
        fi
        
        worktree_dir="$base_dir/$branch_name"
        
        echo -e "''${BLUE}Fetching PR #$pr_number...''${NC}"
        gh pr checkout "$pr_number" --detach || {
          echo -e "''${RED}Failed to fetch PR #$pr_number''${NC}"
          exit 1
        }
        
        echo -e "''${GREEN}Creating worktree for PR #$pr_number...''${NC}"
        git worktree add "$worktree_dir" HEAD
        
        if [ "${toString cfg.autoSwitch}" = "true" ]; then
          echo -e "''${CYAN}Switching to PR worktree...''${NC}"
          cd "$worktree_dir"
          exec $SHELL
        else
          echo -e "''${GREEN}✓ PR worktree created at: $worktree_dir''${NC}"
        fi
        ;;
        
      status|st)
        check_git_repo
        echo -e "''${BLUE}Worktree Status Overview:''${NC}"
        echo ""
        
        git worktree list | while IFS= read -r line; do
          worktree=$(echo "$line" | awk '{print $1}')
          sha=$(echo "$line" | awk '{print $2}')
          branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
          
          # Get status for this worktree
          pushd "$worktree" > /dev/null 2>&1
          
          # Count changes
          staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
          modified=$(git diff --numstat 2>/dev/null | wc -l)
          untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
          
          # Branch status vs upstream
          ahead_behind=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0	0")
          ahead=$(echo "$ahead_behind" | cut -f1)
          behind=$(echo "$ahead_behind" | cut -f2)
          
          popd > /dev/null 2>&1
          
          # Format output
          if [ "$PWD" = "$worktree" ] || [[ "$PWD" == "$worktree"/* ]]; then
            echo -ne "''${GREEN}→''${NC} "
          else
            echo -n "  "
          fi
          
          printf "''${YELLOW}%-20s''${NC} " "$branch"
          
          if [ "$staged" -gt 0 ] || [ "$modified" -gt 0 ] || [ "$untracked" -gt 0 ]; then
            printf "''${RED}●''${NC} "
          else
            printf "''${GREEN}✓''${NC} "
          fi
          
          [ "$staged" -gt 0 ] && printf "''${GREEN}+$staged''${NC} "
          [ "$modified" -gt 0 ] && printf "''${YELLOW}~$modified''${NC} "
          [ "$untracked" -gt 0 ] && printf "''${RED}?$untracked''${NC} "
          
          if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
            printf "("
            [ "$ahead" -gt 0 ] && printf "↑$ahead"
            [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ] && printf " "
            [ "$behind" -gt 0 ] && printf "↓$behind"
            printf ")"
          fi
          
          echo " $worktree"
        done
        ;;
        
      help|--help|-h)
        echo "wt - Git Worktree Helper"
        echo ""
        echo "Commands:"
        echo "  new <branch> [commit]  Create new worktree"
        echo "  list                   List all worktrees"
        echo "  switch [branch]        Switch to worktree (interactive with fzf)"
        echo "  remove <branch>        Remove worktree"
        echo "  clean                  Prune worktree administrative files"
        echo "  pr <number>            Create worktree for GitHub PR"
        echo "  status                 Show status of all worktrees"
        echo "  help                   Show this help message"
        echo ""
        echo "Aliases:"
        echo "  add = new"
        echo "  ls = list"
        echo "  sw = switch"
        echo "  rm = remove"
        echo "  st = status"
        echo ""
        echo "Examples:"
        echo "  wt new feature/cool   Create worktree for new feature"
        echo "  wt pr 123            Check out PR #123 in a worktree"
        echo "  wt switch            Interactive worktree selection"
        echo "  wt status            See all worktrees and their status"
        ;;
        
      *)
        if [ -n "$1" ]; then
          echo -e "''${RED}Unknown command: $1''${NC}"
        fi
        echo "Use 'wt help' for usage information"
        exit 1
        ;;
    esac
  '';
in
{
  options.programs.gitWorktree = {
    enable = mkEnableOption "Enhanced Git worktree management";

    defaultLocation = mkOption {
      type = types.str;
      default = "auto";
      example = "~/projects/worktrees";
      description = "Default location for worktrees. 'auto' uses parent of main worktree.";
    };

    autoSwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically switch to new worktree after creation";
    };

    enableHelper = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the 'wt' helper command";
    };

    enablePrompt = mkOption {
      type = types.bool;
      default = true;
      description = "Add worktree info to shell prompt";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf cfg.enableHelper [ wtScript ];

    programs.git.aliases = {
      # Worktree aliases
      wt = "worktree";
      wta = "worktree add";
      wtl = "worktree list";
      wtr = "worktree remove";
      wtp = "worktree prune";
      
      # Worktree utilities
      wt-clean = "!git worktree prune && git remote prune origin";
      
      # Show all worktree statuses
      wt-status = "!git worktree list | while read -r wt; do echo \"=== $wt ===\"; git -C \"$(echo $wt | awk '{print $1}')\" status -sb; echo; done";
      
      # Update all worktrees
      wt-update = "!f() { \
        git fetch --all --prune; \
        for wt in $(git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2); do \
          branch=$(git -C \"$wt\" branch --show-current); \
          if [ -n \"$branch\" ]; then \
            echo \"Updating worktree: $wt ($branch)\"; \
            git -C \"$wt\" pull --rebase --autostash 2>/dev/null || echo \"  → Could not update\"; \
          fi; \
        done; \
      }; f";
    };

    # Shell integration
    programs.bash.initExtra = mkIf cfg.enablePrompt ''
      # Worktree prompt indicator
      __git_worktree_prompt() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local main_worktree=$(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
          if [ -n "$main_worktree" ] && [ "$PWD" != "$main_worktree" ] && [[ "$PWD" != "$main_worktree"/* ]]; then
            local branch=$(git branch --show-current 2>/dev/null || echo "detached")
            echo " [⚡$branch]"
          fi
        fi
      }
      
      # Add to prompt if not already customized
      if [[ ! "$PS1" == *__git_worktree_prompt* ]]; then
        PS1="\$(__git_worktree_prompt)$PS1"
      fi
      
      # Helper functions
      wt_foreach() {
        local cmd="$*"
        for worktree in $(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2); do
          echo "=== Running in: $worktree ==="
          (cd "$worktree" && eval "$cmd")
          echo
        done
      }
      
      wt_status_all() {
        for worktree in $(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2); do
          echo "=== Worktree: $worktree ==="
          (cd "$worktree" && git status -sb)
          echo
        done
      }
    '';
    
    programs.zsh.initExtra = mkIf cfg.enablePrompt ''
      # Worktree prompt indicator
      __git_worktree_prompt() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local main_worktree=$(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
          if [ -n "$main_worktree" ] && [ "$PWD" != "$main_worktree" ] && [[ "$PWD" != "$main_worktree"/* ]]; then
            local branch=$(git branch --show-current 2>/dev/null || echo "detached")
            echo " [⚡$branch]"
          fi
        fi
      }
      
      # Add to prompt if not already customized
      if [[ ! "$PROMPT" == *__git_worktree_prompt* ]]; then
        PROMPT="\$(__git_worktree_prompt)$PROMPT"
      fi
      
      # Helper functions (same as bash)
      wt_foreach() {
        local cmd="$*"
        for worktree in $(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2); do
          echo "=== Running in: $worktree ==="
          (cd "$worktree" && eval "$cmd")
          echo
        done
      }
      
      wt_status_all() {
        for worktree in $(git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2); do
          echo "=== Worktree: $worktree ==="
          (cd "$worktree" && git status -sb)
          echo
        done
      }
    '';

    # Shell aliases
    home.shellAliases = mkIf cfg.enableHelper {
      # Worktree shortcuts
      wtn = "wt new";
      wtl = "wt list";
      wts = "wt switch";
      wtr = "wt remove";
      wtst = "wt status";
      
      # Quick navigation
      cdwt = "cd $(git worktree list 2>/dev/null | fzf --height=20% | awk '{print $1}')";
      cdmain = "cd $(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')";
    };
  };
}
