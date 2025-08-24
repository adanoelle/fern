# fern/nix/home/git.nix
# 
# Main git configuration that uses modules in git/
{ config, lib, pkgs, ... }:

with lib;

{
  # Import all the git modules
  imports = [
    ./git  # This imports git/default.nix and all submodules
  ];

  # Enable and configure the modular git suite
  programs.gitSuite = {
    enable = true;
    
    # Use Helix as your editor
    editor = "hx";
    
    # Set your primary identity
    primaryIdentity = "personal";
    
    # Configure workspace directories for automatic identity switching
    workspaceDirs = {
      personal = "~/personal";
      work = "~/src/work";  # Ready when you need it
    };
    
    # Enable Claude Code safety features when you have it
    enableClaudeCode = false;  # Set to true when you install Claude Code
    
    # Enable advanced tools
    enableAdvancedTools = true;
  };

  # Configure your identities
  programs.gitIdentities = {
    identities = {
      personal = {
        name = "adanoelle";
        email = "adanoelleyoung@gmail.com";
        signingKey = "~/.ssh/github";
        githubUser = "adanoelle";
      };
      
      # Uncomment and configure when you need work identity
      # work = {
      #   name = "Ada Young";
      #   email = "ada.young@company.com";
      #   signingKey = "~/.ssh/github-work";
      #   githubUser = "ada-work";
      # };
    };
    
    # Automatically switch identities based on directory
    autoSwitch = true;
  };

  # Configure worktree behavior
  programs.gitWorktree = {
    defaultLocation = "auto";  # Creates worktrees as siblings to main
    autoSwitch = true;  # Automatically cd into new worktrees
    enableHelper = true;  # Enable the 'wt' command
    enablePrompt = true;  # Show worktree info in prompt
  };

  # Configure GitHub CLI
  programs.gitGithub = {
    gitProtocol = "ssh";
    editor = "hx";
    
    aliases = {
      co = "pr checkout";
      pv = "pr view --web";
      pc = "pr create --fill";
      pl = "pr list";
      ps = "pr status";
      
      il = "issue list";
      ic = "issue create";
      iv = "issue view --web";
    };
  };

  # Helix-specific Git integration
  programs.gitHelix = {
    enableDifftastic = true;  # Structural diffs that work great with Helix
  };

  # Custom aliases beyond the defaults
  programs.gitAliases = {
    custom = {
      # Your personal workflow aliases
      save = "!git add -A && git commit -m 'SAVEPOINT'";
      wip = "!git add -u && git commit -m 'WIP'";
      undo = "reset HEAD~1 --mixed";
      
      # Quick commits with conventional commit format
      feat = "commit -m 'feat: '";
      fix = "commit -m 'fix: '";
      docs = "commit -m 'docs: '";
      style = "commit -m 'style: '";
      refactor = "commit -m 'refactor: '";
      test = "commit -m 'test: '";
      chore = "commit -m 'chore: '";
      
      # Useful for code review
      review = "!f() { git fetch origin pull/\${1}/head:pr-\${1} && git checkout pr-\${1}; }; f";
      pr-clean = "!git for-each-ref refs/heads/pr-* --format='%(refname:short)' | xargs -n 1 git branch -D";
      
      # Statistics
      stats = "shortlog -sn --all --no-merges";
      recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'";
      
      # Maintenance
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
    };
  };

  # Tool selection
  programs.gitTools = {
    lazygit.enable = true;
    tig.enable = true;
    gitui.enable = true;
    gitAbsorb.enable = true;  # Great for fixup commits with Helix
    gitSecrets.enable = false;  # Enable if you want to prevent secret commits
  };

  # Claude Code configuration (for when you have it)
  programs.gitClaudeCode = mkIf config.programs.gitSuite.enableClaudeCode {
    autoSnapshot = true;
    alwaysSuggestWorktree = true;
    safeMode = true;
    
    aliases = {
      cc = "claude";
      ccw = "claude --in-worktree";
      ccs = "claude --sandbox";
    };
  };
}
