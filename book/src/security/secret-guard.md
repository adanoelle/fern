# Secret guard

> The `secrets-guard` aspect installs two scanners for credentials in
> Git repositories, git-secrets and trufflehog. As configured, neither
> runs automatically: they are commands to run by hand. The aspect also
> sets a Git template directory intended to install commit hooks, which
> has no effect.

**Goes on:** fern and yarrow, through the `workstation` role (the
`server` role includes it too). It is a NixOS-side aspect, so the work
laptop has neither tool.

## What the aspect sets

`modules/secrets-guard.nix`:

- `git-secrets` and `trufflehog` in `environment.systemPackages`
- `programs.git.enable`, which installs Git system-wide
- `init.templateDir` in the system Git configuration, pointing at
  `share/git-secrets` inside the git-secrets package

## No hooks are installed

The template directory is meant to give every `git init` and
`git clone` the git-secrets commit hooks. It does not, for two
independent reasons.

1. **The directory does not exist.** The nixpkgs git-secrets package
   contains only `bin/git-secrets` and its man page; there is no
   `share/git-secrets`. Git therefore copies nothing into new
   repositories, and prints
   `warning: templates not found in /nix/store/…/share/git-secrets` on
   each `git init` and `git clone`.
2. **Per-repository hooks are bypassed for this user anyway.** The
   `git-safety` aspect sets a global `core.hooksPath` of
   `~/.config/git/hooks`, and Git then ignores each repository's own
   `.git/hooks`. That directory holds one hook, the protected-branch
   `pre-push` check; see [Git](../git/git.md). Hooks written by
   `git secrets --install` into a repository would not run either.

Separately, this configuration registers no patterns, and git-secrets
only matches patterns that have been added to it.

So nothing in this configuration blocks a commit that contains a
secret. Protection against committing one rests on the manual scans
below and on secrets living in sops
([SOPS-nix](sops-nix.md)) instead of in files.

## Manual scans

git-secrets needs patterns first. They are stored in Git configuration:

```bash
git secrets --register-aws --global   # the bundled AWS patterns
git secrets --add --global '<regex>'  # a pattern of your own
git secrets --list --global           # what is registered
```

Then, in a repository:

```bash
git secrets --scan            # all tracked files
git secrets --scan-history    # every revision
```

trufflehog carries its own detectors and needs no setup:

```bash
trufflehog git file://.       # this repository's history
trufflehog filesystem .       # the working tree as files
```

`git secrets --scan` prints each match and exits non-zero when it finds
one. Upstream documentation:
[git-secrets](https://github.com/awslabs/git-secrets),
[trufflehog](https://github.com/trufflesecurity/trufflehog).

## Key files

| File                        | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `modules/secrets-guard.nix` | The two packages and the template directory     |
| `modules/git/safety.nix`    | Sets the global `core.hooksPath` and its `pre-push` hook |
| `modules/roles/workstation.nix`, `modules/roles/server.nix` | Where the aspect is included |
