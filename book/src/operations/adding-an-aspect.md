# Adding an Aspect

> How to add a unit of configuration: create one file under `modules/`,
> stage it, and include it from the bundle, role, host or user layer
> where it belongs. import-tree picks the file up; there is no import
> list to edit.

The vocabulary used here (aspect, side, bundle, role, layer) is defined
in [Aspects & Composition](../architecture/aspects.md).

## 1. Start a worktree

Work on a branch in its own git worktree, never on `main`. The full
loop is in [Day to Day](day-to-day.md#the-working-loop).

## 2. Create the file

One aspect per file, dash-separated, with the aspect name matching the
file name. Pick the directory by what the thing is:

| Directory | Holds |
| --- | --- |
| `modules/` | Host aspects, user layers, and system concerns with no category (`core`, `users`, `secrets`, `tailscale`, `fonts`, ...) |
| `modules/roles/` | Host role bundles |
| `modules/audio/` | PipeWire layers and music software |
| `modules/cli/` | Terminal tools, editors, terminal emulators |
| `modules/cloud/` | Cloud platform tooling |
| `modules/desktop/` | Compositors, greeter, graphical applications |
| `modules/devtools/` | Language toolchains and development services |
| `modules/git/` | The git suite |
| `modules/shells/` | Shells and prompt |
| `modules/foreign/` | Aspects only for a non-NixOS (standalone home) machine |
| `modules/asahi/` | Apple Silicon support for the parked host |

A path with a `_`-prefixed component (`modules/cli/_presenterm/`,
`modules/desktop/_studies/`) is not auto-imported. Use one for data
files and helpers that the aspect's own file reads or imports.

The names `ada-*` are reserved for user layers.

### Templates

A leaf aspect does not use `den`, so its module takes `_:`. Writing
`{ den, ... }:` and not using it fails `just deadnix`.

Home side only, the common case for a tool:

```nix
# modules/cli/my-tool.nix — one line saying what this is
_: {
  den.aspects.my-tool.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.my-tool ];
    };
}
```

System side only:

```nix
# modules/my-service.nix — one line saying what this is
_: {
  den.aspects.my-service.nixos = {
    services.my-service.enable = true;
  };
}
```

Both sides:

```nix
# modules/devtools/my-lang.nix — one line saying what this is
_: {
  den.aspects.my-lang = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.my-lang ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.my-lang-lsp ];
      };
  };
}
```

Take `{ den, ... }:` only when the aspect has `includes` that name
other aspects, and `{ inputs, ... }:` when it needs a flake input.

## 3. Stage it

```bash
git add modules/cli/my-tool.nix
```

A flake only sees tracked files. Until the file is staged, the aspect
does not exist and any reference to `den.aspects.my-tool` fails with
an attribute-missing error.

## 4. Include it

Defining an aspect does nothing until something includes it. Choose
the most shared place where it is still correct:

| The aspect is | Include it from | Example |
| --- | --- | --- |
| A tool every machine should have | Its category bundle (`*/bundle.nix`) | `bat` in `modules/cli/bundle.nix` |
| A system concern every machine of a kind needs | A role in `modules/roles/` | `greetd` in `workstation` |
| A system concern for one machine | The host aspect's `includes` | `monitoring` in `modules/host-fern.nix` |
| User configuration that only some machines want | The host aspect's `provides.to-users.includes` | `obs` on fern, `art` on yarrow |
| For the work laptop only | `modules/user-ada-work.nix` | `thunderbird` |

Three things decide between `includes` and `provides.to-users`:

- An aspect in a host's `includes` contributes only its `nixos` side.
  Its `homeManager` side reaches a user only when the aspect is
  forwarded through `provides.to-users.includes` (or included by a user
  layer). An aspect with both sides that is forwarded has both applied.
- A home side that sets options from a module imported at host level
  must be forwarded by the host that does the import. Niri is the case
  here: `programs.niri.*` exists in Home Manager only on hosts that
  import the niri-flake NixOS module, so `niri` is forwarded from each
  host aspect rather than from the `desktop-apps` bundle.
- The base user layer (`modules/user-ada.nix`) must stay safe on a
  headless machine. GUI and toolchain aspects do not go there.

Before including an aspect in a second place, read the composition
patterns in [Aspects & Composition](../architecture/aspects.md):

- [Diamond includes](../architecture/aspects.md#diamond-includes-den-does-not-dedupe):
  den does not dedupe, so an aspect reachable by two paths needs a
  module `key`, or its list options are set twice.
- [Upstream modules are imported once, at host level](../architecture/aspects.md#upstream-modules-are-imported-once-at-host-level):
  an aspect that would `imports` a third-party NixOS module should
  leave the import to the host aspect.
- [Parametric includes](../architecture/aspects.md#parametric-includes):
  how an aspect reads the host's users instead of naming one.

## 5. Check, test, commit

First add a row for the new aspect to the
[Aspect Index](../reference/aspect-index.md). `just check` fails
without it: the `aspect-index` check compares that page with the
aspects the flake defines.

```bash
just fmt
just check
just test
```

Then commit with a conventional-commit message
(`feat: add my-tool aspect`).

## Adding a bundle

A bundle is an aspect whose job is its `includes`. To start a new
category, create `modules/<category>/bundle.nix` defining
`den.aspects.<category>` and include it from a user layer or role:

```nix
# modules/mycat/bundle.nix — what the category is
{ den, ... }:
{
  den.aspects.mycat = {
    includes = [
      den.aspects.tool-a
      den.aspects.tool-b
    ];
  };
}
```

## Key files

| File | Purpose |
| --- | --- |
| `modules/*/bundle.nix` | Category bundles |
| `modules/roles/*.nix` | Host roles |
| `modules/host-*.nix` | Host aspects: `includes` and `provides.to-users` |
| `modules/user-ada*.nix` | User layers |
| `justfile` | `fmt`, `check`, `deadnix`, `test` |
