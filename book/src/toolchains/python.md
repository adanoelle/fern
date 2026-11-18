# Python

> Python 3.13 on the NixOS hosts, `uv` from a separate fresh nixpkgs
> input, plus rye, ruff, black, pyright, IPython and JupyterLab for the
> user. Helix uses pyright.

**Goes on:** fern, yarrow, work laptop (through the `devtools` bundle in
the `ada-dev` user layer). The work laptop gets the home-manager side
only.

## What the aspect installs

`den.aspects.python` (`modules/devtools/python.nix`):

| Side         | Packages |
| ------------ | -------- |
| NixOS        | `python313`, `uv` |
| home-manager | `uv`, `rye`, `ruff`, `black`, `pyright`, `python313Packages.ipython`, `python313Packages.jupyterlab` |

The bare interpreter is on the NixOS side only. On the work laptop this
aspect provides `uv` and the tools, and `uv` manages interpreters per
project.

## Why `uv` has its own nixpkgs input

`uv` is not taken from the shared `nixpkgs` pin. It comes from
`inputs.nixpkgs-uv`, a second `nixos-unstable` input declared in
`flake.nix`:

- **Why:** the shared pin carries a `uv` older than some projects
  require (they need 0.13.1 or later, the first release that knows the
  Python 3.15 release).
- **Why a separate input:** `nixpkgs-uv` deliberately does not follow
  `nixpkgs`, so the package substitutes from the binary cache instead
  of forcing a local rebuild.
- **When to drop it:** once `just update` moves the shared pin to
  `uv` 0.13.1 or later, go back to `pkgs.uv` in the aspect and delete
  the input from `flake.nix` (after checking its other user, the
  [PostgreSQL client](data-tools.md)).

## Helix

| Setting          | Value |
| ---------------- | ----- |
| Server `pyright` | `pyright-langserver --stdio` (from the `pyright` package) |
| `python`         | servers `[ "pyright" ]`; formatter `blackd -` |

The configured formatter does not format: `blackd` is black's HTTP
daemon, takes no file argument, and the `black` package here is built
without the `aiohttp` dependency `blackd` needs, so the command exits
with an import error. `black` and `ruff format` work from the shell.

The aspect also sets `programs.zsh.enableCompletion = true`.

## Key files

| File                          | Purpose                                   |
| ----------------------------- | ----------------------------------------- |
| `modules/devtools/python.nix` | Packages, `uv` override, Helix config     |
| `flake.nix`                   | `nixpkgs-uv` input and its removal note   |
