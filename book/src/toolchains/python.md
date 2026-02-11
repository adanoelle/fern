# Python

> Python 3.12 with uv for fast package management, pyright LSP, and Jupyter for
> interactive development.

## Overview

The Python setup uses `uv` (a fast Rust-based package installer and venv
manager) instead of pip. The system module provides the interpreter, and the
home module adds development tooling and editor integration.

## System module

The system module (`nix/modules/devtools/python-toolchain.nix`) installs:

| Package     | Purpose                                 |
| ----------- | --------------------------------------- |
| `python312` | Python 3.12 interpreter                 |
| `uv`        | Fast package installer and venv manager |

`nix-ld` is enabled at the host level (`programs.nix-ld.enable = true`) to
support Python packages with native extensions.

## Home module

The home module (`nix/home/devtools/python.nix`) adds:

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

| File                                        | Purpose                       |
| ------------------------------------------- | ----------------------------- |
| `nix/modules/devtools/python-toolchain.nix` | Python 3.12, uv               |
| `nix/home/devtools/python.nix`              | Ruff, black, pyright, Jupyter |
