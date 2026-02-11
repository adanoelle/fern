# Ada

> GNAT 13 compiler, GPRBuild project manager, Alire package manager, and ada_ls
> for Helix integration.

## Overview

Ada development uses the GNAT toolchain from GCC with Alire for dependency
management. The setup spans a system module for the compiler and a home module
for editor integration.

## System module

The system module (`nix/modules/devtools/ada-toolchain.nix`) installs:

| Package    | Purpose                    |
| ---------- | -------------------------- |
| `gnat13`   | GNAT Ada compiler (GCC 13) |
| `gprbuild` | GPR project build tool     |
| `alire`    | Ada/SPARK package manager  |

### Environment variables

```bash
ADA_PROJECT_PATH="$HOME/.config/ada_project_path"
```

This sets the default search path for GPR project files.

## Home module

The home module (`nix/home/devtools/ada.nix`) adds:

| Package | Purpose                      |
| ------- | ---------------------------- |
| `alire` | Also available in home scope |

### Helix LSP

```nix
programs.helix.languages.language-server.ada_ls = {
  command = "ada_ls";
};
```

ada_ls provides completions, diagnostics, and navigation for Ada source files.

## Key files

| File                                     | Purpose               |
| ---------------------------------------- | --------------------- |
| `nix/modules/devtools/ada-toolchain.nix` | GNAT, GPRBuild, Alire |
| `nix/home/devtools/ada.nix`              | Alire, ada_ls LSP     |
