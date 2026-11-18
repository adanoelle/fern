# modules/git/aliases.nix — git aliases configuration
_: {
  den.aspects.git-aliases.homeManager =
    {
      config,
      lib,
      ...
    }:

    with lib;

    let
      cfg = config.programs.gitAliases;
    in
    {
      options.programs.gitAliases = {
        enable = mkEnableOption "Git aliases configuration";

        enableShellAliases = mkOption {
          type = types.bool;
          default = true;
          description = "Enable shell aliases for common git commands";
        };

        custom = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Custom user-defined git aliases";
        };
      };

      config = mkIf cfg.enable {
        # Git aliases - pure git functionality
        programs.git.settings.alias = {
          # --- Status and Info
          s = "status -sb";
          ss = "status";

          # --- Adding/Staging
          a = "add";
          aa = "add -A";
          ap = "add -p"; # Interactive staging
          au = "add -u"; # Stage modified files only

          # --- Committing
          c = "commit";
          cm = "commit -m";
          fixup = "commit --fixup";

          # ---Branches
          b = "branch -vv";
          ba = "branch -a";
          bd = "branch -d";
          co = "checkout";
          cob = "checkout -b";
          com = "checkout main";
          wip = "!git add -A && git commit -m 'WIP'";

          # --- Diff
          d = "diff";
          dc = "diff --cached";
          dh = "diff HEAD";

          # --- Logs
          l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          ll = "log --graph --oneline --decorate --all";
          last = "log -1 HEAD --stat";
          # A shell alias (!): a plain alias does not expand $(...), so the
          # author filter was the literal text and matched nothing.
          today = "!git log --since=midnight --author=\"$(git config user.name)\" --oneline";

          # --- Push/Pull/Fetch
          p = "push";
          pf = "push --force-with-lease"; # Safer force push
          pu = "push -u origin HEAD";
          pl = "pull";
          plr = "pull --rebase";
          f = "fetch";
          fa = "fetch --all";

          # --- Stash
          st = "stash";
          stp = "stash pop";
          stl = "stash list";
          std = "stash drop";

          # undo, uncommit, unstage and amend live in safety.nix.

          # --- Worktrees (no scripts!)
          wta = "worktree add";
          wtl = "worktree list";
          wtr = "worktree remove";
          wtp = "worktree prune";
          # Create new worktree with branch
          wt-new = "!f() { git worktree add ../$1 -b $1; }; f";

          # --- Identity (no scripts!)
          whoami = "!echo \"$(git config user.name) <$(git config user.email)>\"";
          identity = "config --get-regexp '^user\\.'";

          # --- Snapshots (no scripts!)
          snapshot = "!git tag -a \"snapshot-$(date +%Y%m%d-%H%M%S)\" -m 'Snapshot'";
          snapshots = "tag -l 'snapshot-*' --sort=-creatordate";
          last-snapshot = "!git tag -l 'snapshot-*' --sort=-creatordate | head -1";

          # --- Utility
          aliases = "config --get-regexp '^alias\\.'";
          root = "rev-parse --show-toplevel";
          current = "rev-parse --abbrev-ref HEAD";

        }
        // cfg.custom; # Merge in any custom aliases

        # Shell aliases for convenience (if enabled).
        #
        # This is the one definition of the git shortcuts for every
        # shell: home.shellAliases reaches fish, zsh, bash and Nushell.
        # fish.nix turns the same entries into abbreviations; do not
        # redefine them per shell.
        home.shellAliases = mkIf cfg.enableShellAliases {
          # Essential shortcuts
          g = "git status -sb";
          ga = "git add";
          gaa = "git add -A";
          gc = "git commit";
          gcm = "git commit -m";
          gp = "git push";
          gpu = "git push -u origin HEAD";
          gl = "git pull";
          gpl = "git pull";
          gf = "git fetch";
          gd = "git diff";
          gds = "git diff --staged";
          gg = "git log --graph --decorate --oneline --all";
          gst = "git stash";
          gstp = "git stash pop";
          gco = "git checkout";
          gb = "git branch";

          # Identity check
          gid = "git whoami";

          # Worktree shortcuts
          wtn = "git wt-new";
          wtl = "git wtl";

          # Note: gsave removed due to Nushell command parsing issues
          # Use 'git wip' alias instead
        };
      };
    };
}
