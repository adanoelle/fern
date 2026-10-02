# modules/git/safety.nix — git safety features via hooks and aliases
_: {
  den.aspects.git-safety.homeManager =
    {
      config,
      lib,
      ...
    }:

    with lib;

    let
      cfg = config.programs.gitSafety;
    in
    {
      options.programs.gitSafety = {
        enable = mkEnableOption "Git safety features";

        protectedBranches = mkOption {
          type = types.listOf types.str;
          default = [
            "main"
            "master"
            "prod"
            "production"
          ];
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
        programs.git.settings.alias = {
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

          # Status checks (moved from shell aliases due to Nushell issues)
          check = "!git status && git diff --stat";
          safe-status = "status --porcelain";
        };

        # Git hooks for safety
        home.file = mkMerge [
          # Pre-push hook for protected branches
          (mkIf cfg.enablePrePushHook {
            ".config/git/hooks/pre-push" = {
              executable = true;
              # git feeds one line per pushed ref on stdin:
              #   <local ref> <local sha> <remote ref> <remote sha>
              # Check the destination (remote ref), not the checked-out
              # branch: `git push origin feature` while on main is not a
              # push to main, and `git push origin HEAD:main` from a
              # feature branch is. With no terminal to ask (agents, CI,
              # GUI clients), refuse instead of failing on /dev/tty.
              text = ''
                #!/usr/bin/env bash

                protected_branches=" ${concatStringsSep " " cfg.protectedBranches} "
                remote_name="$1"

                hits=()
                while read -r _local_ref _local_sha remote_ref _remote_sha; do
                  [ -n "$remote_ref" ] || continue
                  branch="''${remote_ref#refs/heads/}"
                  [ "$branch" != "$remote_ref" ] || continue   # tags, notes, ...
                  case "$protected_branches" in
                    *" $branch "*) hits+=("$branch") ;;
                  esac
                done

                [ ''${#hits[@]} -eq 0 ] && exit 0

                echo "⚠️  Pushing to protected branch(es) on $remote_name: ''${hits[*]}"
                if ! { : </dev/tty; } 2>/dev/null; then
                  echo "   No terminal to confirm on; push refused."
                  echo "   Push a feature branch and merge a PR, or rerun with --no-verify."
                  exit 1
                fi
                read -p "   Are you sure you want to push? (y/n): " -n 1 -r </dev/tty
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                  echo "Push cancelled."
                  exit 1
                fi
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
        programs.git.settings = {
          core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";

          # Additional safety settings (push.default is in core.nix)
          # push.followTags is already in core.nix

          # Safer merging
          merge.ff = "only"; # Fast-forward only by default

          # Note: rebase, merge.conflictStyle and rerere settings are in core.nix
        };

        # Note: Complex shell aliases removed due to Nushell compatibility issues
        # Use the git aliases instead: git check, git safe-status
      };
    };
}
