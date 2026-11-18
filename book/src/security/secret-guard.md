# Secret guard

> Every commit is scanned for credentials before it is created. A
> user-level Git `pre-commit` hook runs gitleaks over the staged
> changes and refuses the commit when it finds one. trufflehog is
> available on the NixOS hosts for deeper scans by hand.

**Goes on:** the commit hook is part of the `git-safety` aspect, on
every machine. The `secrets-guard` aspect (trufflehog, system-wide Git)
is NixOS-side and comes with the `workstation` role; see the
[machine pages](../machines/fern.md).

## The commit hook

`modules/git/safety.nix` installs `~/.config/git/hooks/pre-commit`. On
each `git commit` it runs:

```bash
gitleaks git --pre-commit --staged --redact --verbose
```

- Only the staged changes are scanned, so it is fast and does not
  re-report history.
- gitleaks ships rules for common credential formats (cloud keys,
  tokens, private keys). Nothing has to be registered.
- A finding is printed with the secret redacted, and the commit is
  refused.
- If the scan passes, the repository's own `pre-commit` hook runs next,
  if it has one; see
  [Git](../git/git.md#repository-hooks-still-run).

`programs.gitSafety.enableSecretScanHook` (default on) turns it off.

### False positives

| To | Do |
| --- | --- |
| Allow one line | End the line with a `gitleaks:allow` comment |
| Allow one finding permanently | Add its `Fingerprint:` line from the output to `.gitleaksignore` at the repository root |
| Change rules for a repository | Add a `.gitleaks.toml` at the repository root |
| Skip the scan for one commit | `git commit --no-verify` |

`--no-verify` skips every hook for that commit, not only this one.

### What it does not cover

- Commits made before the hook existed. Scan history by hand (below).
- A repository whose local configuration sets its own `core.hooksPath`:
  that replaces the global hooks directory entirely.
- Secrets that match no rule, such as a password in prose.

The first line of defence is still that secrets live in sops
([SOPS-nix](sops-nix.md)) and not in files.

## Scanning by hand

gitleaks is on `PATH` on every machine:

```bash
gitleaks git                  # this repository's whole history
gitleaks dir .                # the working tree as files
```

trufflehog, on the NixOS hosts, can also check whether a credential it
finds is live:

```bash
trufflehog git file://.       # this repository's history
trufflehog filesystem .       # the working tree as files
```

Upstream documentation:
[gitleaks](https://github.com/gitleaks/gitleaks),
[trufflehog](https://github.com/trufflesecurity/trufflehog).

## Key files

| File | Purpose |
| --- | --- |
| `modules/git/safety.nix` | The `pre-commit` hook, the gitleaks package, the hooks directory |
| `modules/secrets-guard.nix` | trufflehog and system-wide Git on NixOS hosts |
| `modules/roles/workstation.nix`, `modules/roles/server.nix` | Where `secrets-guard` is included |
