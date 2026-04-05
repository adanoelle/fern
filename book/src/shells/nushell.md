# Nushell

> Nushell is the primary shell, configured as a den aspect with Starship prompt
> integration, Zoxide directory jumping, and Git-aware aliases.

## Overview

The `nushell` aspect (`modules/shells/nushell.nix`) configures Nushell as the
default interactive shell. Nushell treats data as structured tables rather than
plain text, making it powerful for filtering, sorting, and transforming command
output.

## Configuration

The aspect uses Home Manager's `programs.nushell` module:

```nix
den.aspects.nushell.homeManager = { pkgs, config, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      cat = "bat";
      find = "fd";
      grep = "rg";
    };
  };
};
```

### Shell aliases

Nushell aliases replace common Unix commands with modern alternatives:

| Alias | Expands to | Why |
|-------|-----------|-----|
| `cat` | `bat` | Syntax highlighting, line numbers |
| `find` | `fd` | Faster, simpler syntax |
| `grep` | `rg` | Faster, respects `.gitignore` |
| `ll` | `ls -l` | Long listing |
| `la` | `ls -a` | Show hidden files |

### Integration hooks

The aspect configures activation hooks for Starship and Zoxide so they generate
Nushell-compatible init scripts. This ensures the prompt and directory jumping
work within Nushell's evaluation model.

## Part of the shells bundle

Nushell is included in the shells bundle alongside Starship, Zoxide, and devenv:

```nix
# modules/shells/bundle.nix
den.aspects.shells = {
  includes = [
    den.aspects.nushell
    den.aspects.starship
    den.aspects.zoxide
    den.aspects.devenv
  ];
};
```

The user aspect includes the bundle, and all four aspects activate together.

## User account integration

The `users` aspect (`modules/users.nix`) sets Nushell as the login shell:

```nix
users.users.ada.shell = pkgs.nushell;
```

This means both interactive sessions and login shells use Nushell.

## Key files

| File | Purpose |
|------|---------|
| `modules/shells/nushell.nix` | Nushell configuration and aliases |
| `modules/shells/bundle.nix` | Shells bundle (includes nushell) |
| `modules/users.nix` | Login shell assignment |
