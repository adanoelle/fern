# git/prompts.nix - Shell prompt enhancements
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitPrompts;
in
{
  options.programs.gitPrompts = {
    enable = mkEnableOption "Git-aware shell prompt enhancements";

    showBranch = mkOption {
      type = types.bool;
      default = true;
      description = "Show current git branch in prompt";
    };

    showDirty = mkOption {
      type = types.bool;
      default = true;
      description = "Show if repository has uncommitted changes";
    };

    showStash = mkOption {
      type = types.bool;
      default = false;
      description = "Show if there are stashed changes";
    };

    showUpstream = mkOption {
      type = types.bool;
      default = false;
      description = "Show commits ahead/behind upstream";
    };

    showWorktree = mkOption {
      type = types.bool;
      default = true;
      description = "Show if in a worktree";
    };

    usePowerline = mkOption {
      type = types.bool;
      default = false;
      description = "Use powerline symbols (requires powerline fonts)";
    };
  };

  config = mkIf cfg.enable {
    # Git prompt functions for bash/zsh
    programs.bash.initExtra = mkIf cfg.showBranch ''
      # Git branch in prompt
      __git_branch() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local branch=$(git branch --show-current 2>/dev/null || echo "detached")
          
          # Check if dirty
          local dirty=""
          ${optionalString cfg.showDirty ''
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
              dirty="*"
            fi
          ''}
          
          # Check if stash exists
          local stash=""
          ${optionalString cfg.showStash ''
            if git rev-parse --verify refs/stash > /dev/null 2>&1; then
              stash="$"
            fi
          ''}
          
          # Check upstream status
          local upstream=""
          ${optionalString cfg.showUpstream ''
            local ahead_behind=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0	0")
            local ahead=$(echo "$ahead_behind" | cut -f1)
            local behind=$(echo "$ahead_behind" | cut -f2)
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
              upstream=" "
              [ "$ahead" -gt 0 ] && upstream="$upstream↑$ahead"
              [ "$behind" -gt 0 ] && upstream="$upstream↓$behind"
            fi
          ''}
          
          # Check if in worktree
          local worktree=""
          ${optionalString cfg.showWorktree ''
            local main_worktree=$(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
            if [ -n "$main_worktree" ] && [ "$PWD" != "$main_worktree" ] && [[ "$PWD" != "$main_worktree"/* ]]; then
              worktree="⚡"
            fi
          ''}
          
          echo " ($worktree$branch$dirty$stash$upstream)"
        fi
      }
      
      # Add to PS1 if not already there
      if [[ ! "$PS1" == *__git_branch* ]]; then
        PS1="\$(__git_branch)$PS1"
      fi
    '';
    
    programs.zsh.initExtra = mkIf cfg.showBranch ''
      # Git branch in prompt
      __git_branch() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local branch=$(git branch --show-current 2>/dev/null || echo "detached")
          
          # Check if dirty
          local dirty=""
          ${optionalString cfg.showDirty ''
            if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
              dirty="*"
            fi
          ''}
          
          # Check if stash exists
          local stash=""
          ${optionalString cfg.showStash ''
            if git rev-parse --verify refs/stash > /dev/null 2>&1; then
              stash="$"
            fi
          ''}
          
          # Check upstream status
          local upstream=""
          ${optionalString cfg.showUpstream ''
            local ahead_behind=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0	0")
            local ahead=$(echo "$ahead_behind" | cut -f1)
            local behind=$(echo "$ahead_behind" | cut -f2)
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
              upstream=" "
              [ "$ahead" -gt 0 ] && upstream="$upstream↑$ahead"
              [ "$behind" -gt 0 ] && upstream="$upstream↓$behind"
            fi
          ''}
          
          # Check if in worktree
          local worktree=""
          ${optionalString cfg.showWorktree ''
            local main_worktree=$(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
            if [ -n "$main_worktree" ] && [ "$PWD" != "$main_worktree" ] && [[ "$PWD" != "$main_worktree"/* ]]; then
              worktree="⚡"
            fi
          ''}
          
          echo " ($worktree$branch$dirty$stash$upstream)"
        fi
      }
      
      # Add to PROMPT if not already there
      if [[ ! "$PROMPT" == *__git_branch* ]]; then
        setopt PROMPT_SUBST
        PROMPT="\$(__git_branch)$PROMPT"
      fi
    '';
  };
}
