# Fern NixOS Configuration Documentation

Welcome to the documentation for the Fern NixOS configuration. This directory
contains comprehensive guides, improvement plans, and reference materials for
understanding and working with this configuration.

## 📚 Documentation Structure

### Core Documents

- **[IMPROVEMENT_PLAN.md](./IMPROVEMENT_PLAN.md)** - Comprehensive improvement
  plan with phased approach
- **[QUICK_WINS.md](./QUICK_WINS.md)** - Immediately actionable improvements (<
  1 hour each)
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and design
  decisions
- **[ROADMAP.md](./ROADMAP.md)** - Future development roadmap

### Guides

Located in the [`guides/`](./guides/) directory:

- **[git-suite.md](./guides/git-suite.md)** - Complete guide to the advanced git
  configuration
- **[development.md](./guides/development.md)** - Development workflow and best
  practices
- **[troubleshooting.md](./guides/troubleshooting.md)** - Common issues and
  solutions

## 🚀 Quick Start

### For New Users

1. Read the [ARCHITECTURE.md](./ARCHITECTURE.md) to understand the system
   structure
2. Follow the setup instructions in the main [README](../README.md)
3. Review [QUICK_WINS.md](./QUICK_WINS.md) for immediate improvements
4. Explore specific guides based on your needs

### For Contributors

1. Review the [IMPROVEMENT_PLAN.md](./IMPROVEMENT_PLAN.md)
2. Check GitHub issues for current work
3. Read [development.md](./guides/development.md) for workflow guidelines
4. Test changes using the validation scripts

## 🗂️ Configuration Overview

### Directory Structure

```
fern/
├── docs/                 # This documentation
├── flake.nix            # Main flake definition
├── flake.parts/         # Flake organization
├── hosts/               # Host-specific configurations
│   └── fern/           # Main host configuration
├── nix/                 # All Nix modules
│   ├── home/           # Home Manager modules
│   │   ├── cli/        # CLI tools configuration
│   │   ├── desktop/    # Desktop environment
│   │   ├── devtools/   # Development tools
│   │   ├── git/        # Git suite modules
│   │   └── shells/     # Shell configurations
│   └── modules/        # NixOS system modules
│       ├── cloud/      # Cloud tools
│       ├── desktop/    # Desktop services
│       └── devtools/   # System-level dev tools
├── scripts/            # Utility scripts
└── secrets/            # Encrypted secrets (SOPS)
```

## 📋 Current Features

### System Configuration

- **Boot:** Zen kernel with optimizations
- **Graphics:** Nvidia support with Hyprland
- **Audio:** PipeWire with quality tweaks
- **Security:** SOPS-nix for secrets management

### Development Environment

- **Languages:** Rust, Zig, Python, TypeScript, C/C++, Ada, C#
- **Tools:** Docker, LocalStack, AWS CLI, Azure CLI
- **Editors:** Helix as primary, with VS Code and Cursor available

### Desktop Environment

- **Compositor:** Hyprland with per-workspace wallpapers
- **Shell:** Nushell as primary, with Bash/Zsh compatibility
- **Terminal:** Ghostty
- **Bar:** Waybar with custom configuration

### Git Configuration

- **Worktrees:** Advanced worktree management
- **Identities:** Multi-identity support with auto-switching
- **AI Integration:** Claude Code safety features
- **Tools:** LazyGit, Tig, delta, git-absorb

## 🔧 Maintenance

### Regular Tasks

- **Daily:** Automatic garbage collection runs
- **Weekly:** Review and update dependencies
- **Monthly:** Full system backup
- **Quarterly:** Review improvement plan progress

### Common Commands

```bash
# Rebuild system
make rebuild

# Test changes
make test

# Update dependencies
make update

# Clean old generations
make clean

# Format code
make fmt
```

## 📈 Improvement Tracking

We use GitHub Issues to track improvements. Key labels:

- `phase-1` through `phase-5` - Improvement phases
- `quick-win` - Can be done immediately
- `documentation` - Documentation improvements
- `bug` - Things that are broken
- `enhancement` - New features

## 🤝 Contributing

1. Check existing issues or create a new one
2. Follow the code style (use `nixpkgs-fmt`)
3. Test your changes with `make test`
4. Document any new features
5. Submit a pull request

## 📞 Getting Help

- Check [troubleshooting.md](./guides/troubleshooting.md) first
- Review existing GitHub issues
- Ask in discussions for general questions
- Create an issue for bugs or feature requests

## 📊 Status

- **Configuration Version:** 25.11
- **Last Major Update:** 2024-12-24
- **Documentation Coverage:** 60% (improving)
- **Test Coverage:** 20% (planned improvement)

## 🔗 Related Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Flakes Book](https://nixos-and-flakes.thiscute.world/)

---

_This documentation is actively maintained. Please report any issues or
suggestions via GitHub issues._
