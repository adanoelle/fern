# C / C++

> GCC and Clang with hardening flags, CMake/Ninja build systems, and clangd LSP
> integration in Helix.

## Overview

The C/C++ toolchain is split across a system module (compilers, build tools,
hardening flags) and a home module (debugging, profiling, LSP, static analysis).
Together they provide a complete development environment for C and C++ projects.

## System module

The system module (`nix/modules/devtools/c-toolchain.nix`) installs compilers
and build tools:

| Package       | Purpose                          |
| ------------- | -------------------------------- |
| `gcc`         | GNU C/C++ compiler               |
| `binutils`    | Linker, assembler, object tools  |
| `clang`       | LLVM C/C++ compiler              |
| `clang-tools` | clangd, clang-tidy, clang-format |
| `lld`         | LLVM linker (fast)               |
| `cmake`       | Build system generator           |
| `ninja`       | Fast build executor              |
| `pkg-config`  | Library discovery                |

### Hardening flags

Applied via environment variables to all C/C++ builds:

```bash
CFLAGS="-fstack-protector-strong -Wl,-z,relro,-z,now"
CXXFLAGS="-fstack-protector-strong -Wl,-z,relro,-z,now"
```

- **`-fstack-protector-strong`** -- Detects stack buffer overflows
- **`-Wl,-z,relro,-z,now`** -- Full RELRO (read-only GOT)

## Home module

The home module (`nix/home/devtools/cpp.nix`) adds debugging, profiling, and
editor integration:

**Debugging & profiling:**

- `gdb`, `lldb` -- Debuggers
- `valgrind` -- Memory error detection
- `rr` -- Time-travel debugger (record and replay)
- `heaptrack` -- Heap memory profiler

**Build helpers:**

- `bear` -- Generates `compile_commands.json` from build output
- `ccache` -- Compiler cache
- `cmake-format` -- CMake file formatter

**Static analysis:**

- `cppcheck` -- Static analyzer
- `clang-tools` -- clang-tidy, include-what-you-use

**Build systems:**

- `cmake`, `ninja`, `meson` -- Build system generators
- `doxygen`, `graphviz` -- Documentation generation

### Helix LSP

clangd is configured with background indexing and clang-tidy integration:

```nix
programs.helix.languages.language-server.clangd = {
  command = "${pkgs.clang-tools}/bin/clangd";
  args = [ "--background-index" "--clang-tidy" ];
};
```

### direnv

The module enables `direnv` with `nix-direnv` support, allowing per-project Nix
shells to activate automatically when entering a directory.

## Key files

| File                                   | Purpose                                 |
| -------------------------------------- | --------------------------------------- |
| `nix/modules/devtools/c-toolchain.nix` | Compilers, build tools, hardening flags |
| `nix/home/devtools/cpp.nix`            | Debuggers, profilers, clangd LSP        |
