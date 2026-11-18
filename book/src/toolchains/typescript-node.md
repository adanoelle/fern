# TypeScript / Node

> Node.js 24 with pnpm, yarn and Deno on the NixOS hosts; TypeScript,
> its language server, prettier and eslint_d for the user; Helix wired
> to `typescript-language-server` and prettier.

**Goes on:** fern, yarrow, work laptop (through the `devtools` bundle in
the `ada-dev` user layer). The work laptop gets the home-manager side
only.

## What the aspect installs

`den.aspects.node-ts` (`modules/devtools/node-ts.nix`):

| Side         | Packages |
| ------------ | -------- |
| NixOS        | `nodejs_24`, `pnpm`, `yarn`, `deno`, `jq`, `parallel` |
| home-manager | `eslint_d`, `prettier`, `typescript`, `typescript-language-server`, `tailwindcss`, `deno`, `coc-jest`, `playwright-test` |

On the work laptop there is no NixOS side, so Node itself, pnpm and yarn
do not come from this aspect; Deno, `tsc`, the language server and the
formatters do.

`aws-cdk` is not installed: it left nixpkgs together with the
`nodePackages` set. Where it is needed, `npm install -g aws-cdk`.

## nix-ld

The NixOS side sets `programs.nix-ld.enable = true`, so prebuilt
binaries downloaded by npm packages can find a dynamic loader. The same
option is already a fleet default (`lib.mkDefault true` in
`modules/core.nix`); see
[Defaults, core and users](../architecture/defaults-core-users.md).

## Helix

The home-manager side defines a language server named `tsls` and uses it
for both languages:

| Setting         | Value |
| --------------- | ----- |
| Server `tsls`   | `typescript-language-server --stdio` |
| `typescript`    | servers `[ "tsls" ]`; formatter `prettier --stdin-filepath file.ts` |
| `javascript`    | servers `[ "tsls" ]`; formatter `prettier --stdin-filepath file.js` |

The `--stdin-filepath` value is a fixed placeholder that tells prettier
which parser to use. Prettier's own options come from `~/.prettierrc`,
written by `modules/cli/prettier.nix`.

The aspect also enables `programs.direnv` with `nix-direnv`.

## Key files

| File                           | Purpose                                  |
| ------------------------------ | ---------------------------------------- |
| `modules/devtools/node-ts.nix` | Packages, nix-ld, Helix TS/JS config     |
| `modules/cli/prettier.nix`     | `~/.prettierrc`                          |
| `modules/core.nix`             | Fleet default for `programs.nix-ld`      |
