# Ada

> GNAT 13 compiler, GPRBuild project manager, Alire package manager, and ada_ls
> for Helix integration.

## Overview

Ada development uses the GNAT toolchain from GCC with Alire for dependency
management. The setup is provided as a single unified aspect
(`modules/devtools/ada.nix`) covering the compiler and editor integration.

## Compiler and build tools

The aspect (`modules/devtools/ada.nix`) installs:

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

## Editor integration

The aspect also includes:

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

| File                       | Purpose                          |
| -------------------------- | -------------------------------- |
| `modules/devtools/ada.nix` | GNAT, GPRBuild, Alire, ada_ls LSP |
