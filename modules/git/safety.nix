# modules/git/safety.nix — git safety features via hooks and aliases
#
# Hooks live in one user-level directory (core.hooksPath), so they apply
# to every repository on every machine, NixOS or not:
#
#   pre-commit  scans the staged changes for credentials (gitleaks)
#   pre-push    asks before pushing to a protected branch
#   commit-msg  optional conventional-commit check
#
# Setting core.hooksPath makes git ignore each repository's own
# .git/hooks. So every hook here ends by running the repository's hook
# of the same name, and pass-through shims do the same for the hook
# names this module does not otherwise use. Project tooling (pre-commit,
# git-lfs, hand-written hooks) keeps working. A repository that sets its
# own core.hooksPath (husky does) overrides the global one entirely and
# these hooks do not run there.
_: {
  den.aspects.git-safety.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    with lib;

    let
      cfg = config.programs.gitSafety;

      # Hand over to the repository's own hook, if it has one. Hooks live
      # in the common git dir, which linked worktrees share.
      runRepoHook = name: ''
        repo_hook="$(git rev-parse --git-common-dir 2>/dev/null)/hooks/${name}"
        if [ -x "$repo_hook" ]; then
          exec "$repo_hook" "$@"
        fi
      '';

      # Client-side hooks this module has no logic for. Left out on
      # purpose: reference-transaction (runs on every ref update) and the
      # fsmonitor / p4 hooks.
      passThroughHooks = [
        "applypatch-msg"
        "pre-applypatch"
        "post-applypatch"
        "pre-merge-commit"
        "prepare-commit-msg"
        "post-commit"
        "pre-rebase"
        "post-checkout"
        "post-merge"
        "post-rewrite"
        "pre-auto-gc"
        "sendemail-validate"
      ]
      ++ optional (!cfg.enableSecretScanHook) "pre-commit"
      ++ optional (!cfg.enablePrePushHook) "pre-push"
      ++ optional (!cfg.enableCommitMsgHook) "commit-msg";
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

        enableSecretScanHook = mkOption {
          type = types.bool;
          default = true;
          description = "Scan staged changes for credentials before each commit";
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

        # gitleaks on PATH too, for scanning by hand
        # (`gitleaks git` for history, `gitleaks dir` for files).
        home.packages = mkIf cfg.enableSecretScanHook [ pkgs.gitleaks ];

        # Git hooks for safety
        home.file = mkMerge [
          # Pre-commit hook: refuse a commit whose staged changes contain
          # something that looks like a credential. gitleaks reads a
          # repository's .gitleaks.toml and .gitleaksignore by itself.
          (mkIf cfg.enableSecretScanHook {
            ".config/git/hooks/pre-commit" = {
              executable = true;
              text = ''
                #!/usr/bin/env bash

                if ! ${pkgs.gitleaks}/bin/gitleaks git --pre-commit --staged \
                  --redact --verbose --no-banner --log-level warn; then
                  echo "Commit refused: the staged changes look like they contain a secret."
                  echo "  Remove it, or if it is a false positive:"
                  echo "    - add '# gitleaks:allow' at the end of that line, or"
                  echo "    - add the Fingerprint above to .gitleaksignore in the repository"
                  echo "  To skip the scan for this commit only: git commit --no-verify"
                  exit 1
                fi

                ${runRepoHook "pre-commit"}
              '';
            };
          })

          # Pass-through shims, so repository hooks this module has no
          # logic for still run despite core.hooksPath.
          (genAttrs (map (name: ".config/git/hooks/${name}") passThroughHooks) (path: {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              ${runRepoHook (baseNameOf path)}
            '';
          }))

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

                # Keep stdin: the repository's own pre-push hook needs it too.
                refs="$(cat)"
                run_repo_hook() {
                  repo_hook="$(git rev-parse --git-common-dir 2>/dev/null)/hooks/pre-push"
                  if [ -x "$repo_hook" ]; then
                    printf '%s' "''${refs:+$refs$'\n'}" | "$repo_hook" "$@"
                    exit $?
                  fi
                  exit 0
                }

                hits=()
                while read -r _local_ref _local_sha remote_ref _remote_sha; do
                  [ -n "$remote_ref" ] || continue
                  branch="''${remote_ref#refs/heads/}"
                  [ "$branch" != "$remote_ref" ] || continue   # tags, notes, ...
                  case "$protected_branches" in
                    *" $branch "*) hits+=("$branch") ;;
                  esac
                done <<< "$refs"

                [ ''${#hits[@]} -eq 0 ] && run_repo_hook "$@"

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
                run_repo_hook "$@"
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

                ${runRepoHook "commit-msg"}
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
