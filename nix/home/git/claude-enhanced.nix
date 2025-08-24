# git/claude-enhanced.nix - Enhanced Claude Code integration with worktrees
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitClaudeEnhanced;
  
  # Claude worktree manager
  claudeWorktree = pkgs.writeShellScriptBin "claude-wt" ''
    #!/usr/bin/env bash
    set -e
    
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    NC='\033[0m'
    
    # Claude session manager
    action="''${1:-new}"
    
    case "$action" in
      new|start)
        # Create a new Claude worktree session
        session_name="''${2:-experiment}"
        timestamp=$(date +%Y%m%d-%H%M%S)
        branch_name="claude/''${session_name}-''${timestamp}"
        
        echo -e "''${BLUE}═══ Starting Claude Code Session ═══''${NC}"
        echo -e "''${CYAN}Session:''${NC} $session_name"
        echo -e "''${CYAN}Branch:''${NC} $branch_name"
        echo
        
        # Check for uncommitted changes in current worktree
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          echo -e "''${YELLOW}⚠ Uncommitted changes detected''${NC}"
          echo -e "''${CYAN}Creating safety stash...''${NC}"
          git stash push -u -m "Pre-Claude: $session_name ($timestamp)"
          echo -e "''${GREEN}✓ Changes stashed safely''${NC}"
        fi
        
        # Create new worktree for Claude
        echo -e "''${CYAN}Creating isolated worktree...''${NC}"
        wt new "$branch_name"
        
        # Switch to new worktree
        worktree_dir="../$branch_name"
        cd "$worktree_dir"
        
        # Create initial commit
        git commit --allow-empty -m "claude: Initialize session $session_name ($timestamp)"
        
        # Create session file
        cat > .claude-session <<EOF
    SESSION_NAME=$session_name
    SESSION_TIME=$timestamp
    BRANCH_NAME=$branch_name
    START_TIME=$(date)
    EOF
        
        echo -e "''${GREEN}✓ Claude worktree ready''${NC}"
        echo
        echo -e "''${BOLD}Ready for Claude Code!''${NC}"
        echo -e "''${DIM}Run 'claude' to start coding''${NC}"
        echo -e "''${DIM}Run 'claude-wt finish' when done''${NC}"
        
        # Start new shell in worktree
        exec $SHELL
        ;;
        
      finish|end)
        # Finish Claude session
        if [ ! -f .claude-session ]; then
          echo -e "''${RED}Error: Not in a Claude session worktree''${NC}"
          exit 1
        fi
        
        source .claude-session
        
        echo -e "''${BLUE}═══ Finishing Claude Session ═══''${NC}"
        echo -e "''${CYAN}Session:''${NC} $SESSION_NAME"
        echo
        
        # Check for changes
        if [ -n "$(git status --porcelain)" ]; then
          echo -e "''${CYAN}Committing session changes...''${NC}"
          git add -A
          git commit -m "claude: Complete session $SESSION_NAME
    
    Session time: $SESSION_TIME
    Started: $START_TIME
    Completed: $(date)"
          echo -e "''${GREEN}✓ Changes committed''${NC}"
        else
          echo -e "''${YELLOW}No changes to commit''${NC}"
        fi
        
        # Show summary
        echo
        echo -e "''${CYAN}Session Summary:''${NC}"
        git log --oneline --graph -10
        echo
        echo -e "''${CYAN}Changed files:''${NC}"
        git diff --stat HEAD~1...HEAD 2>/dev/null || echo "  No changes"
        
        # Ask about next steps
        echo
        echo -e "''${YELLOW}What would you like to do?''${NC}"
        echo "  1) Keep worktree and changes"
        echo "  2) Merge to main branch"
        echo "  3) Archive and remove worktree"
        echo "  4) Cancel (do nothing)"
        echo -n "Choice [1-4]: "
        read -r choice
        
        case "$choice" in
          2)
            echo -e "''${CYAN}Switching to main branch...''${NC}"
            cd "$(git worktree list | head -n1 | awk '{print $1}')"
            git merge --no-ff "$BRANCH_NAME" -m "Merge Claude session: $SESSION_NAME"
            echo -e "''${GREEN}✓ Merged to main branch''${NC}"
            ;;
          3)
            echo -e "''${CYAN}Archiving worktree...''${NC}"
            cd ..
            git worktree remove "$BRANCH_NAME"
            echo -e "''${GREEN}✓ Worktree archived and removed''${NC}"
            ;;
          *)
            echo -e "''${GREEN}✓ Keeping worktree as-is''${NC}"
            ;;
        esac
        ;;
        
      list|ls)
        # List Claude sessions
        echo -e "''${BLUE}═══ Claude Code Sessions ═══''${NC}"
        echo
        
        found=0
        git worktree list | while read -r line; do
          worktree=$(echo "$line" | awk '{print $1}')
          branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
          
          if [[ "$branch" == claude/* ]]; then
            found=1
            session_file="$worktree/.claude-session"
            if [ -f "$session_file" ]; then
              source "$session_file"
              echo -e "''${CYAN}$SESSION_NAME''${NC} (''${YELLOW}$BRANCH_NAME''${NC})"
              echo "  Started: $START_TIME"
              echo "  Path: $worktree"
            else
              echo -e "''${CYAN}$branch''${NC}"
              echo "  Path: $worktree"
            fi
            echo
          fi
        done
        
        if [ "$found" -eq 0 ]; then
          echo -e "''${DIM}No active Claude sessions''${NC}"
        fi
        ;;
        
      clean|cleanup)
        # Clean up old Claude worktrees
        echo -e "''${BLUE}═══ Cleaning Claude Sessions ═══''${NC}"
        echo
        
        echo -e "''${YELLOW}This will remove all Claude worktrees. Continue? [y/N]''${NC}"
        read -r confirm
        
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
          git worktree list | while read -r line; do
            worktree=$(echo "$line" | awk '{print $1}')
            branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
            
            if [[ "$branch" == claude/* ]]; then
              echo -e "''${CYAN}Removing:''${NC} $branch"
              git worktree remove "$worktree" --force 2>/dev/null || true
            fi
          done
          echo -e "''${GREEN}✓ Claude worktrees cleaned''${NC}"
        else
          echo "Cancelled"
        fi
        ;;
        
      snapshot)
        # Create a snapshot before Claude makes changes
        echo -e "''${BLUE}Creating pre-Claude snapshot...''${NC}"
        
        if [ -n "$(git status --porcelain)" ]; then
          timestamp=$(date +%Y%m%d-%H%M%S)
          git stash push -u -m "Claude snapshot: $timestamp"
          echo -e "''${GREEN}✓ Snapshot created''${NC}"
          echo -e "''${DIM}Run 'git stash list' to see snapshots''${NC}"
          
          # Apply stash to keep working
          git stash apply
          echo -e "''${CYAN}Changes restored (snapshot kept in stash)''${NC}"
        else
          echo -e "''${YELLOW}No changes to snapshot''${NC}"
        fi
        ;;
        
      diff)
        # Show what Claude changed
        if [ -f .claude-session ]; then
          echo -e "''${BLUE}═══ Claude Session Changes ═══''${NC}"
          git diff HEAD~1...HEAD
        else
          echo -e "''${BLUE}═══ Recent Changes ═══''${NC}"
          git diff HEAD~1...HEAD
        fi
        ;;
        
      help|--help|-h)
        echo "claude-wt - Claude Code Worktree Manager"
        echo
        echo "Commands:"
        echo "  new [name]     Start new Claude session in isolated worktree"
        echo "  finish         Complete current Claude session"
        echo "  list           List all Claude sessions"
        echo "  clean          Remove all Claude worktrees"
        echo "  snapshot       Create pre-Claude snapshot"
        echo "  diff           Show Claude's changes"
        echo
        echo "Workflow:"
        echo "  1. claude-wt new experiment   # Start session"
        echo "  2. claude                      # Run Claude Code"
        echo "  3. claude-wt finish           # Complete session"
        ;;
        
      *)
        echo -e "''${RED}Unknown command: $action''${NC}"
        echo "Use 'claude-wt help' for usage"
        exit 1
        ;;
    esac
  '';
  
  # Claude safety wrapper
  claudeSafe = pkgs.writeShellScriptBin "claude-safe" ''
    #!/usr/bin/env bash
    set -e
    
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
    
    echo -e "''${BOLD}''${BLUE}═══ Claude Code Safety Check ═══''${NC}"
    echo
    
    # Check if we're in a worktree
    main_worktree=$(git worktree list 2>/dev/null | head -n1 | awk '{print $1}')
    current_dir=$(pwd)
    
    if [ "$current_dir" = "$main_worktree" ] || [[ "$current_dir" == "$main_worktree"/* ]]; then
      echo -e "''${YELLOW}⚠ WARNING: You're in the main worktree!''${NC}"
      echo
      echo "It's recommended to use Claude in an isolated worktree."
      echo -e "Run ''${CYAN}claude-wt new''${NC} to create a safe environment."
      echo
      echo -n "Continue anyway? [y/N] "
      read -r confirm
      
      if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Cancelled. Use 'claude-wt new' to start safely."
        exit 0
      fi
    else
      echo -e "''${GREEN}✓ Running in worktree (safe)''${NC}"
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
      echo -e "''${YELLOW}⚠ Uncommitted changes detected''${NC}"
      echo
      echo "Options:"
      echo "  1) Create snapshot and continue"
      echo "  2) Commit changes first"
      echo "  3) Continue without snapshot (risky)"
      echo "  4) Cancel"
      echo -n "Choice [1-4]: "
      read -r choice
      
      case "$choice" in
        1)
          claude-wt snapshot
          ;;
        2)
          echo "Please commit your changes and run again."
          exit 0
          ;;
        3)
          echo -e "''${RED}⚠ Proceeding without snapshot''${NC}"
          ;;
        *)
          echo "Cancelled"
          exit 0
          ;;
      esac
    else
      echo -e "''${GREEN}✓ Working directory clean''${NC}"
    fi
    
    echo
    echo -e "''${CYAN}Starting Claude Code...''${NC}"
    echo -e "''${DIM}Remember: Review all changes before committing!''${NC}"
    echo
    
    # Run Claude Code
    if command -v claude-desktop > /dev/null 2>&1; then
      claude-desktop "$@"
    elif command -v claude > /dev/null 2>&1; then
      claude "$@"
    else
      echo -e "''${RED}Error: Claude Code not found''${NC}"
      echo "Please install Claude Code first"
      exit 1
    fi
    
    # Post-Claude check
    echo
    echo -e "''${BLUE}═══ Claude Code Session Complete ═══''${NC}"
    
    if [ -n "$(git status --porcelain)" ]; then
      echo -e "''${CYAN}Changes detected:''${NC}"
      git status -sb
      echo
      echo -e "''${YELLOW}Remember to:''${NC}"
      echo "  • Review changes: git diff"
      echo "  • Test your code"
      echo "  • Commit when ready: git commit"
    fi
  '';
  
  # Claude monitoring script
  claudeMonitor = pkgs.writeShellScriptBin "claude-monitor" ''
    #!/usr/bin/env bash
    
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    DIM='\033[2m'
    NC='\033[0m'
    
    echo -e "''${BLUE}═══ Monitoring Claude Code Changes ═══''${NC}"
    echo -e "''${DIM}Press Ctrl+C to stop monitoring''${NC}"
    echo
    
    # Initial state
    last_stat=$(git status --porcelain | md5sum)
    
    while true; do
      current_stat=$(git status --porcelain | md5sum)
      
      if [ "$last_stat" != "$current_stat" ]; then
        clear
        echo -e "''${BLUE}═══ Claude Code Activity Detected ═══''${NC}"
        echo -e "''${CYAN}Time:''${NC} $(date '+%H:%M:%S')"
        echo
        
        # Show what changed
        echo -e "''${YELLOW}Changes:''${NC}"
        git status -sb
        echo
        
        # Show recent diff
        if [ -n "$(git diff --stat)" ]; then
          echo -e "''${CYAN}Modified files:''${NC}"
          git diff --stat
        fi
        
        last_stat="$current_stat"
        echo
        echo -e "''${DIM}Monitoring... (Ctrl+C to stop)''${NC}"
      fi
      
      sleep 2
    done
  '';
in
{
  options.programs.gitClaudeEnhanced = {
    enable = mkEnableOption "Enhanced Claude Code integration";
    
    enableWorktreeManager = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Claude worktree manager";
    };
    
    enableSafetyWrapper = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Claude safety wrapper";
    };
    
    enableMonitor = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Claude change monitoring";
    };
    
    autoSnapshot = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically create snapshots before Claude runs";
    };
    
    requireWorktree = mkOption {
      type = types.bool;
      default = false;
      description = "Require Claude to run in a worktree";
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = 
      optional cfg.enableWorktreeManager claudeWorktree ++
      optional cfg.enableSafetyWrapper claudeSafe ++
      optional cfg.enableMonitor claudeMonitor;
    
    # Git aliases for Claude workflows
    programs.git.aliases = {
      # Claude worktree operations
      claude-new = "!claude-wt new";
      claude-finish = "!claude-wt finish";
      claude-list = "!claude-wt list";
      claude-clean = "!claude-wt clean";
      
      # Safety operations
      claude-snap = "!claude-wt snapshot";
      claude-diff = "!claude-wt diff";
      
      # Quick experiment
      claude-exp = "!f() { claude-wt new experiment-$(date +%s); }; f";
      
      # Review Claude's changes
      claude-review = "!git diff HEAD~1...HEAD --stat && echo && git diff HEAD~1...HEAD";
    };
    
    # Shell aliases
    home.shellAliases = {
      # Primary Claude commands
      cc = if cfg.requireWorktree then "claude-safe" else "claude";
      ccs = "claude-safe";
      ccw = "claude-wt";
      
      # Quick actions
      ccn = "claude-wt new";
      ccf = "claude-wt finish";
      ccl = "claude-wt list";
      ccc = "claude-wt clean";
      
      # Monitoring
      ccm = "claude-monitor";
      
      # Quick experiment
      ccx = "claude-wt new experiment";
    };
    
    # Shell integration for auto-safety
    programs.bash.initExtra = mkIf cfg.autoSnapshot ''
      # Auto-snapshot before Claude if configured
      claude() {
        if [ "''${CLAUDE_NO_SNAPSHOT:-0}" != "1" ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          echo "Creating safety snapshot before Claude..."
          claude-wt snapshot
        fi
        command claude "$@"
      }
    '';
    
    programs.zsh.initExtra = mkIf cfg.autoSnapshot ''
      # Auto-snapshot before Claude if configured
      claude() {
        if [ "''${CLAUDE_NO_SNAPSHOT:-0}" != "1" ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          echo "Creating safety snapshot before Claude..."
          claude-wt snapshot
        fi
        command claude "$@"
      }
    '';
  };
}