# TypeScript & Node

> Node.js 24, pnpm, Deno, typescript-language-server for Helix, and nix-ld for
> running native ELF binaries.

## Overview

The TypeScript/Node setup covers both server-side Node.js development and
front-end tooling. The system module provides the runtimes, and the home module
adds linting, formatting, and editor integration.

## System module

The system module (`nix/modules/devtools/node-ts.nix`) installs:

| Package     | Purpose                                  |
| ----------- | ---------------------------------------- |
| `nodejs_24` | Node.js 24 LTS runtime                   |
| `pnpm`      | Fast, disk-efficient package manager     |
| `yarn`      | Alternative package manager              |
| `deno`      | TypeScript runtime with built-in tooling |
| `aws-cdk`   | AWS Cloud Development Kit CLI            |
| `jq`        | JSON processor                           |
| `parallel`  | GNU parallel for batch operations        |

### nix-ld

The module enables `programs.nix-ld`, which provides a compatibility layer for
running dynamically-linked ELF binaries on NixOS. This is needed because Node.js
native modules (built by npm/pnpm) expect a standard FHS layout that NixOS does
not provide.

## Home module

The home module (`nix/home/devtools/typescript.nix`) adds:

| Package                      | Purpose                      |
| ---------------------------- | ---------------------------- |
| `eslint_d`                   | ESLint daemon (fast linting) |
| `prettier`                   | Code formatter               |
| `typescript`                 | TypeScript compiler          |
| `typescript-language-server` | LSP for Helix                |
| `tailwindcss`                | Utility-first CSS framework  |
| `deno`                       | Also available in home scope |
| `playwright-test`            | E2E testing framework        |

### Helix LSP

```nix
programs.helix.languages.language-server.typescript-language-server = {
  command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
  args = [ "--stdio" ];
};
```

This provides completions, diagnostics, go-to-definition, and refactoring for
both TypeScript and JavaScript files.

### direnv

direnv with nix-direnv is enabled for per-project Node.js environment
management.

## Key files

| File                               | Purpose                           |
| ---------------------------------- | --------------------------------- |
| `nix/modules/devtools/node-ts.nix` | Node.js, pnpm, Deno, nix-ld       |
| `nix/home/devtools/typescript.nix` | LSP, linting, formatting, testing |
