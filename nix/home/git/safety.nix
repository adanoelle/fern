# git/safety.nix - Git safety features via hooks and aliases
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitSafety;
in
{
  options.programs.gitSafety = {
    enable = mkEnableOption "Git safety features";

    protectedBranches = mkOption {
      type = types.listOf types.str;
      default = [ "main" "master" "prod" "production" ];
      description = "Branches that require confirmation before push";
    };

    enablePrePushHook = mkOption {
      type = types.bool;
      default = true;
      description = "Enable pre-push hook for protected branches";
    };

    enableCommitMsgHook = mkOption {
      type = types.bool;
      default = false;
      description = "Enable commit message validation";
    };
  };

  config = mkIf cfg.enable {
    # Safety-oriented git aliases
    programs.git.aliases = {
      # Safe force push
      pushf = "push --force-with-lease";
      pushforce = "push --force-with-lease";
      
      # Undo helpers (safe)
      undo = "reset --soft HEAD~1";
      uncommit = "reset HEAD~1";
      unstage = "reset HEAD --";
      discard = "checkout --";
      
      # Stash helpers
      save = "stash push -m";
      pop = "stash pop";
      
      # Safe operations
      amend = "commit --amend --no-edit";
      amendmsg = "commit --amend";
      
      # Cleanup
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 -r git branch -d";
      prune-branches = "!git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -n 1 -r git branch -d";
    };

    # Git hooks for safety
    home.file = mkMerge [
      # Pre-push hook for protected branches
      (mkIf cfg.enablePrePushHook {
        ".config/git/hooks/pre-push" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            
            protected_branches="${concatStringsSep " " cfg.protectedBranches}"
            current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
            
            for branch in $protected_branches; do
              if [ "$branch" = "$current_branch" ]; then
                echo "⚠️  You're pushing to protected branch: $current_branch"
                echo "   This branch is typically protected in production."
                read -p "   Are you sure you want to push? (y/n): " -n 1 -r < /dev/tty
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                  echo "Push cancelled."
                  exit 1
                fi
              fi
            done
            
            exit 0
          '';
        };
      })
      
      # Commit message hook (optional)
      (mkIf cfg.enableCommitMsgHook {
        ".config/git/hooks/commit-msg" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            
            # Simple commit message validation
            commit_regex='^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .{1,50}'
            
            if ! grep -qE "$commit_regex" "$1"; then
              echo "❌ Invalid commit message format!"
              echo ""
              echo "Valid format: <type>(<scope>): <subject>"
              echo ""
              echo "Types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert"
              echo ""
              echo "Example: feat(auth): add login functionality"
              echo ""
              exit 1
            fi
          '';
        };
      })
    ];

    # Configure git to use our hooks
    programs.git.extraConfig = {
      core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
      
      # Additional safety settings (push.default is in core.nix)
      # push.followTags is already in core.nix
      
      # Safer merging
      merge.ff = "only";  # Fast-forward only by default
      
      # Note: rebase, merge.conflictStyle and rerere settings are in core.nix
    };

    # Shell aliases for safety - using ; for Nushell compatibility
    home.shellAliases = {
      # Safe alternatives
      "git-clean" = "echo 'Use: git clean -fd (dry run with -n first)'";
      "git-reset-hard" = "echo 'Warning: Use git reset --hard with caution'";
      
      # Quick safety checks - use ; instead of && for Nushell
      "git-check" = "git status; git diff --stat";
      "git-safe" = "git status --porcelain";
    };
  };
}