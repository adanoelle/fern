# Python

> Python 3.12 with uv for fast package management, pyright LSP, and Jupyter for
> interactive development.

## Overview

The Python setup uses `uv` (a fast Rust-based package installer and venv
manager) instead of pip. It is provided as a single unified aspect
(`modules/devtools/python.nix`) covering the interpreter, development tooling,
and editor integration.

## Interpreter and package management

The aspect (`modules/devtools/python.nix`) installs:

| Package     | Purpose                                 |
| ----------- | --------------------------------------- |
| `python312` | Python 3.12 interpreter                 |
| `uv`        | Fast package installer and venv manager |

`nix-ld` is enabled at the host level (`programs.nix-ld.enable = true`) to
support Python packages with native extensions.

## Development tooling

The aspect also includes:

| Package   | Purpose                                      |
| --------- | -------------------------------------------- |
| `uv`      | Also in home scope                           |
| `rye`     | Python project manager                       |
| `ruff`    | Ultra-fast linter and formatter (Rust-based) |
| `black`   | Code formatter                               |
| `pyright` | Type checker and LSP                         |
| `ipython` | Enhanced interactive shell                   |
| `jupyter` | Jupyter Lab for notebooks                    |

### Helix LSP

```nix
programs.helix.languages.language-server.pyright = {
  command = "${pkgs.pyright}/bin/pyright-langserver";
  args = [ "--stdio" ];
};
```

Pyright provides type checking, completions, and diagnostics for Python files.

## Key files

| File                          | Purpose                                      |
| ----------------------------- | -------------------------------------------- |
| `modules/devtools/python.nix` | Python 3.12, uv, ruff, black, pyright, Jupyter |
