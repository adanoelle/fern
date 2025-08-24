# Fern NixOS Configuration Improvement Plan

> Generated: 2024-12-24  
> Status: Planning Phase

## Executive Summary

This document outlines a comprehensive improvement plan for the Fern NixOS
configuration based on a thorough review of the current implementation. The
configuration shows excellent engineering practices with modular architecture
and advanced features, but could benefit from better documentation, testing, and
accessibility improvements.

## Current State Analysis

### 🌟 Strengths

#### 1. **Excellent Modular Architecture**

- Clean separation between NixOS modules (`nix/modules/`) and Home Manager
  modules (`nix/home/`)
- Well-organized directory structure with logical groupings
- Smart use of `flake-parts` for organizing the flake
- Clear naming conventions throughout

#### 2. **Advanced Git Configuration**

- Comprehensive git suite with worktrees, identities, and Claude integration
- Safety features for AI-assisted coding with automatic snapshots
- Rich aliases and helper scripts for productivity
- Shell-specific compatibility handling (Nushell vs Bash/Zsh)

#### 3. **Developer-Focused Setup**

- Multiple language toolchains:
  - Rust (with overlay)
  - Zig (with overlay)
  - C/C++
  - Python
  - TypeScript/Node.js
  - Ada
  - C#/.NET
- Docker and LocalStack for cloud development
- Well-configured development tools

#### 4. **Desktop Environment**

- Hyprland with comprehensive configuration
- Per-workspace wallpaper support
- Idle/lock management with hypridle/hyprlock
- Clean waybar integration
- Screenshot utilities

#### 5. **Security & Secrets**

- SOPS-nix integration for secret management
- Age-based encryption for sensitive data
- SSH key management
- Secrets guard module for protection

### ⚠️ Weaknesses & Areas for Improvement

#### 1. **Documentation Gaps**

- Missing README files in most directories
- No clear onboarding documentation for new users
- Complex git configuration lacks usage documentation
- No architecture decision records (ADRs)
- No troubleshooting guides

#### 2. **Backup & Recovery**

- No automated backup strategy for user data
- No disaster recovery plan
- Git worktrees could benefit from automatic cleanup policies
- No configuration snapshot system

#### 3. **Testing & Validation**

- No CI/CD pipeline for configuration validation
- No automated tests for configuration changes
- Missing pre-commit hooks for Nix formatting/linting
- No integration tests for complex modules

#### 4. **Performance & Resource Management**

- Multiple overlays might slow down evaluation
- No caching strategy for Nix builds
- Could benefit from binary cache configuration
- No optimization for rebuild times

#### 5. **Shell Configuration Complexity**

- Nushell configuration has compatibility issues with POSIX aliases
- Duplicate configuration between shells
- Command substitution doesn't work in Nushell aliases
- Need better abstraction for cross-shell compatibility

#### 6. **Missing System Features**

- No network management configuration
- No firewall rules defined
- No systemd service management patterns
- Limited container/virtualization beyond Docker
- No monitoring or alerting setup

## Improvement Phases

### Phase 1: Documentation & Onboarding (Week 1-2)

**Goal:** Make the configuration understandable and maintainable

#### Tasks:

1. **Create comprehensive README files**
   - Root README with quick start guide
   - Module-specific documentation
   - Configuration examples
2. **Architecture documentation**
   - System design overview
   - Module interaction diagrams
   - Decision rationale (ADRs)
3. **User guides**
   - Git suite usage guide
   - Development workflow documentation
   - Troubleshooting guide
4. **Inline documentation**
   - Document complex Nix expressions
   - Add module option descriptions
   - Include usage examples

**Deliverables:**

- `docs/README.md` - Documentation index
- `docs/ARCHITECTURE.md` - System overview
- `docs/guides/` - User guides directory
- Inline comments in complex modules

### Phase 2: Development Workflow (Week 3-4)

**Goal:** Improve development experience and code quality

#### Tasks:

1. **Pre-commit hooks setup**

   ```nix
   # Tools to integrate:
   - nixpkgs-fmt     # Formatting
   - statix          # Linting
   - deadnix         # Dead code detection
   - nil             # Nix language server checks
   ```

2. **Development scripts**

   - `scripts/rebuild.sh` - Safe rebuild with rollback
   - `scripts/validate.sh` - Configuration validation
   - `scripts/update.sh` - Dependency updates

3. **Caching implementation**

   - Configure Cachix or similar
   - Set up local binary cache
   - GitHub Actions for CI builds

4. **Testing framework**
   - Unit tests for complex functions
   - Integration tests for modules
   - Smoke tests for system builds

**Deliverables:**

- `.pre-commit-config.yaml`
- `scripts/` directory with utilities
- `.github/workflows/ci.yml`
- `tests/` directory structure

### Phase 3: Shell Unification (Week 5-6)

**Goal:** Resolve shell compatibility issues and reduce duplication

#### Tasks:

1. **Shell abstraction layer**

   ```nix
   # Create common interface:
   mkShellAliases = shell: aliases:
     if shell == "nushell" then
       convertToNushell aliases
     else
       aliases;
   ```

2. **Nushell improvements**

   - Convert complex aliases to Nushell custom commands
   - Create Nushell modules for git operations
   - Add structured data outputs

3. **Common configuration**
   - Extract shared environment variables
   - Unify prompt configuration
   - Standardize keybindings

**Deliverables:**

- `nix/home/shells/common.nix` - Shared configuration
- `nix/home/shells/nushell/commands/` - Custom commands
- Reduced code duplication across shells

### Phase 4: System Hardening (Week 7-8)

**Goal:** Improve security and reliability

#### Tasks:

1. **Security enhancements**

   - Firewall configuration module
   - fail2ban or similar for SSH protection
   - Audit logging setup
   - SELinux/AppArmor consideration

2. **Backup strategy**

   ```nix
   # Implement:
   - Automated home directory backups
   - Configuration snapshots
   - Database backup hooks
   - Cloud sync options
   ```

3. **Disaster recovery**
   - Recovery procedures documentation
   - Backup restoration scripts
   - System state verification

**Deliverables:**

- `nix/modules/security/firewall.nix`
- `nix/modules/backup.nix`
- `docs/DISASTER_RECOVERY.md`

### Phase 5: Advanced Features (Week 9-10)

**Goal:** Add enterprise-grade features

#### Tasks:

1. **Service management**

   - Systemd service templates
   - Service monitoring
   - Auto-restart policies
   - Health checks

2. **Network management**

   - NetworkManager configuration
   - VPN setup modules
   - DNS configuration (systemd-resolved)
   - mDNS/Avahi setup

3. **Container/VM support**

   - Podman integration
   - QEMU/KVM configuration
   - Development containers
   - Microvm.nix consideration

4. **Monitoring & Observability**
   - Prometheus node exporter
   - Grafana dashboards
   - Log aggregation
   - Alert manager

**Deliverables:**

- `nix/modules/services/` - Service templates
- `nix/modules/network/` - Network configuration
- `nix/modules/containers/` - Container support
- `nix/modules/monitoring/` - Observability stack

## Quick Wins (Can be done immediately)

These improvements can be implemented quickly for immediate benefit:

### 1. **Add Makefile for common operations**

```makefile
# /home/ada/src/nix/fern/Makefile
rebuild:
	sudo nixos-rebuild switch --flake .#fern

test:
	sudo nixos-rebuild test --flake .#fern

update:
	nix flake update

clean:
	nix-collect-garbage -d

fmt:
	nixpkgs-fmt .
```

### 2. **Safe rebuild function**

```bash
# Add to shell configuration
rebuild-safe() {
  sudo nixos-rebuild test --flake .#fern && \
  echo "Test successful, applying..." && \
  sudo nixos-rebuild switch --flake .#fern
}
```

### 3. **Direnv integration**

```nix
# nix/home/shells/direnv.nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

### 4. **Aggressive garbage collection**

```nix
# nix/modules/core.nix
nix.gc = {
  automatic = true;
  dates = "daily";
  options = "--delete-older-than 7d";
};
```

### 5. **Basic backup script**

```bash
#!/usr/bin/env bash
# scripts/backup.sh
rsync -av --exclude-from=.backupignore \
  ~/ada/ \
  /backup/ada-$(date +%Y%m%d)/
```

## Success Metrics

- **Documentation Coverage:** 100% of modules have README files
- **Test Coverage:** Critical modules have tests
- **Build Time:** < 5 minutes for full rebuild
- **Shell Compatibility:** All aliases work across shells
- **Security Score:** Pass nix-security-check
- **Backup Recovery:** < 1 hour to restore system

## Timeline Summary

| Phase             | Duration | Priority | Dependencies  |
| ----------------- | -------- | -------- | ------------- |
| Documentation     | 2 weeks  | High     | None          |
| Dev Workflow      | 2 weeks  | High     | Documentation |
| Shell Unification | 2 weeks  | Medium   | Dev Workflow  |
| System Hardening  | 2 weeks  | High     | Documentation |
| Advanced Features | 2 weeks  | Low      | All above     |
| Quick Wins        | 1 day    | High     | None          |

## Next Steps

1. Review and approve this plan
2. Create GitHub issues for each phase
3. Start with Quick Wins for immediate improvement
4. Begin Phase 1 (Documentation) in parallel
5. Schedule regular review meetings

## Notes

- This plan is modular - phases can be reordered based on priorities
- Quick wins should be implemented immediately
- Each phase should include testing and documentation
- Consider pair programming for complex changes
- Regular backups before major changes

---

_This improvement plan is a living document and should be updated as the project
evolves._
