# 🛠️ Development Tools - Language Toolchains

> **Purpose:** Comprehensive development environment for multiple programming
> languages  
> **Type:** Feature Suite  
> **Status:** Stable

## Overview

Complete development toolchains for modern programming languages, including
compilers, language servers, package managers, and productivity tools. Each
language module is independently configurable and optimized for development
workflows.

## Quick Start

```bash
# Language-specific commands
cargo build         # Rust
zig build          # Zig
poetry shell       # Python
pnpm install       # Node.js
go mod init        # Go
gcc main.c         # C/C++

# Common development tools
hx file.rs         # Open in Helix editor
bacon             # Rust background compilation
ruff check        # Python linting
```

## What's Inside

| Module       | Language      | Key Tools                     |
| ------------ | ------------- | ----------------------------- |
| `rust.nix`   | Rust          | cargo, rustfmt, clippy, bacon |
| `zig.nix`    | Zig           | zig, zls, ziglings            |
| `python.nix` | Python        | poetry, ruff, black, mypy     |
| `node.nix`   | JavaScript/TS | node, pnpm, typescript, deno  |
| `go.nix`     | Go            | go, gopls, golangci-lint      |
| `c.nix`      | C/C++         | gcc, clang, cmake, valgrind   |

## Language Profiles

### 🦀 Rust

Modern systems programming:

**Toolchain:**

- `rustc` - Rust compiler
- `cargo` - Package manager and build tool
- `rustfmt` - Code formatter
- `clippy` - Linter
- `rust-analyzer` - Language server

**Additional Tools:**

- `bacon` - Background compilation
- `cargo-watch` - File watcher
- `cargo-edit` - Dependency management
- `cargo-outdated` - Dependency updates
- `cargo-audit` - Security audits
- `cargo-flamegraph` - Performance profiling
- `sccache` - Compilation cache

**Workflow:**

```bash
# Create new project
cargo new my-project
cd my-project

# Development cycle
bacon            # Start background compiler
cargo build      # Build project
cargo test       # Run tests
cargo fmt        # Format code
cargo clippy     # Lint code

# Dependencies
cargo add serde  # Add dependency
cargo update     # Update dependencies
cargo tree       # View dependency tree
```

### ⚡ Zig

Simple, robust, optimal:

**Toolchain:**

- `zig` - Compiler and build system
- `zls` - Language server
- `ziglings` - Learn Zig exercises

**Features:**

- Cross-compilation out of the box
- C/C++ compiler included
- No hidden allocations
- Compile-time code execution

**Workflow:**

```bash
# Initialize project
zig init-exe     # Executable
zig init-lib     # Library

# Build and run
zig build        # Build project
zig build run    # Build and run
zig build test   # Run tests

# Cross-compilation
zig build -Dtarget=x86_64-windows
zig build -Dtarget=aarch64-linux
```

### 🐍 Python

Data science and scripting:

**Toolchain:**

- `python` - Python interpreter
- `poetry` - Dependency management
- `ruff` - Fast linter and formatter
- `black` - Code formatter
- `mypy` - Type checker
- `pylsp` - Language server

**Additional Tools:**

- `ipython` - Enhanced REPL
- `pytest` - Testing framework
- `httpie` - HTTP client
- `rich-cli` - Terminal formatting
- `uv` - Fast package installer

**Workflow:**

```bash
# Project setup
poetry new project
cd project
poetry shell     # Activate environment

# Development
poetry add numpy # Add dependency
ruff check .     # Lint code
black .          # Format code
mypy .          # Type check
pytest          # Run tests

# Virtual environments
poetry install   # Install dependencies
poetry update    # Update dependencies
```

### 📦 Node.js / TypeScript

Web and full-stack development:

**Toolchain:**

- `node` - JavaScript runtime
- `pnpm` - Fast package manager
- `typescript` - TypeScript compiler
- `deno` - Secure runtime
- `bun` - All-in-one toolkit

**Additional Tools:**

- `prettier` - Code formatter
- `eslint` - Linter
- `vite` - Build tool
- `tsx` - TypeScript executor
- `npm-check` - Dependency checker

**Workflow:**

```bash
# Project initialization
pnpm init
pnpm add -D typescript @types/node
npx tsc --init

# Development
pnpm install     # Install dependencies
pnpm dev        # Start dev server
pnpm build      # Build for production
pnpm test       # Run tests

# TypeScript
tsc             # Compile TypeScript
tsx script.ts   # Run TypeScript directly
```

### 🐹 Go

Cloud and network services:

**Toolchain:**

- `go` - Go compiler and tools
- `gopls` - Language server
- `golangci-lint` - Meta linter
- `delve` - Debugger
- `air` - Live reload

**Workflow:**

```bash
# Module initialization
go mod init github.com/user/project

# Development
go run .         # Run application
go build        # Build binary
go test ./...   # Run all tests
go fmt ./...    # Format code
golangci-lint run # Lint code

# Dependencies
go get github.com/pkg/errors
go mod tidy     # Clean dependencies
go mod vendor   # Vendor dependencies
```

### 🔧 C/C++

Systems and embedded programming:

**Toolchain:**

- `gcc` - GNU compiler collection
- `clang` - LLVM compiler
- `cmake` - Build system
- `make` - Build automation
- `gdb` - Debugger

**Additional Tools:**

- `valgrind` - Memory debugger
- `ccls` - Language server
- `clang-format` - Code formatter
- `cppcheck` - Static analyzer
- `bear` - Compilation database

**Workflow:**

```bash
# CMake project
mkdir build && cd build
cmake ..
make
./executable

# Debugging
gdb ./program
valgrind ./program

# Formatting
clang-format -i *.c *.h
```

## Cross-Language Tools

### Language Servers

All configured for Helix/VS Code:

| Language   | Server        | Features                    |
| ---------- | ------------- | --------------------------- |
| Rust       | rust-analyzer | Full IDE features           |
| Zig        | zls           | Completion, goto definition |
| Python     | pylsp         | Type checking, refactoring  |
| TypeScript | typescript-ls | IntelliSense, refactoring   |
| Go         | gopls         | Full IDE features           |
| C/C++      | ccls/clangd   | Indexing, completion        |

### Build Tools

Universal build tools available:

- `just` - Command runner (like make)
- `watchexec` - File watcher
- `direnv` - Environment management
- `docker` - Containerization
- `nix` - Reproducible builds

## Project Templates

### Quick Project Setup

```bash
# Rust web service
cargo new --bin api-server
cd api-server
cargo add tokio axum serde

# Python data science
poetry new ml-project
cd ml-project
poetry add numpy pandas scikit-learn jupyter

# TypeScript React app
pnpm create vite@latest my-app --template react-ts
cd my-app
pnpm install
pnpm dev

# Go CLI tool
go mod init github.com/user/cli-tool
cobra-cli init
go mod tidy
```

## Environment Management

### Direnv Integration

Auto-load project environments:

```bash
# .envrc in project root
use flake .       # Nix flake
layout poetry     # Python poetry
layout node       # Node.js

# Activate
direnv allow
```

### Docker Development

Containerized environments:

```dockerfile
# Multi-stage builds supported
FROM rust:latest as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:slim
COPY --from=builder /app/target/release/app /usr/local/bin/
CMD ["app"]
```

## Performance Optimization

### Compilation Caching

Speed up builds:

```bash
# Rust
export RUSTC_WRAPPER=sccache

# C/C++
export CC="ccache gcc"
export CXX="ccache g++"

# Go
export GOCACHE=$HOME/.cache/go-build
```

### Parallel Builds

```bash
# Make
make -j$(nproc)

# Cargo
cargo build --jobs 8

# CMake
cmake --build . --parallel
```

## Troubleshooting

### Language Server Issues

```bash
# Check server status
hx --health rust   # Helix health check

# Restart servers
pkill rust-analyzer
pkill gopls

# Clear caches
rm -rf ~/.cache/rust-analyzer
```

### Build Errors

```bash
# Rust
cargo clean
rm -rf target/

# Node
rm -rf node_modules package-lock.json
pnpm install

# Python
poetry cache clear --all pypi
poetry install
```

### Version Conflicts

```bash
# Check versions
rustc --version
node --version
python --version

# Use specific versions
nix develop .#rust-stable
nix develop .#node-18
```

## Best Practices

1. **Use language servers** - Configure your editor properly
2. **Automate formatting** - Set up format-on-save
3. **Enable linting** - Catch issues early
4. **Write tests** - Use built-in test frameworks
5. **Use type checking** - Even in dynamic languages
6. **Cache dependencies** - Speed up CI/CD
7. **Containerize** - For consistent environments

## Integration

### With Editor (Helix)

All language servers pre-configured:

```toml
# ~/.config/helix/languages.toml
[[language]]
name = "rust"
language-server = { command = "rust-analyzer" }

[[language]]
name = "python"
language-server = { command = "pylsp" }
```

### With Git

Language-specific gitignore:

```bash
# Auto-generated
/target/          # Rust
/node_modules/    # Node
/__pycache__/     # Python
/zig-cache/       # Zig
```

## See Also

- **[Home Modules](../)** - Parent module directory
- **[Helix Editor](../helix.nix)** - Editor configuration
- **[Git Suite](../git/)** - Version control
- **[Shell Configuration](../shells/)** - Development shells

---

_Professional development environments for every language - configured,
optimized, and ready to code._
