# git/aliases.nix
#
# Aliases built right into git
{ config, lib, pkgs, ... }:

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
      default = {};
      description = "Custom user-defined git aliases";
    };
  };

  config = mkIf cfg.enable {
    # Git aliases - pure git functionality
    programs.git.aliases = {
      # --- Status and Info
      s = "status -sb";
      ss = "status";
      
      # --- Adding/Staging
      a = "add";
      aa = "add -A";
      ap = "add -p";  # Interactive staging
      au = "add -u";  # Stage modified files only
      
      # --- Committing
      c = "commit";
      cm = "commit -m";
      amend = "commit --amend --no-edit";
      fixup = "commit --fixup";
      
      # ---Branches
      b = "branch -vv";
      ba = "branch -a";
      bd = "branch -d";
      co = "checkout";
      cob = "checkout -b";
      com = "checkout main";
      
      # --- Diff 
      d = "diff";
      dc = "diff --cached";
      dh = "diff HEAD";
      
      # --- Logs
      l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --graph --oneline --decorate --all";
      last = "log -1 HEAD --stat";
      today = "log --since=midnight --author='$(git config user.name)' --oneline";
      
      # --- Push/Pull/Fetch 
      p = "push";
      pf = "push --force-with-lease";  # Safer force push
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
      
      # --- Reset/Undo
      undo = "reset --soft HEAD~1";
      uncommit = "reset HEAD~1";
      unstage = "reset HEAD --";
      
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
      
    } // cfg.custom;  # Merge in any custom aliases

    # Shell aliases for convenience (if enabled)
    home.shellAliases = mkIf cfg.enableShellAliases {
      # Essential shortcuts
      g = "git status";
      ga = "git add";
      gaa = "git add -A";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpu = "git push -u origin HEAD";
      gpl = "git pull";
      gf = "git fetch";
      gl = "git log --oneline";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      
      # Identity check
      gid = "git whoami";
      
      # Worktree shortcuts
      wtn = "git wt-new";
      wtl = "git wtl";
      
      # Quick save
      gsave = "git add -A && git commit -m 'WIP'";
    };
  };
}
