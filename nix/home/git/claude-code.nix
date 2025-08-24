# git/claude-code.nix - Claude Code safety integration for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitClaudeCode;
  
  # Claude Code wrapper script
  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    #!/usr/bin/env bash
    set -e

    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    MAGENTA='\033[0;35m'
    NC='\033[0m'

    # Check if we're in a git repository
    in_git_repo() {
      git rev-parse --git-dir > /dev/null 2>&1
    }

    # Check if we're in a worktree (not the main one)
    in_worktree() {
      if ! in_git_repo; then
        return 1
      fi
      
      main_worktree=$(git worktree list | head -n1 | awk '{print $1}')
      current_dir=$(pwd)
      
      [ "$current_dir" != "$main_worktree" ]
    }

    # Get current branch name
    current_branch() {
      git branch --show-current 2>/dev/null || echo "detached"
    }

    # Safety check before running Claude Code
    safety_check() {
      local force="$1"
      
      if [ "$force" = "--force" ] || [ "$force" = "-f" ]; then
        return 0
      fi
      
      if ! in_git_repo; then
        echo -e "''${YELLOW}⚠ Warning: Not in a git repository''${NC}"
        echo -e "Claude Code works best with version control."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          exit 1
        fi
        return 0
      fi
      
      # Check for uncommitted changes
      if [ -n "$(git status --porcelain)" ]; then
        echo -e "''${YELLOW}⚠ Warning: You have uncommitted changes''${NC}"
        git status --short
        echo
        
        if in_worktree; then
          echo -e "''${GREEN}✓ You're in a worktree ($(current_branch)), which is good!''${NC}"
        else
          echo -e "''${RED}⚠ You're in the main worktree!''${NC}"
          echo -e "Consider creating a worktree for Claude Code experiments:"
          echo -e "  ''${BLUE}wt new claude-$(date +%Y%m%d-%H%M%S)''${NC}"
          echo
        fi
        
        if [ "${toString cfg.requireConfirmation}" = "true" ]; then
          read -p "Continue with Claude Code? (y/N) " -n 1 -r
          echo
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
          fi
        fi
      fi
      
      # Suggest worktree if in main
      if in_git_repo && ! in_worktree && [ "${cfg.alwaysSuggestWorktree}" = "true" ]; then
        echo -e "''${BLUE}💡 Tip: You're in the main worktree''${NC}"
        echo -e "For safer Claude Code usage, consider creating a worktree:"
        echo -e "  ''${GREEN}wt claude''${NC} - Create a worktree for Claude"
        echo -e "  ''${GREEN}claude --in-worktree <name>''${NC} - Create and use a worktree"
        echo
        sleep 1
      fi
    }

    # Create a snapshot before Claude Code runs
    create_snapshot() {
      if in_git_repo && [ "${toString cfg.autoSnapshot}" = "true" ]; then
        local snapshot_name="claude-snapshot-$(date +%Y%m%d-%H%M%S)"
        echo -e "''${BLUE}📸 Creating safety snapshot: $snapshot_name''${NC}"
        
        # Create a lightweight tag for the current state
        git tag -a "$snapshot_name" -m "Snapshot before Claude Code session" 2>/dev/null || true
        
        # If there are uncommitted changes, stash them with a name
        if [ -n "$(git status --porcelain)" ]; then
          git stash push -m "$snapshot_name" > /dev/null
          echo -e "''${GREEN}✓ Uncommitted changes stashed as: $snapshot_name''${NC}"
          echo -e "  Restore with: ''${BLUE}git stash pop''${NC}"
        fi
      fi
    }

    # Parse arguments
    CLAUDE_ARGS=()
    FORCE=false
    CREATE_WORKTREE=""
    SANDBOX_MODE=false
    
    while [[ $# -gt 0 ]]; do
      case $1 in
        --force|-f)
          FORCE=true
          shift
          ;;
        --in-worktree)
          CREATE_WORKTREE="$2"
          shift 2
          ;;
        --sandbox)
          SANDBOX_MODE=true
          shift
          ;;
        --help)
          echo "claude - Claude Code wrapper with safety features"
          echo ""
          echo "Usage: claude [options] [claude-code-args]"
          echo ""
          echo "Options:"
          echo "  --force, -f           Skip safety checks"
          echo "  --in-worktree <name>  Create and run in a new worktree"
          echo "  --sandbox             Run in sandbox mode (read-only)"
          echo "  --help                Show this help"
          echo ""
          echo "Safety features:"
          echo "  - Warns about uncommitted changes"
          echo "  - Suggests using worktrees"
          echo "  - Creates automatic snapshots"
          echo "  - Shows current git context"
          echo ""
          echo "Examples:"
          echo "  claude                          # Run with safety checks"
          echo "  claude --force                  # Skip safety checks"
          echo "  claude --in-worktree fix-bug    # Create worktree and run"
          exit 0
          ;;
        *)
          CLAUDE_ARGS+=("$1")
          shift
          ;;
      esac
    done

    # Handle worktree creation
    if [ -n "$CREATE_WORKTREE" ]; then
      if command -v wt > /dev/null 2>&1; then
        echo -e "''${BLUE}Creating worktree for Claude Code: $CREATE_WORKTREE''${NC}"
        wt new "$CREATE_WORKTREE"
        cd "$(git worktree list | grep "$CREATE_WORKTREE" | awk '{print $1}')"
        echo -e "''${GREEN}✓ Now in worktree: $CREATE_WORKTREE''${NC}"
      else
        echo -e "''${RED}Error: wt command not found''${NC}"
        exit 1
      fi
    fi

    # Run safety checks
    if [ "$FORCE" != "true" ]; then
      safety_check
    fi

    # Create snapshot
    create_snapshot

    # Show current context
    if in_git_repo; then
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
      echo -e "''${MAGENTA}       Claude Code Session Starting     ''${NC}"
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
      echo -e "📍 Directory: ''${BLUE}$(pwd)''${NC}"
      echo -e "🌿 Branch: ''${GREEN}$(current_branch)''${NC}"
      if in_worktree; then
        echo -e "⚡ Worktree: ''${GREEN}Yes''${NC}"
      else
        echo -e "⚡ Worktree: ''${YELLOW}No (main)''${NC}"
      fi
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
      echo
    fi

    # Check if Claude Code is available
    if ! command -v claude-code > /dev/null 2>&1; then
      echo -e "''${RED}Error: Claude Code is not installed''${NC}"
      echo "Please install Claude Code or set enableClaudeCode = false"
      exit 1
    fi
    
    # Set up environment variables for Claude Code
    export CLAUDE_SAFE_MODE="${toString cfg.safeMode}"
    export CLAUDE_PROJECT_ROOT="$(pwd)"
    
    if [ "$SANDBOX_MODE" = "true" ]; then
      echo -e "''${YELLOW}🔒 Running in sandbox mode (read-only)''${NC}"
      export CLAUDE_SANDBOX=1
    fi

    # Run actual Claude Code
    echo -e "''${BLUE}Starting Claude Code...''${NC}"
    claude-code "''${CLAUDE_ARGS[@]}"
    
    # Post-session summary
    if in_git_repo; then
      echo
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
      echo -e "''${MAGENTA}       Claude Code Session Complete     ''${NC}"
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
      
      if [ -n "$(git status --porcelain)" ]; then
        echo -e "''${YELLOW}Changes made:''${NC}"
        git status --short
        echo
        echo -e "''${BLUE}Review changes with:''${NC} git diff"
        echo -e "''${BLUE}Commit changes with:''${NC} git add -A && git commit"
        echo -e "''${BLUE}Discard changes with:''${NC} git restore ."
      else
        echo -e "''${GREEN}✓ No changes made''${NC}"
      fi
      
      echo -e "''${MAGENTA}═══════════════════════════════════════''${NC}"
    fi
  '';

  # Helper functions script
  claudeHelpers = pkgs.writeShellScriptBin "claude-helpers" ''
    #!/usr/bin/env bash

    # Create a Claude-specific worktree
    claude-worktree() {
      local name="''${1:-claude-$(date +%Y%m%d-%H%M%S)}"
      if command -v wt > /dev/null 2>&1; then
        wt new "$name"
        echo "Created worktree: $name"
        echo "Run 'wt switch $name' to enter it"
      else
        echo "wt command not found. Creating regular branch instead."
        git checkout -b "$name"
      fi
    }

    # Review Claude's changes
    claude-review() {
      if ! git diff --quiet; then
        echo "═══ Claude's Changes ═══"
        git diff --stat
        echo "══════════════════════"
        echo ""
        echo "View full diff: git diff"
        echo "Interactive review: git add -p"
      else
        echo "No uncommitted changes"
      fi
    }

    # Undo Claude's last changes
    claude-undo() {
      local last_snapshot=$(git tag -l "claude-snapshot-*" | tail -n1)
      if [ -n "$last_snapshot" ]; then
        echo "Reverting to snapshot: $last_snapshot"
        git reset --hard "$last_snapshot"
        git tag -d "$last_snapshot"
        echo "Reverted successfully"
      else
        echo "No Claude snapshots found"
        echo "You can still use: git restore ."
      fi
    }

    # List Claude snapshots
    claude-snapshots() {
      local snapshots=$(git tag -l "claude-snapshot-*")
      if [ -n "$snapshots" ]; then
        echo "Claude Code snapshots:"
        echo "$snapshots" | while read -r tag; do
          echo "  $tag - $(git log -1 --format=%ci $tag)"
        done
      else
        echo "No Claude snapshots found"
      fi
    }

    # Export functions
    case "$1" in
      worktree) shift; claude-worktree "$@" ;;
      review) claude-review ;;
      undo) claude-undo ;;
      snapshots) claude-snapshots ;;
      *)
        echo "claude-helpers - Claude Code helper functions"
        echo ""
        echo "Commands:"
        echo "  worktree [name]  Create Claude-specific worktree"
        echo "  review           Review Claude's changes"
        echo "  undo             Undo Claude's last changes"
        echo "  snapshots        List Claude snapshots"
        ;;
    esac
  '';
in
{
  options.programs.gitClaudeCode = {
    enable = mkEnableOption "Claude Code integration with safety features";

    autoSnapshot = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically create snapshots before Claude Code sessions";
    };

    alwaysSuggestWorktree = mkOption {
      type = types.bool;
      default = true;
      description = "Always suggest using worktrees when in main branch";
    };

    safeMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable safe mode by default (extra confirmations)";
    };

    requireConfirmation = mkOption {
      type = types.bool;
      default = true;
      description = "Require confirmation when there are uncommitted changes";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        cc = "claude";
        ccw = "claude --in-worktree";
        ccs = "claude --sandbox";
        ccf = "claude --force";
      };
      description = "Shell aliases for Claude Code commands";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      claudeWrapper
      claudeHelpers
    ];

    # Git configuration for Claude Code
    programs.git.extraConfig = {
      # Claude-specific settings
      claude = {
        autoSnapshot = cfg.autoSnapshot;
        safeMode = cfg.safeMode;
      };
    };

    # Git aliases for Claude Code
    programs.git.aliases = {
      # Claude helpers
      claude-snapshot = "tag -a \"claude-snapshot-$(date +%Y%m%d-%H%M%S)\" -m \"Claude Code snapshot\"";
      claude-changes = "!git diff --stat && git status -sb";
      claude-review = "diff --color-words";
      
      # Quick worktree for Claude
      wtc = "!git worktree add \"../claude-$(date +%Y%m%d-%H%M%S)\" -b \"claude-$(date +%Y%m%d-%H%M%S)\"";
      
      # Show all Claude snapshots
      claude-tags = "tag -l 'claude-snapshot-*'";
    };

    # Shell aliases
    home.shellAliases = cfg.aliases // {
      # Helper commands
      claude-worktree = "claude-helpers worktree";
      claude-review = "claude-helpers review";
      claude-undo = "claude-helpers undo";
      claude-snapshots = "claude-helpers snapshots";
      
      # Quick workflow aliases
      cc-new = "claude --in-worktree claude-$(date +%Y%m%d-%H%M%S)";
      cc-review = "git diff --stat && echo '' && git status -sb";
      cc-commit = "git add -A && git commit -m 'Changes by Claude Code'";
      cc-undo = "git restore .";
      cc-diff = "git diff";
    };

    # Create Claude Code config directory
    home.file.".config/claude-code/.keep" = {
      text = "";
    };

    # Add Claude safety documentation
    home.file.".config/claude-code/README.md" = {
      text = ''
        # Claude Code Safety Features

        This wrapper provides safety features for Claude Code:

        ## Features
        - **Automatic snapshots** before each session
        - **Worktree suggestions** to avoid messing up main branch
        - **Uncommitted changes warnings**
        - **Sandbox mode** for read-only exploration

        ## Usage
        ```bash
        # Normal usage (with safety checks)
        claude

        # Create a worktree and run Claude
        claude --in-worktree feature-name

        # Skip safety checks
        claude --force

        # Run in sandbox mode
        claude --sandbox
        ```

        ## Helper Commands
        - `claude-review` - Review changes made by Claude
        - `claude-undo` - Revert to snapshot before Claude
        - `claude-worktree` - Create Claude-specific worktree
        - `claude-snapshots` - List all Claude snapshots

        ## Workflow
        1. Create worktree: `claude --in-worktree fix-bug`
        2. Let Claude work
        3. Review: `claude-review`
        4. Commit or undo: `cc-commit` or `claude-undo`

        ## Configuration
        Settings in git config:
        - `claude.autoSnapshot` - Auto-create snapshots
        - `claude.safeMode` - Enable safe mode

        Shell aliases:
        - `cc` - Quick access to claude
        - `ccw` - Claude in new worktree
        - `ccs` - Claude in sandbox
        - `ccf` - Force mode
      '';
    };

    # Bash/Zsh integration for session tracking
    programs.bash.initExtra = ''
      # Claude Code session tracking
      __claude_session_start() {
        export CLAUDE_SESSION_START=$(date +%s)
        export CLAUDE_SESSION_BRANCH=$(git branch --show-current 2>/dev/null)
      }
      
      __claude_session_end() {
        if [ -n "$CLAUDE_SESSION_START" ]; then
          local duration=$(($(date +%s) - CLAUDE_SESSION_START))
          echo "Claude Code session duration: $((duration / 60)) minutes"
          unset CLAUDE_SESSION_START
          unset CLAUDE_SESSION_BRANCH
        fi
      }
      
      # Track Claude sessions
      alias claude='__claude_session_start; command claude'
    '';
    
    programs.zsh.initExtra = programs.bash.initExtra;
  };
}
