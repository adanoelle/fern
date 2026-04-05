# Design & Orchestrator

> The Git suite is the most extensively configured tool in this repository: 13
> aspects, 100+ aliases, multi-identity management, worktree workflows, safety
> guards, and Claude Code integration -- all composed through an orchestrator
> bundle.

## Architecture

The suite lives in `modules/git/` and is organized as a set of aspects composed
by the `git-suite` bundle. Each sub-aspect is independently testable and can be
toggled via the orchestrator's options.

```
modules/git/
├── bundle.nix            # Orchestrator bundle (programs.gitSuite)
├── core.nix              # SSH signing, delta, performance tuning
├── aliases.nix           # 100+ Git and shell aliases
├── identities.nix        # Multi-identity with includeIf
├── github.nix            # GitHub CLI integration
├── tools.nix             # Lazygit, tig, git-absorb, git-lfs
├── safety.nix            # Protected branches, pre-push hooks
├── help.nix              # tldr, quick-reference sheet
├── claude-code.nix       # Claude Code safety wrapper
├── claude-enhanced.nix   # Claude session manager
├── worktree.nix          # wt helper script
├── worktree-enhanced.nix # Dashboard, templates, parallel ops
├── helix.nix             # Difftastic, editor aliases
└── prompts.nix           # Shell prompt git indicators
```

## The orchestrator pattern

The bundle (`modules/git/bundle.nix`) is an orchestrator -- it composes all 13
sub-aspects via `includes` and provides a `programs.gitSuite` option set that
controls them:

```nix
den.aspects.git-suite = {
  includes = [
    den.aspects.git-core
    den.aspects.git-aliases
    den.aspects.git-identities
    den.aspects.git-github
    den.aspects.git-tools
    den.aspects.git-safety
    den.aspects.git-help
    den.aspects.git-claude-code
    den.aspects.git-claude-enhanced
    den.aspects.git-worktree
    den.aspects.git-worktree-enhanced
    den.aspects.git-helix
    den.aspects.git-prompts
  ];

  homeManager = { config, lib, ... }:
  let cfg = config.programs.gitSuite;
  in {
    options.programs.gitSuite = {
      enable = mkEnableOption "Complete Git suite configuration";
      userName = mkOption { type = types.str; default = "adanoelle"; };
      userEmail = mkOption { type = types.str; default = "adanoelleyoung@gmail.com"; };
      editor = mkOption { type = types.str; default = "hx"; };
      enableGithub = mkOption { type = types.bool; default = true; };
      enableTools = mkOption { type = types.bool; default = true; };
      enableSafety = mkOption { type = types.bool; default = true; };
      enableHelp = mkOption { type = types.bool; default = true; };
      # ... more toggles
    };

    config = mkIf cfg.enable {
      programs.gitCore = {
        enable = true;
        userName = cfg.userName;
        userEmail = cfg.userEmail;
        editor = cfg.editor;
      };
      programs.gitAliases.enable = true;
      programs.gitIdentities.enable = true;
      programs.gitGithub.enable = cfg.enableGithub;
      programs.gitTools.enable = cfg.enableTools;
      programs.gitSafety.enable = cfg.enableSafety;
      programs.gitHelp.enable = cfg.enableHelp;
      # ...
    };
  };
};
```

### How it works

1. **Always-on features**: `gitCore`, `gitAliases`, and `gitIdentities` enable
   unconditionally when the suite is enabled
2. **Optional features**: GitHub, tools, safety, help, worktrees, Claude Code
   each have independent toggles
3. **Shared config**: `userName`, `userEmail`, and `editor` are set once and
   forwarded to `gitCore`

## Enabling the suite

In the user aspect:

```nix
# modules/user-ada.nix (excerpt)
programs.gitSuite = {
  enable = true;
  userName = "adanoelle";
  userEmail = "adanoelleyoung@gmail.com";
  editor = "hx";
  enableGithub = true;
  enableTools = true;
  enableSafety = true;
  enableHelp = true;
};
```

## Sub-aspect overview

| Aspect | What it does | Default |
|--------|-------------|---------|
| `git-core` | SSH signing, delta pager, performance tuning, pull/push/merge defaults | Always on |
| `git-aliases` | 100+ Git aliases and shell aliases | Always on |
| `git-identities` | Multi-identity support with `includeIf` | Always on |
| `git-github` | GitHub CLI, PR/issue workflow aliases | `enableGithub` |
| `git-tools` | Lazygit, tig, git-absorb, git-filter-repo, git-lfs | `enableTools` |
| `git-safety` | Protected branch guards, pre-push hooks, safe operations | `enableSafety` |
| `git-help` | tldr integration, quick-reference sheet | `enableHelp` |
| `git-worktree` | `wt` helper script for worktree management | `enableWorktree` |
| `git-worktree-enhanced` | Dashboard, parallel ops, templates | `enableWorktreeEnhanced` |
| `git-helix` | Difftastic diff tool, editor aliases for modified files | `enableHelix` |
| `git-prompts` | Shell prompt git status indicators | `enablePrompts` |
| `git-claude-code` | `claude` wrapper with safety checks and snapshots | `enableClaudeCode` |
| `git-claude-enhanced` | `claude-wt` session manager, monitoring | `enableClaudeEnhanced` |

## Key files

| File | Purpose |
|------|---------|
| `modules/git/bundle.nix` | Orchestrator bundle |
| `modules/user-ada.nix` | Where the suite is enabled and configured |
