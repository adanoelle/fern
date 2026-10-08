# modules/git/github.nix — GitHub CLI integration (no scripts)
_: {
  den.aspects.git-github.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:

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
          type = types.enum [
            "https"
            "ssh"
          ];
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
            inherit (cfg) editor;
            prompt = "enabled";
            pager = "less";
            browser = mkIf (cfg.browser != "") cfg.browser;

            inherit (cfg) aliases;
          };
        };

        # gh rewrites config.yml whenever it saves state (auth login,
        # auth refresh, gh config set), and it saves config.yml before
        # hosts.yml. home-manager links config.yml read-only from the
        # store, so every such save failed with "permission denied" and a
        # refreshed token was silently never written to hosts.yml.
        # Install the same generated settings as an ordinary writable
        # file instead, rewritten on each switch so the declared settings
        # above stay authoritative (a `gh config set` lasts until then).
        # hosts.yml (the token) is untouched.
        xdg.configFile."gh/config.yml".enable = lib.mkForce false;
        home.activation.ghWritableConfig =
          let
            generated = (pkgs.formats.yaml { }).generate "gh-config.yml" (
              { version = "1"; } // config.programs.gh.settings
            );
            target = "${config.xdg.configHome}/gh/config.yml";
          in
          lib.hm.dag.entryAfter [ "linkGeneration" ] ''
            if [ -L "${target}" ] || ! ${pkgs.diffutils}/bin/cmp -s "${generated}" "${target}"; then
              run rm -f "${target}"
              run install -D -m 600 "${generated}" "${target}"
            fi
          '';

        # Git configuration for GitHub
        # Note: The gh module already sets up credential helpers, so we don't need to duplicate

        # Git aliases for GitHub integration (no scripts!)
        programs.git.settings.alias = {
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
    };
}
