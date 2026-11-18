# C / C++

> GCC and Clang, CMake/Ninja/Meson, debuggers and analysis tools, and a
> clangd + clang-format setup for Helix. Compilers and the hardening
> `CFLAGS`/`CXXFLAGS` are on the NixOS side only.

**Goes on:** fern, yarrow, work laptop (through the `devtools` bundle in
the `ada-dev` user layer). The work laptop gets the home-manager side
only; see the table below.

## What the aspect installs

`den.aspects.c-cpp` (`modules/devtools/c-cpp.nix`) is split by class.
The NixOS side applies on fern and yarrow; the home-manager side applies
everywhere.

| Side         | Packages |
| ------------ | -------- |
| NixOS        | `gcc`, `binutils`, `clang`, `clang-tools`, `lld`, `cmake`, `ninja`, `pkg-config` |
| home-manager | `gdb`, `lldb`, `valgrind`, `rr`, `bear`, `ccache`, `cmake-format`, `pkg-config`, `clang-tools`, `cppcheck`, `include-what-you-use`, `cmake`, `ninja`, `meson`, `doxygen`, `graphviz`, `ripgrep`, `fd` |

Consequences on the work laptop, which has no NixOS side:

- No compiler, linker or binutils come from this aspect. `clangd`,
  `clang-format`, CMake, Ninja and the debuggers are present; the
  compiler is whatever the distribution or a project dev shell provides.
- `CFLAGS` and `CXXFLAGS` are not set.

`clang-tools` supplies `clangd`, `clang-tidy` and `clang-format`.
`include-what-you-use` is its own package, not part of `clang-tools`.
`heaptrack` is not in this aspect; it comes with
[`gamedev`](../gamedev/gamedev-and-art.md).

## Hardening flags (NixOS hosts)

The NixOS side sets both variables to the same string through
`environment.variables`:

```nix
safeFlags = [
  "-fstack-protector-strong"
  "-Wl,-z,relro,-z,now"
];
```

These are plain environment variables: build systems that read `CFLAGS`
/ `CXXFLAGS` from the environment pick them up, and a project that sets
its own flags replaces them.

## Helix

The home-manager side adds to `programs.helix.languages`:

- a `clangd` language server: command `clangd` (resolved from `PATH`),
  args `--background-index --clang-tidy`;
- a `cpp` language entry using that server, with
  `roots = [ "compile_commands.json" ]` and `clang-format` as the
  formatter.

Only `cpp` is overridden; C files use Helix's built-in language entry.
`bear` is installed for generating `compile_commands.json` from build
systems that cannot emit one.

The debugger entry in `modules/cli/helix.nix` names `lldb-vscode`; the
`lldb` package in the current pin ships that adapter as `lldb-dap`.

## direnv

The aspect also enables `programs.direnv` with `nix-direnv` and
`hide_env_diff = true`, so per-project dev shells load on `cd` without
printing the environment diff.

## Key files

| File                         | Purpose                                     |
| ---------------------------- | ------------------------------------------- |
| `modules/devtools/c-cpp.nix` | Packages, flags, Helix C++ config, direnv   |
| `modules/devtools/bundle.nix`| Includes the aspect in `devtools`           |
| `modules/cli/helix.nix`      | Base Helix config and debugger entry        |
