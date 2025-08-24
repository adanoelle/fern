# 🔧 Scripts Directory - Automation Tools

## Purpose

Automation scripts for common NixOS configuration tasks. These scripts provide
safety checks, validation, and convenience for development workflow.

## Available Scripts

### rebuild.sh

Safe NixOS rebuild with pre-flight checks.

**Usage:**

```bash
./scripts/rebuild.sh           # Test configuration (default)
./scripts/rebuild.sh switch    # Build and switch
./scripts/rebuild.sh test      # Test explicitly
./scripts/rebuild.sh --rollback  # Rollback to previous
```

**Features:**

- Pre-flight validation checks
- Uncommitted changes warning
- Automatic flake validation
- Format checking
- Colored output
- Error recovery hints

### validate.sh

Comprehensive configuration validation.

**Usage:**

```bash
./scripts/validate.sh            # Run all checks
./scripts/validate.sh --skip-build  # Skip build check (faster)
./scripts/validate.sh --verbose     # Detailed output
```

**Checks:**

- Nix syntax validation
- Code formatting
- Static analysis (statix)
- Dead code detection (deadnix)
- Git status
- Secrets management
- Documentation presence
- Module structure
- Performance analysis

### update.sh

Dependency updates and system maintenance.

**Usage:**

```bash
./scripts/update.sh        # Interactive mode
./scripts/update.sh --all  # Full update process
./scripts/update.sh --flake # Update flake inputs only
./scripts/update.sh --clean # Clean old generations
```

**Features:**

- Flake input updates
- Generation cleanup
- Store optimization
- Security checks
- Update reports
- Interactive and batch modes

## Quick Commands

```bash
# Make scripts executable (first time)
chmod +x scripts/*.sh

# Common workflows
./scripts/validate.sh && ./scripts/rebuild.sh test
./scripts/update.sh --flake && ./scripts/rebuild.sh switch
./scripts/rebuild.sh --rollback  # If something breaks
```

## Integration Tips

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/validate.sh --skip-build
```

### Aliases

Add to your shell configuration:

```bash
alias rebuild="./scripts/rebuild.sh"
alias validate="./scripts/validate.sh"
alias update="./scripts/update.sh"
```

### CI/CD Integration

These scripts can be used in CI pipelines:

```yaml
- run: ./scripts/validate.sh
- run: ./scripts/rebuild.sh build
```

## Error Handling

All scripts follow these conventions:

- Exit code 0 on success
- Exit code 1 on failure
- Colored output for clarity
- Detailed error messages
- Recovery suggestions

## Safety Features

1. **rebuild.sh**

   - Won't switch without successful test
   - Checks for uncommitted changes
   - Validates flake before building

2. **validate.sh**

   - Non-destructive checks only
   - Reports issues without fixing
   - Summary with error/warning counts

3. **update.sh**
   - Confirms before destructive operations
   - Shows what will change
   - Creates update reports

## Common Issues

### Permission Denied

```bash
chmod +x scripts/*.sh
```

### Command Not Found

Some tools are optional:

- `nixpkgs-fmt` - Install for format checking
- `statix` - Install for linting
- `deadnix` - Install for dead code detection

### Sudo Required

Rebuild operations need root:

```bash
sudo ./scripts/rebuild.sh switch
```

## Best Practices

1. Run `validate.sh` before rebuilding
2. Use `test` before `switch`
3. Keep update reports for rollback reference
4. Run `update.sh` regularly for security updates
5. Clean generations periodically to save space

---

_These scripts make NixOS configuration management safer and more convenient._
