# Secret Guard

> git-secrets and trufflehog prevent accidental commits of credentials, API
> keys, and other sensitive data.

The guard module (`nix/modules/secrets-guard.nix`) installs two tools that scan
Git repositories for accidentally committed secrets.

## git-secrets

git-secrets hooks into Git to prevent commits containing patterns that match
known secret formats (AWS keys, private keys, etc.). It is installed system-wide
and configured as a Git template directory:

```nix
programs.git = {
  enable = true;
  config.init.templateDir = "${pkgs.git-secrets}/share/git-secrets";
};
```

This means every new `git init` or `git clone` automatically installs the
git-secrets hooks. The hooks run on `git commit` and reject commits that contain
patterns matching secrets.

### Usage

```bash
# Scan entire history for secrets
git secrets --scan-history

# Add a custom pattern to check
git secrets --add 'PRIVATE_KEY'

# Register AWS patterns
git secrets --register-aws
```

## trufflehog

trufflehog scans repositories for high-entropy strings and known credential
patterns. It goes beyond git-secrets by analyzing the entropy of strings to
detect secrets that do not match predefined patterns.

```bash
# Scan current directory
trufflehog filesystem .

# Scan git history
trufflehog git file://.

# Scan a remote repository
trufflehog git https://github.com/user/repo
```

## Key files

| File                            | Purpose                                     |
| ------------------------------- | ------------------------------------------- |
| `nix/modules/secrets-guard.nix` | git-secrets, trufflehog, template directory |
