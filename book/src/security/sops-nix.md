# SOPS-nix

> Secrets are encrypted with age in `secrets/main.yaml` and decrypted
> automatically at system activation by sops-nix. Each host decrypts with an
> identity derived from its SSH host key; humans edit with a personal admin
> key.

SOPS (Secrets OPerationS) encrypts secret values inside YAML files so they can
be committed to Git safely. sops-nix integrates this into NixOS, decrypting
secrets during system activation and placing them at specified paths with
correct ownership and permissions.

## Identities

There are two kinds of age identities, both registered in `.sops.yaml` at the
repository root:

| Identity      | Private key lives at                     | Used for                    |
| ------------- | ---------------------------------------- | --------------------------- |
| `admin_ada`   | `~/.config/sops/age/keys.txt`            | Editing secrets (humans)    |
| `host_<name>` | `/etc/ssh/ssh_host_ed25519_key` (via ssh-to-age) | Decryption at activation |

Hosts do **not** have a separate age key file. sops-nix converts the machine's
ed25519 SSH host key into an age identity at activation time
(`sops.age.sshKeyPaths` in `modules/secrets.nix`). The matching public
recipient is computed with [ssh-to-age](https://github.com/Mic92/ssh-to-age):

```bash
# from anywhere on the network
ssh-keyscan -t ed25519 <host> | ssh-to-age
# or on the machine itself
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

This means a host's secret-decryption identity exists as soon as the machine
has booted NixOS once — there is no key to generate, distribute, or back up
per host. Reinstalling a machine regenerates its SSH host key, which is a
**key rotation**: re-register the new recipient (see below).

## The `.sops.yaml` registry

`.sops.yaml` declares every recipient as a YAML anchor and maps secret files
to recipients via `creation_rules`:

```yaml
keys:
  - &admin_ada age100dcyxe...
  - &host_fern age1gqxz9qd...

creation_rules:
  - path_regex: ^secrets/main\.yaml$
    key_groups:
      - age: [ *admin_ada, *host_fern ]
```

When `sops` creates or re-keys a file it consults these rules, so you never
pass recipients on the command line. After changing the registry, re-key
existing files:

```bash
sops updatekeys secrets/main.yaml   # or secrets/*.yaml
```

## Editing secrets

Editing uses the admin key and requires no sudo and no environment variables —
sops finds `~/.config/sops/age/keys.txt` automatically:

```bash
sops secrets/main.yaml   # decrypts to $EDITOR, re-encrypts on save
```

Never edit files under `secrets/` by any other means.

## Adding a new secret

1. `sops secrets/main.yaml` — add the key/value
2. Declare it in `modules/secrets.nix` under `sops.secrets.<name>` with its
   target path, owner, and mode
3. `just test`, then `just switch`

## Registering a new machine

**This must happen before the machine's first rebuild with the `secrets`
aspect.** A host that is not a recipient cannot decrypt anything, and
activation fails loudly — by design, so a misregistered machine is caught at
deploy time instead of silently running without its secrets.

```bash
ssh-keyscan -t ed25519 <host> | ssh-to-age   # get the age recipient
# add `- &host_<name> age1...` to .sops.yaml and extend creation_rules
sops updatekeys secrets/*.yaml
git commit -am "chore(secrets): register <host> as sops recipient"
```

The same procedure applies after reinstalling an existing machine (its host
key, and therefore its age identity, changes).

## Recovery procedures

**A word of history:** the original `secrets/main.yaml` in this repository had
a single age recipient whose private key was lost in a reinstall. The file
became permanently undecryptable and had to be recreated from scratch, with
every secret inside it rotated. The rules below exist so that never happens
again.

- **Every file must have at least two recipients**: `admin_ada` plus each host
  that consumes it. Either side can recover the other.
- **Lost/reinstalled host**: nothing is lost. Register the host's new age
  identity and `sops updatekeys` using the admin key.
- **Lost admin key**: while at least one registered host survives, its host
  identity can still decrypt. On that host:
  `sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key` yields an
  age identity that can re-key the files to a fresh admin key. Then rotate:
  generate a new admin key (`age-keygen`), replace `admin_ada` in
  `.sops.yaml`, `sops updatekeys`.
- **Both lost**: the encrypted files are gone for good. Recreate and rotate
  every secret. Keep an offline backup of the admin key so it never comes to
  this.
- **A private key was exposed** (pasted, committed, leaked): treat it as
  burned. Generate a replacement, update `.sops.yaml`, `sops updatekeys`, and
  rotate any secret values the burned key could have decrypted.

## Key files

| File                          | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| `.sops.yaml`                  | Recipient registry + creation rules            |
| `modules/secrets.nix`         | sops-nix configuration, secret definitions     |
| `secrets/main.yaml`           | Encrypted secrets file                         |
| `~/.config/sops/age/keys.txt` | Admin (editing) age key — **keep a backup**    |
| `/etc/ssh/ssh_host_ed25519_key` | Host identity (age via ssh-to-age), not in Git |
