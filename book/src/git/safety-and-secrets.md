# Safety & Secrets

> The safety aspect protects against common Git mistakes: accidental pushes to
> protected branches, force pushes without lease, and irreversible operations.

## Protected branches

The `git-safety` aspect (`modules/git/safety.nix`) installs a pre-push hook
that warns when pushing to protected branches:

- `main`
- `master`
- `prod`
- `production`

When you push to one of these branches, the hook displays a warning and asks for
confirmation. This prevents accidental pushes to branches that should only
receive changes through pull requests.

## Commit validation

A commit-msg hook validates commit messages. It checks for common issues like
empty messages and enforces basic formatting.

## Safe operation aliases

The aliases aspect defines safe alternatives to dangerous Git commands:

| Alias | Expansion | Why safer |
|-------|-----------|-----------|
| `pushf` | `push --force-with-lease` | Refuses to overwrite remote changes you have not fetched |
| `undo` | `reset HEAD~1 --mixed` | Undoes the last commit but keeps changes in the working tree |
| `uncommit` | `reset --soft HEAD~1` | Undoes the last commit but keeps changes staged |

There is no alias for `push --force` -- if you need it, you must type it out.

## Snapshot system

The Claude Code integration (see [Claude Code Integration](claude-code-integration.md))
creates `claude-snapshot/*` tags before each AI-assisted session. These provide
a rollback point if a session goes wrong:

```bash
# List all snapshots
claude-helpers snapshots

# Revert to the most recent snapshot
claude-helpers undo
```

## Secret scanning

Separate from the Git safety aspect, the `secrets-guard` aspect
(`modules/secrets-guard.nix`) installs system-level secret scanning tools:

- **git-secrets** -- Scans commits for AWS keys, passwords, and other secrets.
  Configured with a template directory so every new `git init` gets the hooks
  automatically.
- **trufflehog** -- Scans repository history for high-entropy strings that might
  be credentials.

See [Secret Guard](../security/secret-guard.md) for details.

## Key files

| File | Purpose |
|------|---------|
| `modules/git/safety.nix` | Pre-push hooks, commit validation, safe aliases |
| `modules/git/aliases.nix` | Safe operation aliases (pushf, undo, uncommit) |
| `modules/secrets-guard.nix` | git-secrets, trufflehog |
