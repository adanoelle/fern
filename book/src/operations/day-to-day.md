# Day to Day

> The command recipes for working on this repository: the edit, check,
> test, switch loop; updating inputs; garbage collection; rollback; and
> building this book. Every recipe lives in the `justfile` at the
> repository root, and this page is the only place the book lists them.

**Goes on:** fern, yarrow (the system recipes). The work laptop uses
`home-manager` instead; see [Per machine](#per-machine).

## Setup

`just` and the tools the recipes call (`nixfmt`, `statix`, `deadnix`,
`nvd`, `mdbook`, `flake-checker`, `sops`) come from the flake's dev
shell (`modules/dev.nix`). `.envrc` contains `use flake`, so after a
one-time `direnv allow` the shell activates on `cd`. Without direnv,
run `nix develop`.

`nh` is not in the dev shell. It is installed on NixOS hosts by the
`nh` aspect (`modules/cli/nh.nix`), which is why a `bootstrap` recipe
exists for a machine that does not have it yet.

## The working loop

1. **Work in a git worktree, never on `main`.** Create a branch in its
   own worktree and edit there.
2. **`git add` new files.** A flake only sees files git tracks. A new
   module that is not staged does not exist as far as `nix` is
   concerned: import-tree will not find it and nothing will error.
3. **`just fmt`** formats every `.nix` file.
4. **`just check`** before any rebuild.
5. **`just test`** builds the configuration and activates it without
   making it the boot default. A reboot returns to the previous
   generation.
6. Commit, open a pull request against `main`, merge.
7. **`just switch` from the main checkout** after the merge, so the
   generation that becomes the boot default is built from `main`.

The system recipes pass `.` as the flake, so they build the directory
they are run from. `just test` in a worktree tests that worktree. A
bare `nh os switch` (no path) uses `programs.nh.flake`, which the `nh`
aspect points at `~/src/fern`.

## Recipes

### System

| Recipe | Runs | Effect |
| --- | --- | --- |
| `just switch` | `nh os switch .` | Build, activate, make boot default |
| `just test` | `nh os test .` | Build and activate; not the boot default |
| `just test-trace` | `nh os test . -- --show-trace` | Same, with a full evaluation trace |
| `just dry` | `nh os build . -- --dry-run` | Evaluate and list what would be built or fetched; builds nothing |
| `just rollback` | `sudo nixos-rebuild switch --rollback` | Switch to the previous generation |
| `just bootstrap` | `sudo nixos-rebuild test --flake .#fern` | Test build without `nh` |

`nh os` picks the `nixosConfigurations` entry that matches the
machine's hostname, so the same recipe works on fern and yarrow.
`bootstrap` is the exception: it names `.#fern`. On another host, run
the same command with that host's name.

### Inputs

| Recipe | Runs | Effect |
| --- | --- | --- |
| `just update` | `nix flake update` | Update every input in `flake.lock` |
| `just bump <input>` | `nix flake update <input>` | Update one input, e.g. `just bump herdr` |
| `just flake-health` | `flake-checker` | Report stale or unsupported nixpkgs pins |

### Quality

| Recipe | Runs | Effect |
| --- | --- | --- |
| `just fmt` | `nixfmt` over every `.nix` file | Format in place; skips `.direnv/`, `result/`, `.claude/` |
| `just check` | `nix flake check` | Evaluate every flake output |
| `just statix` | `statix check -i '.claude'` | Lint for anti-patterns |
| `just deadnix` | `deadnix . --exclude <hardware files>` | Find unused bindings; generated `hosts/*/hardware.nix` files are excluded by name |
| `just lint` | `fmt`, `check`, `statix`, `deadnix` in order | Everything above |

### Generations

| Recipe | Runs | Effect |
| --- | --- | --- |
| `just gc` | `nh clean all --keep 5 --keep-since 7d` | Delete old generations and collect garbage |
| `just diff-gen` | `nvd diff` of the two newest `/nix/var/nix/profiles/system-*-link` | Package changes between the last two system generations |

### Book

| Recipe | Runs | Effect |
| --- | --- | --- |
| `just book-serve` | `mdbook serve book --open` | Live-reloading preview |
| `just book-build` | `mdbook build book` | Build to `book/build/` |
| `just book-nix` | `nix build .#book` | Build as a Nix derivation to `./result` |

## Updating inputs

`flake.lock` changes only through `just update` or `just bump`. After
either, run the normal loop: `just check`, `just test`, then
`just diff-gen` to see what moved.

- `just bump <input>` is the cheap option when one tool needs to move.
- A scheduled workflow, `.github/workflows/update-flake-lock.yml`,
  opens a weekly pull request bumping `herdr` and `claude-code`.
  Everything else moves only on demand.
- Bumping the shared `nixpkgs` pin is expensive on the work laptop,
  where many packages then build from source. Read
  [the work laptop page](../machines/work-laptop.md#day-to-day) before
  running `just update` there.
- When a single package is too old in the shared pin, the flake carries
  a separate nixpkgs input that does not follow the shared one, so that
  package comes from the binary cache. These inputs are meant to be
  removed at the next full update; see
  [The Flake & Bootstrap](../architecture/flake-and-bootstrap.md#the-deliberately-non-following-nixpkgs-inputs).

## Garbage collection

There is no `nix.gc` block in this configuration. Cleaning is done by
`nh`, configured in `modules/cli/nh.nix`:

```nix
nixos.programs.nh = {
  enable = true;
  clean = {
    enable = true;
    dates = "weekly";
    extraArgs = "--keep 5 --keep-since 7d";
  };
};
```

A weekly timer therefore runs the same clean that `just gc` runs by
hand. It keeps the five newest generations of each profile, plus
anything created in the last seven days, and deletes the rest before
collecting unreferenced store paths.

`sudo nix-collect-garbage -d` is not an equivalent. It deletes every
old generation, which removes every rollback target. Use `just gc`.

## Rollback

`just rollback` switches to the previous system generation. If the
running system is too broken for that, reboot and pick an older entry
in the systemd-boot menu, then run `just rollback` or fix the
configuration and `just switch`.

A generation activated with `just test` never became the boot default,
so rebooting is enough to leave it.

## Comparing generations

`just diff-gen` compares the two newest system generations with `nvd`:
added, removed and version-changed packages, and the closure size
difference. Run it after `just switch` to confirm an input update did
what was expected.

`nh` shows the same kind of diff before it activates, for `just test`
and `just switch`.

## The book

The book source is `book/src`; `book/book.toml` sets the build
directory to `book/build`. Preview with `just book-serve` while
writing.

Publishing is automatic. `.github/workflows/deploy-docs.yml` runs on
every push to `main` that touches `book/**` (or the workflow file),
runs `mdbook build book` with the latest mdBook release, and deploys
`book/build` to GitHub Pages. It can also be started by hand from the
Actions tab. Nothing needs to be built or committed locally.

`just book-nix` builds the same book through `modules/docs.nix`, with
the mdBook version pinned by the flake rather than "latest".

## Per machine

| Machine | Apply changes with | Notes |
| --- | --- | --- |
| fern, yarrow | `just test`, `just switch` | `nh` infers the host |
| work laptop | `home-manager switch --flake ~/src/fern` | Standalone home; see [its page](../machines/work-laptop.md) |

On the work laptop the system recipes do not apply: there is no NixOS
system to rebuild. `just fmt`, `just check`, `just lint`, the input
recipes and the book recipes work there as on any machine with the dev
shell.

## Key files

| File | Purpose |
| --- | --- |
| `justfile` | Every recipe on this page |
| `modules/dev.nix` | Dev shell providing the recipe tools; formatter |
| `modules/cli/nh.nix` | `nh`, its default flake path and the weekly clean |
| `modules/docs.nix` | `packages.book` and the `book-serve` / `book-build` apps |
| `.github/workflows/deploy-docs.yml` | Book deployment to GitHub Pages |
| `.github/workflows/update-flake-lock.yml` | Weekly bump of the fast-moving inputs |
| `.envrc` | `use flake` for direnv |
