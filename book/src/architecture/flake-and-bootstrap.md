# The Flake & Bootstrap

> How the repository turns into flake outputs: `flake.nix` hands every
> file under `modules/` to flake-parts through import-tree,
> `modules/dendritic.nix` switches den on, and a few small modules supply
> the package set, the dev shell and the book. Also the directory-level
> map of where things live.

**Goes on:** every host

## `flake.nix`

The whole outputs section is one line: `flake-parts.lib.mkFlake` over
`import-tree ./modules`. There is no import list and nothing else to
edit when a module is added. `flake.nix` is otherwise only inputs, in
these groups:

| Group | Inputs | Used for |
| ----- | ------ | -------- |
| Base | `nixpkgs` (nixos-unstable), `home-manager` | Everything |
| Framework | `flake-parts`, `import-tree`, `den` | The dendritic pattern itself |
| Desktop shell | `garden-shell`, `niri` | The `garden` aspect namespace and palette; the niri-flake modules |
| Hardware | `nixos-hardware`, `nixos-apple-silicon`, `musnix` | Per-model quirks, Asahi support, realtime audio |
| Overlays and packages | `rust-overlay`, `claude-code`, `herdr`, `zen-browser`, `devenv` | Packages nixpkgs does not carry or carries too old |
| Secrets | `sops-nix` | See [sops-nix](../security/sops-nix.md) |
| Foreign distro | `nixgl` (and `flake-utils`, which it follows) | GL wrappers for the standalone home on the work laptop |
| Single-package pins | `nixpkgs-thunderbird`, `nixpkgs-uv` | See below |

Almost every input sets `inputs.nixpkgs.follows = "nixpkgs"` so there is
one nixpkgs in the lock.

### The deliberately non-following nixpkgs inputs

`nixpkgs-thunderbird` and `nixpkgs-uv` are second and third copies of
nixos-unstable that do **not** follow the shared pin. Each exists to
take one or two packages at a newer version than the shared pin carries:

| Input | Package | Consumed in |
| ----- | ------- | ----------- |
| `nixpkgs-thunderbird` | Thunderbird | `modules/desktop/thunderbird.nix` |
| `nixpkgs-uv` | uv | `modules/devtools/python.nix` |
| `nixpkgs-uv` | PostgreSQL (client) | `modules/cli/postgres.nix` |

The reason is cost. Bumping the shared `nixpkgs` moves every package at
once and rebuilds everything the overlays touch locally. A separate,
unmodified nixpkgs is evaluated without overlays, so the one package
substitutes straight from cache.nixos.org.

They are temporary. Once `just update` has moved the shared pin past the
version each comment asks for, delete the input from `flake.nix` and the
package override in the consuming aspect (each is marked `TEMPORARY`).
To add another, reuse the pattern: a non-following input, and
`inputs.<name>.legacyPackages.${system}.<pkg>` in the one aspect that
needs it.

`flake.lock` changes only through `just update` or `just bump <input>`;
see [Day to Day](../operations/day-to-day.md).

## import-tree

`import-tree ./modules` returns a flake-parts module that imports every
`.nix` file below `modules/`, recursively. Paths with a component
starting with `_` are skipped (see
[Aspects & Composition](aspects.md#the-_-prefix)). Two practical
consequences:

- Every file must be a flake-parts module, even if it only sets
  `den.aspects.*`.
- Flakes only see files git knows about. A new module has to be
  `git add`-ed before `nix flake check` or a rebuild will find it.

## `modules/dendritic.nix`

The den bootstrap. Stanza by stanza:

| Stanza | Effect |
| ------ | ------ |
| `imports = [ inputs.den.flakeModule … ]` | Loads den into flake-parts, which provides the `den.*` options and builds `nixosConfigurations` and `homeConfigurations` from the topology |
| `ctx.user.includes = [ den._.mutual-provider ]` | Enables host-to-user forwarding through `provides.to-users` |
| `ctx.home.includes = [ den._.mutual-provider ]` | The same routing for standalone homes: the home's aspect may declare `provides."<hostname>"` layers. Used by the work laptop |
| `ctx.hm-host.nixos.home-manager = { … }` | Home Manager settings on NixOS hosts: `useGlobalPkgs` (users share the system package set, overlays included), `useUserPackages`, `backupFileExtension = "backup"`, and `inputs` passed to every Home Manager module |
| `schema.user.classes = [ "homeManager" ]` | Users are configured through Home Manager by default |

Home Manager is therefore used in two ways. On fern and yarrow it is a
NixOS module: one rebuild produces system and user environment together
and there is no separate `home-manager switch`. On the work laptop it is
standalone: `den.homes` in `modules/hosts.nix` produces a
`homeConfigurations` output, and because that path does not go through
`hm-host`, the entry supplies its own `pkgs` and passes `inputs` itself
(the comments there explain both).

How aspects are then routed to hosts and users is described in
[Aspects & Composition](aspects.md#what-reaches-where).

## `modules/garden.nix`

One line: `inputs.den.namespace "garden" [ inputs.garden-shell ]`. It
imports the aspects exported by the garden-shell flake under the name
`garden`, so modules can take a `garden` argument next to `den` and
include `garden.terminal` or `garden.shell`. What those contain is in
[The Garden Shell](../desktop/garden.md). garden-shell's palette is also
read directly as `inputs.garden-shell.lib.palette` by several aspects.

## Overlays: one list, two package sets

There are two package sets, and both take their overlays from one file,
`modules/_lib/overlays.nix`.

| | `modules/core.nix` | `modules/overlays.nix` |
| - | ------------------ | ---------------------- |
| Configures | `nixpkgs.overlays` and `allowUnfree` of each NixOS host | the flake-parts `perSystem` `pkgs` |
| Used by | fern, yarrow (system, and Home Manager through `useGlobalPkgs`) | the dev shell, the book package, and the work laptop's standalone home, which reuses it via `withSystem` in `modules/hosts.nix` |

The shared list holds rust-overlay, claude-code and an inline overlay
that sets `pkgs.herdr` from the `herdr` input. Add a new overlay there,
not in either consumer, so an aspect sees the same package on NixOS as
on the standalone home.

`modules/overlays.nix` also sets the flake's `systems` (x86_64-linux and
aarch64-linux).

## perSystem outputs

| Output | Defined in | Contents |
| ------ | ---------- | -------- |
| `devShells.default` | `modules/dev.nix` | `just`, `mdbook`, `nixfmt`, `statix`, `deadnix`, `flake-checker`, `nix-output-monitor`, `nvd`, and the secrets tools `sops`, `ssh-to-age`, `age`. Entered automatically through `.envrc` |
| `formatter` | `modules/dev.nix` | `nixfmt` (so `nix fmt` works) |
| `packages.book` | `modules/docs.nix` | This book, built with mdBook as a derivation |
| `apps.book-serve`, `apps.book-build` | `modules/docs.nix` | `nix run .#book-serve` / `.#book-build`, run from the repository root |

The `just` recipes that wrap these are listed in
[Day to Day](../operations/day-to-day.md).

## Repository map

Directory level only; individual aspects are in the
[Aspect Index](../reference/aspect-index.md).

| Path | Contents |
| ---- | -------- |
| `flake.nix`, `flake.lock` | Inputs and their pins |
| `justfile` | Command recipes |
| `hosts/<name>/hardware.nix` | Generated hardware configuration, one per machine. Nothing else lives here; never edited by hand |
| `modules/` (top level) | Bootstrap, topology, defaults, host aspects, user layers, and single-file system aspects |
| `modules/roles/` | Host roles |
| `modules/cli/`, `modules/shells/`, `modules/git/` | The base user layer's bundles |
| `modules/desktop/` | Compositors, greeter, desktop applications |
| `modules/devtools/`, `modules/cloud/` | Toolchains and development services |
| `modules/audio/` | Audio stack, studio tuning, music software |
| `modules/foreign/` | Aspects for running on a non-NixOS distro (the work laptop) |
| `modules/asahi/` | Apple Silicon boot and graphics (moss) |
| `secrets/`, `.sops.yaml` | Encrypted secrets and their recipients; edit only with `sops` |
| `book/` | This book |
| `.github/workflows/` | Book deployment and the scheduled flake-lock update |

### Where do I find...

| Looking for | Look in |
| ----------- | ------- |
| Which machines exist and who uses them | `modules/hosts.nix` |
| What one machine is made of | `modules/host-<name>.nix`, then [machines](../machines/fern.md) |
| What a kind of machine gets | `modules/roles/` |
| What the user gets everywhere | `modules/user-ada.nix` |
| What the user gets only on some machines | `modules/user-ada-*.nix` and each host's `provides.to-users` |
| A specific tool or application | `modules/<category>/<name>.nix`; `grep -rn "aspects.<name>" modules/` finds the definition and its includers |
| User accounts, groups, sshd | `modules/users.nix` |
| Nix settings, timezone, fleet defaults | `modules/core.nix` |
| The package set and overlays | `modules/core.nix` (NixOS), `modules/overlays.nix` (everything else) |
| den wiring | `modules/dendritic.nix`, `modules/defaults.nix` |

## Key files

| File | Role |
| ---- | ---- |
| `flake.nix` | Inputs; `mkFlake` over `import-tree ./modules` |
| `modules/dendritic.nix` | den bootstrap |
| `modules/garden.nix` | `garden` namespace import |
| `modules/overlays.nix` | `systems`, perSystem `pkgs` |
| `modules/core.nix` | NixOS-side overlays |
| `modules/dev.nix` | Dev shell and formatter |
| `modules/docs.nix` | Book package and apps |
