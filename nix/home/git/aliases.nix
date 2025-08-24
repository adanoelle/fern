# git/aliases.nix - Comprehensive git aliases for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitAliases;
in
{
  options.programs.gitAliases = {
    enable = mkEnableOption "Git aliases configuration";

    custom = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom user-defined git aliases";
    };
  };

  config = mkIf cfg.enable {
    programs.git.aliases = {
      # ============ Status and Info ============
      s = "status -sb";
      ss = "status";
      # st = "status"; # Removed - conflicts with stash
      
      # ============ Adding/Staging ============
      a = "add";
      aa = "add -A";
      ap = "add -p";
      ai = "add -i";
      au = "add -u";
      
      # ============ Committing ============
      c = "commit";
      cm = "commit -m";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cane = "commit --amend --no-edit";
      cf = "commit --fixup";
      cs = "commit --squash";
      cv = "commit -v";
      
      # Quick commit types (conventional commits)
      feat = "commit -m 'feat: '";
      fix = "commit -m 'fix: '";
      docs = "commit -m 'docs: '";
      style = "commit -m 'style: '";
      refactor = "commit -m 'refactor: '";
      perf = "commit -m 'perf: '";
      test = "commit -m 'test: '";
      chore = "commit -m 'chore: '";
      ci = "commit -m 'ci: '";
      
      # ============ Branches ============
      b = "branch";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      br = "branch -r";
      bm = "branch -m";
      
      # Branch info
      branch-name = "rev-parse --abbrev-ref HEAD";
      bn = "rev-parse --abbrev-ref HEAD";
      
      # ============ Checkout ============
      co = "checkout";
      cob = "checkout -b";
      com = "checkout main";
      cod = "checkout develop";
      cop = "checkout -p";
      
      # ============ Cherry-pick ============
      cp = "cherry-pick";
      cpc = "cherry-pick --continue";
      cpa = "cherry-pick --abort";
      
      # ============ Diff ============
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      dh = "diff HEAD";
      dhh = "diff HEAD~1";
      dt = "difftool";
      
      # Diff stats
      diff-stat = "diff --stat";
      dstat = "diff --stat";
      
      # ============ Fetch/Pull/Push ============
      f = "fetch";
      fa = "fetch --all";
      fo = "fetch origin";
      fu = "fetch upstream";
      
      p = "push";
      pf = "push --force-with-lease";
      pff = "push --force";
      pu = "push -u origin HEAD";
      pt = "push --tags";
      
      pl = "pull";
      plr = "pull --rebase";
      plra = "pull --rebase --autostash";
      
      # ============ Logs and History ============
      l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      lg = "log --graph --oneline --decorate";
      lga = "log --graph --oneline --decorate --all";
      
      # Specific log queries
      last = "log -1 HEAD --stat";
      lastmsg = "log -1 HEAD --pretty=%B";
      today = "log --since=midnight --author='$(git config user.name)' --oneline";
      yesterday = "log --since=yesterday.midnight --until=midnight --author='$(git config user.name)' --oneline";
      standup = "log --since=yesterday --author='$(git config user.name)' --pretty=short";
      
      # File history
      file-history = "log -p --follow";
      fh = "log -p --follow";
      
      # ============ Merge ============
      m = "merge";
      ma = "merge --abort";
      mc = "merge --continue";
      ms = "merge --skip";
      mff = "merge --ff-only";
      mnff = "merge --no-ff";
      
      # ============ Rebase ============
      rb = "rebase";
      rbi = "rebase -i";
      rbc = "rebase --continue";
      rba = "rebase --abort";
      rbs = "rebase --skip";
      rbm = "rebase main";
      rbd = "rebase develop";
      
      # Interactive rebase shortcuts
      rb2 = "rebase -i HEAD~2";
      rb3 = "rebase -i HEAD~3";
      rb4 = "rebase -i HEAD~4";
      rb5 = "rebase -i HEAD~5";
      
      # ============ Reset ============
      r = "reset";
      rh = "reset HEAD";
      rhh = "reset HEAD --hard";
      rs = "reset --soft";
      rsh = "reset --soft HEAD~1";
      uncommit = "reset --soft HEAD~1";
      unstage = "reset HEAD --";
      
      # ============ Stash ============
      st = "stash";
      sta = "stash apply";
      stc = "stash clear";
      std = "stash drop";
      stl = "stash list";
      stp = "stash pop";
      sts = "stash show";
      stsa = "stash save";
      stall = "stash --include-untracked";
      
      # ============ Tags ============
      t = "tag";
      ta = "tag -a";
      td = "tag -d";
      tl = "tag -l";
      
      # ============ Remote ============
      rem = "remote";
      rema = "remote add";
      remr = "remote remove";
      remv = "remote -v";
      rems = "remote show";
      
      # ============ Working with Index ============
      assume = "update-index --assume-unchanged";
      unassume = "update-index --no-assume-unchanged";
      assumed = "!git ls-files -v | grep '^[[:lower:]]'";
      
      skip = "update-index --skip-worktree";
      unskip = "update-index --no-skip-worktree";
      skipped = "!git ls-files -v | grep '^S'";
      
      # ============ Finding and Searching ============
      find = "!git ls-files | grep -i";
      grep = "grep -Ii";
      
      # Find commits
      find-merge = "!sh -c 'commit=$0 && branch=\${1:-HEAD} && (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 -s | uniq -f1 -d | sort -n | tail -1 | cut -f2'";
      
      # ============ Utilities ============
      # Show aliases
      aliases = "config --get-regexp alias";
      alias = "config --get-regexp alias";
      
      # Ignore files
      ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      
      # Statistics
      stats = "shortlog -sn --all --no-merges";
      graph = "log --graph --all --decorate --stat --date=iso";
      contrib = "shortlog -sn";
      
      # File changes
      changes = "diff --name-status";
      diffnames = "diff --name-only";
      
      # ============ Maintenance ============
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
      prune-branches = "!git remote prune origin && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D";
      prune-all = "!git remote prune origin && git worktree prune";
      
      # Garbage collection
      gc-aggressive = "gc --aggressive --prune=now";
      
      # ============ Workflow Helpers ============
      # Save work in progress
      wip = "!git add -u && git commit -m 'WIP'";
      save = "!git add -A && git commit -m 'SAVEPOINT'";
      
      # Undo operations
      undo = "reset HEAD~1 --mixed";
      undo-commit = "reset --soft HEAD~1";
      
      # Fixup and absorb
      fixup = "commit --fixup";
      squash = "commit --squash";
      absorb = "!git-absorb --and-rebase";
      
      # Quick push to current branch
      pushup = "!git push -u origin $(git branch-name)";
      
      # Pull with rebase and autostash
      up = "pull --rebase --autostash";
      
      # ============ Information ============
      # Show recent branches
      recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
      
      # Show branch authors
      authors = "!git log --format='%aN <%aE>' | sort -u";
      
      # Show files in commit
      show-files = "diff-tree --no-commit-id --name-only -r";
      
      # Root directory
      root = "rev-parse --show-toplevel";
      
      # Current branch
      current = "rev-parse --abbrev-ref HEAD";
      
      # ============ Advanced ============
      # Rewrite author
      change-author = "!f() { git filter-branch --env-filter \"GIT_AUTHOR_NAME='$1'; GIT_AUTHOR_EMAIL='$2'; GIT_COMMITTER_NAME='$1'; GIT_COMMITTER_EMAIL='$2';\" HEAD; }; f";
      
      # Find deleted file
      find-deleted = "!git log --diff-filter=D --summary | grep delete";
      
      # Show ignored files
      ignored = "ls-files --others --ignored --exclude-standard";
      
      # Export patches
      export-patches = "format-patch -o patches/";
      
      # ============ Fun ============
      # Random commit message from whatthecommit.com
      yolo = "!git add -A && git commit -m \"$(curl -s http://whatthecommit.com/index.txt)\" && git push --force-with-lease";
      
      # Emoji commits
      boom = "!git add -A && git commit -m '💥 Boom!'";
      fire = "!git add -A && git commit -m '🔥 Fire!'";
      sparkles = "!git add -A && git commit -m '✨ Sparkles!'";
    } // cfg.custom;  # Merge with user's custom aliases

    # Shell aliases for common git commands
    home.shellAliases = {
      # Super short aliases
      g = "git";
      
      # Status
      gs = "git status";
      gss = "git status -s";
      
      # Add
      ga = "git add";
      gaa = "git add -A";
      gap = "git add -p";
      
      # Commit
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      
      # Push/Pull
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull";
      gplr = "git pull --rebase";
      
      # Diff
      gd = "git diff";
      gdc = "git diff --cached";
      gds = "git diff --staged";
      
      # Checkout
      gco = "git checkout";
      gcob = "git checkout -b";
      gcom = "git checkout main";
      
      # Branch
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      
      # Log
      glog = "git log --oneline --graph";
      gloga = "git log --oneline --graph --all";
      
      # Stash
      gst = "git stash";
      gstp = "git stash pop";
      gstl = "git stash list";
      
      # Quick saves
      gwip = "git add -u && git commit -m 'WIP'";
      gsave = "git add -A && git commit -m 'SAVEPOINT'";
    };
  };
}
