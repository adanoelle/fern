# GitHub Issues to Create

When you push this repository to GitHub, create these issues to track the
improvement plan. You can use the GitHub CLI or web interface.

## Quick Setup with GitHub CLI

```bash
# After setting up the GitHub repository, run these commands:

# Phase 1: Documentation & Onboarding
gh issue create --title "Phase 1: Documentation & Onboarding" \
  --body "$(cat <<'EOF'
## Overview
Create comprehensive documentation for the Fern NixOS configuration.

## Tasks
- [ ] Create README files for all major directories
- [ ] Write architecture documentation
- [ ] Create git suite user guide
- [ ] Add inline documentation to complex modules
- [ ] Create troubleshooting guide
- [ ] Write quick start guide

## Acceptance Criteria
- Every module has a README
- New users can understand the system
- Architecture decisions are documented

## Timeline
2 weeks

## Priority
High

## Labels
`phase-1`, `documentation`, `enhancement`
EOF
)"

# Phase 2: Development Workflow
gh issue create --title "Phase 2: Development Workflow" \
  --body "$(cat <<'EOF'
## Overview
Improve development experience and code quality with automation and tooling.

## Tasks
- [ ] Set up pre-commit hooks (nixpkgs-fmt, statix, deadnix)
- [ ] Create development scripts (rebuild, validate, update)
- [ ] Implement build caching (Cachix or local)
- [ ] Set up GitHub Actions CI
- [ ] Create testing framework
- [ ] Add integration tests

## Acceptance Criteria
- All commits are automatically formatted
- CI passes on all PRs
- Build times reduced by 50%

## Timeline
2 weeks

## Priority
High

## Labels
`phase-2`, `development`, `enhancement`, `ci-cd`
EOF
)"

# Phase 3: Shell Unification
gh issue create --title "Phase 3: Shell Unification" \
  --body "$(cat <<'EOF'
## Overview
Resolve shell compatibility issues and reduce configuration duplication.

## Tasks
- [ ] Create shell abstraction layer
- [ ] Convert bash-specific aliases to Nushell functions
- [ ] Create Nushell custom commands for complex operations
- [ ] Unify environment variables across shells
- [ ] Standardize prompt configuration
- [ ] Document shell-specific features

## Acceptance Criteria
- All aliases work in Nushell
- No duplicate configuration
- Clear documentation of shell differences

## Timeline
2 weeks

## Priority
Medium

## Labels
`phase-3`, `shells`, `nushell`, `enhancement`
EOF
)"

# Phase 4: System Hardening
gh issue create --title "Phase 4: System Hardening" \
  --body "$(cat <<'EOF'
## Overview
Improve security and reliability of the system.

## Tasks
- [ ] Configure firewall rules
- [ ] Set up fail2ban for SSH protection
- [ ] Implement audit logging
- [ ] Create automated backup strategy
- [ ] Write disaster recovery procedures
- [ ] Set up system monitoring

## Acceptance Criteria
- System passes security audit
- Automated backups running daily
- Recovery time < 1 hour

## Timeline
2 weeks

## Priority
High

## Labels
`phase-4`, `security`, `backup`, `enhancement`
EOF
)"

# Phase 5: Advanced Features
gh issue create --title "Phase 5: Advanced Features" \
  --body "$(cat <<'EOF'
## Overview
Add enterprise-grade features for advanced use cases.

## Tasks
- [ ] Create systemd service templates
- [ ] Implement service monitoring
- [ ] Configure NetworkManager
- [ ] Set up VPN modules
- [ ] Add Podman integration
- [ ] Configure QEMU/KVM
- [ ] Set up Prometheus/Grafana monitoring

## Acceptance Criteria
- Service management is automated
- Network configuration is declarative
- Container workflows are smooth
- Monitoring dashboards available

## Timeline
2 weeks

## Priority
Low

## Labels
`phase-5`, `advanced`, `enhancement`, `monitoring`
EOF
)"

# Quick Wins
gh issue create --title "Quick Wins: Immediate Improvements" \
  --body "$(cat <<'EOF'
## Overview
Implement quick improvements that provide immediate value.

## Tasks
- [ ] Add Makefile for common operations
- [ ] Create safe rebuild shell functions
- [ ] Set up direnv integration
- [ ] Configure aggressive garbage collection
- [ ] Create basic backup script
- [ ] Add pre-commit hooks
- [ ] Write validation script
- [ ] Configure build caching

## Acceptance Criteria
- Each improvement works independently
- Documentation provided for each
- Immediate productivity boost

## Timeline
1 day

## Priority
High

## Labels
`quick-win`, `enhancement`
EOF
)"
```

## Individual Quick Win Issues

### Quick Win 1: Makefile

```bash
gh issue create --title "Add Makefile for common operations" \
  --body "Create a Makefile with targets for rebuild, test, update, clean, format, etc. This will streamline daily operations." \
  --label "quick-win,enhancement"
```

### Quick Win 2: Safe Rebuild

```bash
gh issue create --title "Create safe rebuild functions" \
  --body "Add shell functions that test configuration before applying and automatically rollback on failure." \
  --label "quick-win,enhancement,safety"
```

### Quick Win 3: Direnv

```bash
gh issue create --title "Set up direnv integration" \
  --body "Configure direnv with nix-direnv for better per-project environment management." \
  --label "quick-win,enhancement,development"
```

### Quick Win 4: Backup Script

```bash
gh issue create --title "Create automated backup script" \
  --body "Implement a basic backup script for user data with rotation and cleanup." \
  --label "quick-win,enhancement,backup"
```

## Bug Reports Template

```bash
gh issue create --title "Nushell compatibility: aliases with && operator" \
  --body "$(cat <<'EOF'
## Bug Description
Shell aliases containing && operator break Nushell configuration.

## Current Behavior
Nushell fails to parse aliases with bash-specific syntax.

## Expected Behavior
All aliases should work across all configured shells.

## Workaround
Currently using shell-specific alias configurations.

## Solution
Need to create proper abstraction layer for cross-shell compatibility.

## Labels
`bug`, `nushell`, `shells`
EOF
)"
```

## Documentation Issues

```bash
gh issue create --title "Document git worktree workflow" \
  --body "Create comprehensive guide for using git worktrees with examples and best practices." \
  --label "documentation,git"

gh issue create --title "Document Claude Code integration" \
  --body "Explain Claude Code safety features, worktree integration, and best practices." \
  --label "documentation,claude"

gh issue create --title "Create troubleshooting guide" \
  --body "Document common issues and their solutions, especially shell compatibility." \
  --label "documentation,help"
```

## Labels to Create

When setting up the repository, create these labels:

```bash
# Phases
gh label create "phase-1" --description "Phase 1: Documentation" --color "0e8a16"
gh label create "phase-2" --description "Phase 2: Dev Workflow" --color "0e8a16"
gh label create "phase-3" --description "Phase 3: Shell Unification" --color "0e8a16"
gh label create "phase-4" --description "Phase 4: Hardening" --color "0e8a16"
gh label create "phase-5" --description "Phase 5: Advanced" --color "0e8a16"

# Types
gh label create "quick-win" --description "Can be done in < 1 hour" --color "7057ff"
gh label create "enhancement" --description "New feature or request" --color "a2eeef"
gh label create "bug" --description "Something isn't working" --color "d73a4a"
gh label create "documentation" --description "Documentation improvements" --color "0075ca"

# Areas
gh label create "shells" --description "Shell configuration" --color "fbca04"
gh label create "nushell" --description "Nushell specific" --color "fbca04"
gh label create "git" --description "Git configuration" --color "fbca04"
gh label create "claude" --description "Claude Code integration" --color "fbca04"
gh label create "security" --description "Security improvements" --color "ee0701"
gh label create "backup" --description "Backup and recovery" --color "ee0701"
gh label create "ci-cd" --description "CI/CD and automation" --color "1d76db"
gh label create "monitoring" --description "Monitoring and observability" --color "1d76db"
```

## Milestones

```bash
# Create milestones for tracking
gh api repos/:owner/:repo/milestones -f title="Phase 1: Documentation" -f due_on="2025-01-07T00:00:00Z"
gh api repos/:owner/:repo/milestones -f title="Phase 2: Dev Workflow" -f due_on="2025-01-21T00:00:00Z"
gh api repos/:owner/:repo/milestones -f title="Phase 3: Shell Unification" -f due_on="2025-02-04T00:00:00Z"
gh api repos/:owner/:repo/milestones -f title="Phase 4: Hardening" -f due_on="2025-02-18T00:00:00Z"
gh api repos/:owner/:repo/milestones -f title="Phase 5: Advanced" -f due_on="2025-03-04T00:00:00Z"
gh api repos/:owner/:repo/milestones -f title="Quick Wins" -f due_on="2024-12-25T00:00:00Z"
```

---

_Save this file and use it when you're ready to create the GitHub repository.
All commands are ready to copy and paste!_
