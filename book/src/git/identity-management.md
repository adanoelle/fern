# Identity Management

> The identities aspect supports multiple Git identities switched automatically
> by directory, each with its own name, email, and SSH signing key.

## How it works

The `git-identities` aspect (`modules/git/identities.nix`) defines
`programs.gitIdentities` options that generate Git `includeIf` directives. When
you `cd` into a project under `/home/ada/personal/`, Git automatically uses your
personal identity. Under `/home/ada/work/`, it uses your work identity.

## Configuration

Identities are set in the user aspect:

```nix
# modules/user-ada.nix (excerpt)
programs.gitIdentities.identities = {
  personal = {
    name = "adanoelle";
    email = "adanoelleyoung@gmail.com";
    directory = "/home/ada/personal/";
    signingKey = "/home/ada/.ssh/github";
  };
  work = {
    name = "youngt0dd";
    email = "todd.young@pinnaclereliability.com";
    directory = "/home/ada/work/";
    signingKey = "/home/ada/.ssh/github-work";
    sshCommand = "ssh -i /home/ada/.ssh/github-work -o IdentitiesOnly=yes";
  };
};
```

## What gets generated

For each identity, the aspect generates a Git `includeIf` block in
`~/.gitconfig`:

```ini
[includeIf "gitdir:/home/ada/personal/"]
  path = ~/.config/git/identity-personal

[includeIf "gitdir:/home/ada/work/"]
  path = ~/.config/git/identity-work
```

Each identity config file (`~/.config/git/identity-personal`, etc.) sets:

```ini
[user]
  name = adanoelle
  email = adanoelleyoung@gmail.com
  signingKey = /home/ada/.ssh/github

[gpg "ssh"]
  allowedSignersFile = ~/.config/git/allowed_signers
```

When a work identity specifies `sshCommand`, the identity config also includes:

```ini
[core]
  sshCommand = ssh -i /home/ada/.ssh/github-work -o IdentitiesOnly=yes
```

This ensures the correct SSH key is used for both signing and authentication.

## Checking identity

The `gid` alias (from the aliases aspect) shows the current Git identity:

```bash
$ gid
Identity: personal
  Name:  adanoelle
  Email: adanoelleyoung@gmail.com
  Key:   /home/ada/.ssh/github
```

## SSH allowed signers

The aspect also generates an `allowed_signers` file that maps email addresses to
their SSH public keys. This enables Git to verify signatures on commits from
both identities.

## Key files

| File | Purpose |
|------|---------|
| `modules/git/identities.nix` | Identity configuration and includeIf generation |
| `modules/user-ada.nix` | Where identities are defined |
