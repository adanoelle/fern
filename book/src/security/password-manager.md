# Password Manager

> Bitwarden is the password manager: the desktop app for graphical use and
> `rbw` for the terminal. The vault also plays a role in the sops age-key
> recovery story.

## Desktop app

`den.aspects.bitwarden` (`modules/desktop/bitwarden.nix`) installs
`bitwarden-desktop` as a Home Manager package. It is part of the
`desktop-apps` bundle, so it arrives with the `ada-desktop` layer on
graphical hosts only — headless hosts never pull a GUI vault.

## rbw (CLI)

`den.aspects.rbw` (`modules/cli/rbw.nix`) configures
[rbw](https://github.com/doy/rbw), an unofficial Bitwarden CLI client with a
background agent (no re-typing the master password for every lookup). It is
part of the `cli` bundle, so it is available on every host via the base user
layer.

Configuration notes:

- `pinentry` is `pinentry-curses` — headless-safe, since rbw is invoked from
  a terminal anyway
- `base_url` is intentionally unset, which means the official
  `vault.bitwarden.com`. When the homelab vaultwarden exists, pointing the
  whole setup at it is a one-line change in `modules/cli/rbw.nix`

Typical usage:

```bash
rbw login        # once per machine
rbw unlock       # start an agent session
rbw get <entry>  # print a password
rbw generate 32  # generate and store a new password
```

## Role in age-key recovery

The sops [recovery procedures](sops-nix.md#recovery-procedures) depend on the
admin age key (`~/.config/sops/age/keys.txt`) never being lost together with
all registered hosts. The vault holds a copy of the admin age key as a secure
note, giving an off-machine backup that survives full hardware loss: restore
the key from Bitwarden, and every sops-encrypted secret is editable again.

## Key files

| File | Purpose |
|------|---------|
| `modules/desktop/bitwarden.nix` | Bitwarden desktop app (desktop-apps bundle) |
| `modules/cli/rbw.nix` | rbw CLI client + agent (cli bundle) |
| `book/src/security/sops-nix.md` | The recovery story the vault backs up |
