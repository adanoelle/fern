# git/github.nix - GitHub CLI integration (no scripts)
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
      default = {
        co = "pr checkout";
        pv = "pr view --web";
        prm = "pr list --author @me";
        prr = "pr list --reviewer @me";
      };
      description = "GitHub CLI aliases";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # GitHub CLI configuration
    programs.gh = {
      enable = true;
      
      settings = {
        git_protocol = cfg.gitProtocol;
        editor = cfg.editor;
        prompt = "enabled";
        pager = "less";
        browser = mkIf (cfg.browser != "") cfg.browser;
        
        aliases = cfg.aliases;
      };
    };

    # Git configuration for GitHub
    # Note: The gh module already sets up credential helpers, so we don't need to duplicate

    # Git aliases for GitHub integration (no scripts!)
    programs.git.aliases = {
      # Pull request workflows
      pr-create = "!gh pr create";
      pr-list = "!gh pr list";
      pr-checkout = "!gh pr checkout";
      pr-view = "!gh pr view";
      pr-status = "!gh pr status";
      pr-merge = "!gh pr merge";
      
      # Quick PR operations
      pr-web = "!gh pr view --web";
      pr-checks = "!gh pr checks";
      pr-approve = "!gh pr review --approve";
      pr-comment = "!gh pr review --comment";
      
      # Issue workflows
      issue-create = "!gh issue create";
      issue-list = "!gh issue list";
      issue-view = "!gh issue view";
      
      # Repository operations
      repo-clone = "!gh repo clone";
      repo-fork = "!gh repo fork";
      repo-web = "!gh repo view --web";
      
      # My stuff
      my-prs = "!gh pr list --author @me";
      my-reviews = "!gh pr list --reviewer @me";
      my-issues = "!gh issue list --assignee @me";
    };

    # Shell aliases for convenience
    home.shellAliases = {
      # GitHub shortcuts
      pr = "gh pr";
      prc = "gh pr create";
      prl = "gh pr list";
      prv = "gh pr view";
      prs = "gh pr status";
      prw = "gh pr view --web";
      
      issue = "gh issue";
      issuec = "gh issue create";
      issuel = "gh issue list";
      
      repo = "gh repo";
      repow = "gh repo view --web";
      
      # Quick actions
      ghci = "gh pr checks";
      ghapprove = "gh pr review --approve";
      
      # Personal queries
      myprs = "gh pr list --author @me";
      myreviews = "gh pr list --reviewer @me";
    };
  };
}