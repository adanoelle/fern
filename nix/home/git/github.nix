# git/github.nix - GitHub CLI integration for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitGithub;
in
{
  options.programs.gitGithub = {
    enable = mkEnableOption "GitHub CLI integration";

    package = mkOption {
      type = types.package;
      default = pkgs.gh;
      description = "GitHub CLI package to use";
    };

    gitProtocol = mkOption {
      type = types.enum [ "https" "ssh" ];
      default = "ssh";
      description = "Protocol to use for git operations";
    };

    editor = mkOption {
      type = types.str;
      default = config.programs.gitCore.editor or "vim";
      description = "Editor for GitHub CLI operations";
    };

    browser = mkOption {
      type = types.str;
      default = "";
      description = "Browser to use for opening web pages (empty for system default)";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        co = "pr checkout";
        pv = "pr view --web";
      };
      description = "GitHub CLI aliases";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "GitHub CLI extensions to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ cfg.extensions;

    # GitHub CLI configuration
    programs.gh = {
      enable = true;
      
      settings = {
        git_protocol = cfg.gitProtocol;
        editor = cfg.editor;
        prompt = "enabled";
        pager = config.programs.gitCore.pager or "less";
        browser = mkIf (cfg.browser != "") cfg.browser;
        
        aliases = cfg.aliases;
      };
    };

    # Git configuration for GitHub
    programs.git.extraConfig = {
      # GitHub CLI as credential helper
      credential."https://github.com" = {
        helper = "!${cfg.package}/bin/gh auth git-credential";
      };
      
      credential."https://gist.github.com" = {
        helper = "!${cfg.package}/bin/gh auth git-credential";
      };
      
      # URL rewrites if using SSH
      url = mkIf (cfg.gitProtocol == "ssh") {
        "ssh://git@github.com/".insteadOf = "https://github.com/";
        "ssh://git@gist.github.com/".insteadOf = "https://gist.github.com/";
      };
    };

    # Git aliases for GitHub integration
    programs.git.aliases = {
      # Pull request workflows
      pr = "!gh pr";
      pr-create = "!gh pr create";
      pr-list = "!gh pr list";
      pr-checkout = "!gh pr checkout";
      pr-view = "!gh pr view";
      pr-status = "!gh pr status";
      
      # Issue workflows
      issue = "!gh issue";
      issue-create = "!gh issue create";
      issue-list = "!gh issue list";
      issue-view = "!gh issue view";
      
      # Repository operations
      repo = "!gh repo";
      repo-clone = "!gh repo clone";
      repo-fork = "!gh repo fork";
      repo-view = "!gh repo view --web";
      
      # Workflow runs
      run = "!gh run";
      run-list = "!gh run list";
      run-view = "!gh run view";
      run-watch = "!gh run watch";
      
      # Advanced PR workflows
      review = "!f() { \
        gh pr checkout $1 || exit 1; \
        echo 'PR checked out. Review the changes and run:'; \
        echo '  gh pr review --approve'; \
        echo '  gh pr review --comment'; \
        echo '  gh pr review --request-changes'; \
      }; f";
      
      pr-clean = "!git for-each-ref refs/heads/pr-* refs/heads/pull/* --format='%(refname:short)' | xargs -r -n 1 git branch -D";
      
      # Create PR from current branch
      pr-here = "!gh pr create --fill";
      
      # Quick PR approval
      approve = "!gh pr review --approve";
      
      # Check CI status
      ci = "!gh pr checks";
    };

    # Shell functions for GitHub workflows
    programs.bash.initExtra = ''
      # Create PR with automatic title from branch name
      ghpr() {
        local branch=$(git branch --show-current)
        local title=$(echo "$branch" | sed 's/[-_]/ /g' | sed 's/\b\(.\)/\u\1/g')
        gh pr create --title "$title" --body "" "$@"
      }
      
      # Quick issue creation
      ghissue() {
        gh issue create "$@"
      }
      
      # Clone and cd into a repo
      ghclone() {
        gh repo clone "$1" && cd "$(basename "$1" .git)"
      }
      
      # View PR in browser
      ghweb() {
        gh pr view --web "$@" 2>/dev/null || gh repo view --web "$@"
      }
      
      # List my PRs across all repos
      my-prs() {
        gh pr list --author="@me" --state=open --limit=20
      }
      
      # List PRs needing my review
      my-reviews() {
        gh pr list --reviewer="@me" --state=open --limit=20
      }
      
      # Create a worktree for a GitHub issue
      wt-issue() {
        local issue_number=$1
        if [ -z "$issue_number" ]; then
          echo "Usage: wt-issue <issue-number>"
          return 1
        fi
        
        local branch_name="issue-$issue_number"
        wt new "$branch_name"
        
        # Add issue reference to commit template
        echo "Fixes #$issue_number" > .git/worktrees/$branch_name/commit-template
        git config --local commit.template .git/worktrees/$branch_name/commit-template
        
        # Comment on the issue
        gh issue comment "$issue_number" -b "Working on this in branch: $branch_name"
      }
      
      # Create worktree for all open PRs (useful for batch reviews)
      wt-all-prs() {
        gh pr list --json number,headRefName --limit=10 | \
        jq -r '.[] | "\(.number) \(.headRefName)"' | \
        while read -r number branch; do
          echo "Creating worktree for PR #$number (branch: $branch)"
          wt pr "$number" 2>/dev/null || echo "  → Already exists or failed"
        done
      }
    '';
    
    programs.zsh.initExtra = programs.bash.initExtra;

    # Shell aliases
    home.shellAliases = {
      # GitHub CLI shortcuts
      ghpr = "gh pr";
      ghprc = "gh pr create";
      ghprl = "gh pr list";
      ghprv = "gh pr view";
      ghprs = "gh pr status";
      
      ghissue = "gh issue";
      ghissuec = "gh issue create";
      ghissuel = "gh issue list";
      
      ghrepo = "gh repo";
      ghrepov = "gh repo view --web";
      
      # Quick actions
      ghweb = "gh repo view --web";
      ghci = "gh pr checks";
      ghapprove = "gh pr review --approve";
      
      # Compound workflows
      prweb = "gh pr view --web";
      prnew = "gh pr create --fill";
    };

    # Create GitHub CLI extension directory
    home.file.".config/gh/extensions/.keep" = {
      text = "";
    };
  };
}
