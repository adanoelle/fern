# git/worktree-enhanced.nix - Advanced worktree features
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitWorktreeEnhanced;
  
  # Worktree dashboard script
  wtDashboard = pkgs.writeShellScriptBin "wt-dashboard" ''
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
    DIM='\033[2m'
    NC='\033[0m'
    
    # Dashboard header
    echo -e "''${BOLD}''${BLUE}╔════════════════════════════════════════════════════════════════╗''${NC}"
    echo -e "''${BOLD}''${BLUE}║                     WORKTREE DASHBOARD                        ║''${NC}"
    echo -e "''${BOLD}''${BLUE}╚════════════════════════════════════════════════════════════════╝''${NC}"
    echo
    
    # Get repository info
    repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    
    echo -e "''${CYAN}Repository:''${NC} ''${BOLD}$repo_name''${NC}"
    echo -e "''${CYAN}Default Branch:''${NC} $default_branch"
    echo
    
    # Table header
    printf "''${BOLD}%-25s %-10s %-15s %-10s %-20s''${NC}\n" "WORKTREE" "STATUS" "CHANGES" "UPSTREAM" "LAST COMMIT"
    echo -e "''${DIM}─────────────────────────────────────────────────────────────────────────────''${NC}"
    
    # Process each worktree
    git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2 | while read -r worktree; do
      if [ ! -d "$worktree" ]; then
        continue
      fi
      
      # Get branch name
      branch=$(git -C "$worktree" branch --show-current 2>/dev/null || echo "detached")
      branch_display=$(basename "$worktree")
      
      # Check if current
      if [[ "$PWD" == "$worktree"* ]]; then
        branch_display="→ ''${GREEN}$branch_display''${NC}"
        is_current="*"
      else
        branch_display="  $branch_display"
        is_current=""
      fi
      
      # Get status
      cd "$worktree" 2>/dev/null || continue
      
      # Count changes
      staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
      modified=$(git diff --numstat 2>/dev/null | wc -l)
      untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
      
      # Status indicator
      if [ "$staged" -gt 0 ] || [ "$modified" -gt 0 ] || [ "$untracked" -gt 0 ]; then
        status="''${YELLOW}●''${NC} dirty"
      else
        status="''${GREEN}✓''${NC} clean"
      fi
      
      # Changes summary
      changes=""
      [ "$staged" -gt 0 ] && changes="''${GREEN}+$staged''${NC} "
      [ "$modified" -gt 0 ] && changes="$changes''${YELLOW}~$modified''${NC} "
      [ "$untracked" -gt 0 ] && changes="$changes''${RED}?$untracked''${NC}"
      [ -z "$changes" ] && changes="''${DIM}none''${NC}"
      
      # Upstream status
      upstream=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "")
      if [ -n "$upstream" ]; then
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
        
        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
          upstream_status="''${YELLOW}↑$ahead ↓$behind''${NC}"
        elif [ "$ahead" -gt 0 ]; then
          upstream_status="''${GREEN}↑$ahead''${NC}"
        elif [ "$behind" -gt 0 ]; then
          upstream_status="''${RED}↓$behind''${NC}"
        else
          upstream_status="''${GREEN}synced''${NC}"
        fi
      else
        upstream_status="''${DIM}no remote''${NC}"
      fi
      
      # Last commit
      last_commit=$(git log -1 --format="%ar" 2>/dev/null || echo "no commits")
      
      # Print row
      printf "%-35b %-20b %-25b %-20b %-20s\n" \
        "$branch_display" "$status" "$changes" "$upstream_status" "$last_commit"
    done
    
    echo
    echo -e "''${DIM}─────────────────────────────────────────────────────────────────────────────''${NC}"
    
    # Summary
    total=$(git worktree list | wc -l)
    echo -e "''${CYAN}Total worktrees:''${NC} $total"
    
    # Disk usage
    if command -v du > /dev/null 2>&1; then
      base_dir=$(dirname "$(git worktree list | head -n1 | awk '{print $1}')")
      if [ -d "$base_dir" ]; then
        size=$(du -sh "$base_dir" 2>/dev/null | cut -f1)
        echo -e "''${CYAN}Total disk usage:''${NC} $size"
      fi
    fi
    
    echo
    echo -e "''${DIM}Commands: wt new | wt switch | wt remove | wt-parallel <cmd>''${NC}"
  '';
  
  # Parallel worktree operations script
  wtParallel = pkgs.writeShellScriptBin "wt-parallel" ''
    #!/usr/bin/env bash
    set -e
    
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    
    show_help() {
      echo "wt-parallel - Execute commands in parallel across all worktrees"
      echo
      echo "Usage: wt-parallel <command>"
      echo
      echo "Commands:"
      echo "  pull        Pull latest changes in all worktrees"
      echo "  fetch       Fetch updates for all worktrees"
      echo "  test        Run tests in all worktrees"
      echo "  build       Build in all worktrees"
      echo "  clean       Clean all worktrees"
      echo "  status      Show status of all worktrees"
      echo "  <custom>    Run any custom command"
      echo
      echo "Examples:"
      echo "  wt-parallel pull"
      echo "  wt-parallel 'npm test'"
      echo "  wt-parallel 'git status -sb'"
    }
    
    if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
      show_help
      exit 0
    fi
    
    command="$1"
    
    # Predefined commands
    case "$command" in
      pull)
        actual_command="git pull --rebase --autostash"
        ;;
      fetch)
        actual_command="git fetch --prune"
        ;;
      test)
        # Detect test command
        if [ -f "package.json" ]; then
          actual_command="npm test"
        elif [ -f "Cargo.toml" ]; then
          actual_command="cargo test"
        elif [ -f "go.mod" ]; then
          actual_command="go test ./..."
        else
          actual_command="make test"
        fi
        ;;
      build)
        # Detect build command
        if [ -f "package.json" ]; then
          actual_command="npm run build"
        elif [ -f "Cargo.toml" ]; then
          actual_command="cargo build"
        elif [ -f "go.mod" ]; then
          actual_command="go build"
        else
          actual_command="make build"
        fi
        ;;
      clean)
        actual_command="git clean -fd"
        ;;
      status)
        actual_command="git status -sb"
        ;;
      *)
        actual_command="$command"
        ;;
    esac
    
    echo -e "''${BLUE}═══ Running in parallel: $actual_command ═══''${NC}"
    echo
    
    # Create temporary directory for output
    tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT
    
    # Run commands in parallel (with limit)
    MAX_PARALLEL=4  # Limit concurrent processes
    pids=()
    worktrees=()
    count=0
    
    git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2 | while read -r worktree; do
      if [ ! -d "$worktree" ]; then
        continue
      fi
      
      branch=$(git -C "$worktree" branch --show-current 2>/dev/null || echo "detached")
      worktree_name=$(basename "$worktree")
      
      {
        echo -e "''${CYAN}[$worktree_name]''${NC} Starting..."
        cd "$worktree"
        if eval "$actual_command" > "$tmpdir/$worktree_name.out" 2> "$tmpdir/$worktree_name.err"; then
          echo -e "''${GREEN}[$worktree_name]''${NC} ✓ Success"
          if [ -s "$tmpdir/$worktree_name.out" ]; then
            sed "s/^/  /" "$tmpdir/$worktree_name.out"
          fi
        else
          echo -e "''${RED}[$worktree_name]''${NC} ✗ Failed"
          if [ -s "$tmpdir/$worktree_name.err" ]; then
            sed "s/^/  /" "$tmpdir/$worktree_name.err"
          fi
        fi
      } &
      
      pids+=($!)
      worktrees+=("$worktree_name")
      count=$((count + 1))
      
      # Wait for batch to complete if we hit the limit
      if [ $count -ge $MAX_PARALLEL ]; then
        for pid in "''${pids[@]}"; do
          wait "$pid"
        done
        pids=()
        count=0
      fi
    done
    
    # Wait for all processes
    for pid in "''${pids[@]}"; do
      wait "$pid"
    done
    
    echo
    echo -e "''${GREEN}═══ All parallel operations completed ═══''${NC}"
  '';
  
  # Worktree templates script
  wtTemplates = pkgs.writeShellScriptBin "wt-template" ''
    #!/usr/bin/env bash
    set -e
    
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    
    template="$1"
    name="$2"
    
    if [ -z "$template" ] || [ "$template" = "--help" ] || [ "$template" = "-h" ]; then
      echo "wt-template - Create worktrees from templates"
      echo
      echo "Usage: wt-template <template> <name>"
      echo
      echo "Templates:"
      echo "  feature     Create feature branch (feature/<name>)"
      echo "  fix         Create bugfix branch (fix/<name>)"
      echo "  hotfix      Create hotfix branch (hotfix/<name>)"
      echo "  release     Create release branch (release/<name>)"
      echo "  experiment  Create experimental branch (exp/<name>)"
      echo "  claude      Create Claude Code branch (claude/<name>)"
      echo
      echo "Examples:"
      echo "  wt-template feature awesome-feature"
      echo "  wt-template fix bug-123"
      echo "  wt-template claude test-refactor"
      exit 0
    fi
    
    if [ -z "$name" ]; then
      echo -e "''${RED}Error: Name required''${NC}"
      echo "Usage: wt-template <template> <name>"
      exit 1
    fi
    
    # Set branch prefix based on template
    case "$template" in
      feature|feat)
        prefix="feature"
        commit_prefix="feat"
        ;;
      fix|bugfix)
        prefix="fix"
        commit_prefix="fix"
        ;;
      hotfix)
        prefix="hotfix"
        commit_prefix="fix"
        ;;
      release|rel)
        prefix="release"
        commit_prefix="chore"
        ;;
      experiment|exp)
        prefix="exp"
        commit_prefix="exp"
        ;;
      claude|ai)
        prefix="claude"
        commit_prefix="claude"
        timestamp=$(date +%Y%m%d-%H%M%S)
        name="''${name}-''${timestamp}"
        ;;
      *)
        echo -e "''${RED}Unknown template: $template''${NC}"
        exit 1
        ;;
    esac
    
    branch_name="$prefix/$name"
    
    echo -e "''${BLUE}Creating worktree from template: $template''${NC}"
    echo -e "''${CYAN}Branch: $branch_name''${NC}"
    
    # Create the worktree
    wt new "$branch_name"
    
    # If it's a Claude branch, add safety commit
    if [ "$template" = "claude" ] || [ "$template" = "ai" ]; then
      echo -e "''${YELLOW}Setting up Claude Code safety...''${NC}"
      cd "../$branch_name"
      git add -A 2>/dev/null || true
      git commit --allow-empty -m "$commit_prefix: Initialize Claude Code session $timestamp" || true
      echo -e "''${GREEN}✓ Claude Code worktree ready with safety commit''${NC}"
    fi
    
    echo -e "''${GREEN}✓ Template worktree created: $branch_name''${NC}"
  '';
in
{
  options.programs.gitWorktreeEnhanced = {
    enable = mkEnableOption "Enhanced worktree features";
    
    enableDashboard = mkOption {
      type = types.bool;
      default = true;
      description = "Enable worktree dashboard";
    };
    
    enableParallel = mkOption {
      type = types.bool;
      default = true;
      description = "Enable parallel worktree operations";
    };
    
    enableTemplates = mkOption {
      type = types.bool;
      default = true;
      description = "Enable worktree templates";
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = 
      optional cfg.enableDashboard wtDashboard ++
      optional cfg.enableParallel wtParallel ++
      optional cfg.enableTemplates wtTemplates;
    
    # Additional git aliases for enhanced features
    programs.git.aliases = {
      # Template shortcuts
      wt-feature = "!wt-template feature";
      wt-fix = "!wt-template fix";
      wt-hotfix = "!wt-template hotfix";
      wt-release = "!wt-template release";
      wt-exp = "!wt-template experiment";
      wt-claude = "!wt-template claude";
      
      # Parallel operations shortcuts
      wt-pull-all = "!wt-parallel pull";
      wt-fetch-all = "!wt-parallel fetch";
      wt-test-all = "!wt-parallel test";
      wt-build-all = "!wt-parallel build";
      
      # Dashboard shortcut
      wtd = "!wt-dashboard";
    };
    
    # Shell aliases
    home.shellAliases = {
      # Template shortcuts
      wtf = "wt-template feature";
      wtfix = "wt-template fix";
      wtexp = "wt-template experiment";
      wtc = "wt-template claude";
      
      # Dashboard
      wtd = "wt-dashboard";
      
      # Parallel operations
      wtp = "wt-parallel";
      wtpa = "wt-parallel pull";
    };
  };
}