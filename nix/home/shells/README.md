# 🐚 Shell Configuration - Multi-Shell Support

> **Purpose:** Unified shell configuration with Nushell, Bash, and Zsh support  
> **Type:** Feature Suite  
> **Status:** Stable

## Overview

Comprehensive shell configuration supporting multiple shells with shared
environment variables, consistent keybindings, and shell-specific optimizations.
Nushell is configured as the primary shell with Bash and Zsh available for
compatibility.

## Quick Start

```bash
# Switch shells
nu              # Start Nushell
bash            # Start Bash
zsh             # Start Zsh

# Common commands work across all shells
l               # List files (eza)
ll              # List with details
la              # List all including hidden
cd -            # Go to previous directory
z project       # Jump to project (zoxide)
```

## What's Inside

| Component      | Purpose                      | Shell Support    |
| -------------- | ---------------------------- | ---------------- |
| `nushell/`     | Nushell configuration        | Primary shell    |
| `bash.nix`     | Bash configuration           | POSIX compatible |
| `zsh.nix`      | Zsh configuration            | Feature-rich     |
| `common.nix`   | Shared environment variables | All shells       |
| `starship.nix` | Cross-shell prompt           | All shells       |

## Shell Profiles

### 🚀 Nushell (Primary)

Modern, structured data shell:

**Features:**

- Structured data pipelines
- Built-in data formats (JSON, YAML, TOML)
- Type checking
- Modern scripting language
- Tables as first-class citizens

**Configuration:**

- `nushell/config.nu` - Main configuration
- `nushell/env.nu` - Environment setup
- `nushell/aliases.nu` - Custom aliases
- `nushell/completions/` - Tab completions

**Unique Commands:**

```nu
# Structured data operations
ls | where size > 1mb | sort-by modified
open data.json | get users | where age > 21
sys | get cpu | each {|it| $it.usage}

# Built-in commands
sys             # System information
ps              # Process list with filtering
open file.json  # Parse and display JSON
```

### 🔧 Bash

POSIX-compliant compatibility shell:

**Features:**

- Universal compatibility
- Script portability
- Simple and fast
- Extensive ecosystem

**When to use:**

- Running POSIX scripts
- Maximum compatibility needed
- Simple scripting tasks
- System recovery

### ⚡ Zsh

Feature-rich interactive shell:

**Features:**

- Advanced tab completion
- Powerful globbing
- Spelling correction
- Themes and plugins

**When to use:**

- Interactive sessions
- Complex completions needed
- Plugin ecosystem desired

## Common Configuration

### Environment Variables

Set across all shells (`common.nix`):

```nix
# Development
EDITOR = "hx";
VISUAL = "hx";
BROWSER = "firefox";

# Paths
CARGO_HOME = "$HOME/.cargo";
RUSTUP_HOME = "$HOME/.rustup";
GOPATH = "$HOME/go";

# Tools
FZF_DEFAULT_COMMAND = "fd --type f";
RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
```

### Shared Aliases

Available in all shells:

```bash
# Navigation
..          # cd ..
...         # cd ../..
-           # cd -

# File operations
l           # eza
ll          # eza -l
la          # eza -la
lt          # eza --tree

# Git (basic)
g           # git status
ga          # git add
gc          # git commit
gp          # git push

# System
c           # clear
q           # exit
refresh     # source shell config
```

## Nushell Deep Dive

### Custom Commands

Create powerful custom commands:

```nu
# In ~/.config/nushell/config.nu
def search-history [query: string] {
  history | where command =~ $query | select command time
}

def disk-usage [] {
  sys | get disks | select mount used total | sort-by used --reverse
}

def git-status-all [] {
  ls | where type == dir | par-each {|it|
    cd $it.name; git status --short
  }
}
```

### Data Processing

Leverage structured data:

```nu
# Process JSON API
http get https://api.github.com/users/ada | select name public_repos

# Analyze logs
open system.log | lines | parse "{time} {level} {message}" | where level == "ERROR"

# File analysis
ls **/*.rs | select name size | sort-by size --reverse | first 10
```

### Completions

Custom completions for commands:

```nu
# In ~/.config/nushell/completions/git.nu
def "nu-complete git branches" [] {
  git branch | lines | each {|line| $line | str trim | str replace '* ' ''}
}

extern "git checkout" [
  branch: string@"nu-complete git branches"
]
```

## Shell Integration

### Starship Prompt

Consistent prompt across all shells:

**Features:**

- Git status indicators
- Language version display
- Command duration
- Exit code status
- SSH awareness
- Container detection

**Customization:**

```toml
# In ~/.config/starship.toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
```

### Zoxide Integration

Smart directory jumping:

```bash
z project       # Jump to most used 'project' dir
zi              # Interactive selection with fzf
z foo bar       # Jump to dir matching 'foo' and 'bar'
z -            # Jump to previous directory
```

### Atuin History

Advanced shell history:

```bash
# Search history
CTRL+R          # Interactive history search
atuin search    # Search with filters
atuin stats     # Usage statistics

# Sync across machines
atuin sync      # Sync history (if configured)
```

## Performance Optimization

### Nushell

```nu
# Faster startup
$env.config.show_banner = false
$env.config.use_ansi_coloring = true

# Efficient history
$env.config.history.max_size = 10000
$env.config.history.sync_on_enter = false
```

### Bash

```bash
# In ~/.bashrc
# Faster completion
complete -C /usr/bin/aws_completer aws
shopt -s histappend
HISTSIZE=10000
```

### Zsh

```zsh
# In ~/.zshrc
# Lazy loading
zmodload -F zsh/stat b:zstat
autoload -Uz compinit && compinit -C
```

## Troubleshooting

### Nushell Compatibility

Issues with POSIX syntax:

```nu
# Bash: command1 && command2
# Nushell:
command1; command2

# Bash: VAR=value command
# Nushell:
with-env {VAR: value} { command }

# Bash: command $(other_command)
# Nushell:
command (other_command)
```

### Path Issues

```bash
# Check PATH in each shell
echo $PATH          # Bash/Zsh
$env.PATH           # Nushell

# Add to PATH
# Nushell: edit env.nu
$env.PATH = ($env.PATH | prepend "/new/path")
```

### Alias Conflicts

```bash
# Check alias definition
alias myalias       # Bash/Zsh
alias | where name == "myalias"  # Nushell

# Unset alias
unalias myalias     # Bash/Zsh
# In Nushell: remove from config.nu
```

### Slow Startup

```bash
# Profile startup time
# Bash
bash -lxc exit 2>&1 | ts -i "%.s" | head -20

# Zsh
zsh -xv 2>&1 | ts -i "%.s"

# Nushell
nu --log-level trace
```

## Migration Guide

### From Bash to Nushell

| Bash                    | Nushell                                      | Notes                       |
| ----------------------- | -------------------------------------------- | --------------------------- |
| `ls -la`                | `ls -a`                                      | Nushell ls is more powerful |
| `grep pattern file`     | `open file \| lines \| where $it =~ pattern` | Structured approach         |
| `command \| head -n 10` | `command \| first 10`                        | More intuitive              |
| `export VAR=value`      | `$env.VAR = value`                           | Environment variables       |
| `source script.sh`      | `source script.nu`                           | Different extension         |

### Common Gotchas

1. **No command substitution in aliases** - Use custom commands instead
2. **Different pipe behavior** - Data is structured, not text
3. **No `&&` operator** - Use `;` or custom commands
4. **Different variable syntax** - `$var` not `${var}`
5. **Structured vs text** - Many operations return tables

## Best Practices

1. **Use Nushell for**:

   - Data processing
   - Interactive exploration
   - Modern scripting
   - Structured output

2. **Use Bash for**:

   - POSIX scripts
   - System scripts
   - Maximum compatibility
   - Simple one-liners

3. **Use Zsh for**:
   - Complex completions
   - Plugin ecosystem
   - Oh-My-Zsh themes

## See Also

- **[Home Modules](../)** - Parent module directory
- **[CLI Tools](../cli.nix)** - Command-line utilities
- **[Starship Prompt](../starship.nix)** - Prompt configuration
- **[Nushell Book](https://www.nushell.sh/book/)** - Official Nushell
  documentation

---

_Choose the right shell for the task - structured data with Nushell,
compatibility with Bash, features with Zsh._
