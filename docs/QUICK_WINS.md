# Quick Wins - Immediate Improvements

> These improvements can be implemented in under an hour each for immediate benefit

## 1. Create a Makefile for Common Operations

**File:** `/home/ada/src/nix/fern/Makefile`

```makefile
.PHONY: help rebuild test update clean fmt check rollback

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

rebuild: ## Rebuild and switch to new configuration
	sudo nixos-rebuild switch --flake .#fern

test: ## Test configuration without switching
	sudo nixos-rebuild test --flake .#fern

dry: ## Dry-run build to see what would change
	sudo nixos-rebuild dry-build --flake .#fern

update: ## Update all flake inputs
	nix flake update

update-input: ## Update specific input (usage: make update-input INPUT=nixpkgs)
	nix flake lock --update-input $(INPUT)

clean: ## Garbage collect old generations
	nix-collect-garbage -d
	sudo nix-collect-garbage -d

fmt: ## Format all Nix files
	nixpkgs-fmt .

check: ## Check flake and run tests
	nix flake check

rollback: ## Rollback to previous generation
	sudo nixos-rebuild switch --rollback

history: ## Show generation history
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## 2. Safe Rebuild Shell Functions

**Add to:** `nix/home/shells/common.nix` (create if doesn't exist)

```bash
# Safe rebuild with automatic rollback on failure
rebuild-safe() {
  local current_gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1 | awk '{print $1}')
  
  echo "Current generation: $current_gen"
  echo "Testing new configuration..."
  
  if sudo nixos-rebuild test --flake .#fern; then
    echo "Test successful! Applying configuration..."
    if sudo nixos-rebuild switch --flake .#fern; then
      echo "✓ Successfully rebuilt!"
    else
      echo "✗ Switch failed! Rolling back..."
      sudo nixos-rebuild switch --rollback
    fi
  else
    echo "✗ Test failed! Not applying changes."
    return 1
  fi
}

# Quick rebuild alias
alias nrs="rebuild-safe"
alias nrt="sudo nixos-rebuild test --flake .#fern"
```

## 3. Add Direnv Integration

**File:** `nix/home/shells/direnv.nix`

```nix
{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };
  
  # Optional: global .envrc gitignore
  home.file.".config/git/ignore".text = ''
    .envrc
    .direnv/
  '';
}
```

**Add to imports in** `nix/home/shells.nix`:
```nix
imports = [
  # ... existing imports
  ./shells/direnv.nix
];
```

## 4. Aggressive Garbage Collection

**Update:** `nix/modules/core.nix`

```nix
{ lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # More aggressive garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";  # Changed from weekly
    options = "--delete-older-than 7d";  # Changed from 10d
  };
  
  # Optimize store regularly
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  
  # Limit build jobs to prevent OOM
  nix.settings = {
    max-jobs = "auto";
    cores = 0;  # Use all cores
    
    # Better build output
    builders-use-substitutes = true;
    keep-outputs = true;
    keep-derivations = true;
  };
}
```

## 5. Basic Backup Script

**File:** `scripts/backup.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
BACKUP_SOURCE="$HOME/ada"
BACKUP_DEST="/backup/ada"  # Change to your backup location
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_DEST/$DATE"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting backup...${NC}"
echo "Source: $BACKUP_SOURCE"
echo "Destination: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create exclude file if it doesn't exist
if [ ! -f "$HOME/.backupignore" ]; then
  cat > "$HOME/.backupignore" <<EOF
node_modules/
target/
.git/
*.tmp
*.log
.cache/
EOF
fi

# Perform backup
if rsync -av --progress \
  --exclude-from="$HOME/.backupignore" \
  "$BACKUP_SOURCE/" \
  "$BACKUP_DIR/"; then
  
  echo -e "${GREEN}✓ Backup completed successfully!${NC}"
  
  # Create latest symlink
  ln -sfn "$BACKUP_DIR" "$BACKUP_DEST/latest"
  
  # Show backup size
  SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
  echo "Backup size: $SIZE"
  
  # Clean old backups (keep last 7)
  echo "Cleaning old backups..."
  ls -dt "$BACKUP_DEST"/*/ | tail -n +8 | xargs -r rm -rf
else
  echo -e "${RED}✗ Backup failed!${NC}"
  exit 1
fi
```

**Make executable:**
```bash
chmod +x scripts/backup.sh
```

## 6. Git Pre-commit Hook

**File:** `.pre-commit-config.yaml`

```yaml
repos:
  - repo: local
    hooks:
      - id: nix-fmt
        name: Format Nix files
        entry: nixpkgs-fmt
        language: system
        files: '\.nix$'
      
      - id: nix-check
        name: Check Nix files
        entry: nix flake check
        language: system
        pass_filenames: false
        files: '\.nix$'
```

**Install:**
```bash
nix-shell -p pre-commit --run "pre-commit install"
```

## 7. Configuration Validation Script

**File:** `scripts/validate.sh`

```bash
#!/usr/bin/env bash
set -e

echo "🔍 Validating Nix configuration..."

# Check formatting
echo "Checking formatting..."
if ! nixpkgs-fmt --check .; then
  echo "❌ Format check failed. Run 'make fmt' to fix."
  exit 1
fi

# Check flake
echo "Checking flake..."
if ! nix flake check; then
  echo "❌ Flake check failed"
  exit 1
fi

# Dry build
echo "Performing dry build..."
if ! sudo nixos-rebuild dry-build --flake .#fern; then
  echo "❌ Dry build failed"
  exit 1
fi

echo "✅ All checks passed!"
```

## 8. Add Build Caching

**Add to:** `nix/modules/core.nix`

```nix
{
  nix.settings = {
    # Use binary caches
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    
    # Better performance
    min-free = 1 * 1024 * 1024 * 1024;  # 1GB
    max-free = 10 * 1024 * 1024 * 1024;  # 10GB
  };
}
```

## Implementation Order

1. **Makefile** - Start here for immediate productivity boost
2. **Safe rebuild functions** - Prevent breaking your system
3. **Backup script** - Protect your data before other changes
4. **Direnv** - Better per-project environments
5. **Garbage collection** - Free up disk space
6. **Pre-commit hooks** - Maintain code quality
7. **Validation script** - Catch issues early
8. **Build caching** - Speed up rebuilds

## Testing Each Quick Win

After implementing each quick win:

1. **Makefile:** Run `make help` to see all commands
2. **Safe rebuild:** Test with `rebuild-safe`
3. **Direnv:** Create a test `.envrc` file in a project
4. **GC:** Run `make clean` and check free space
5. **Backup:** Run `./scripts/backup.sh` with a test directory
6. **Pre-commit:** Make a change and try to commit
7. **Validation:** Run `./scripts/validate.sh`
8. **Caching:** Time a rebuild before and after

---

*Each quick win is independent - implement them in any order based on your immediate needs!*