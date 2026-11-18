# SOPS-nix

> Secrets are encrypted with age in `secrets/main.yaml`, committed to
> the repository, and decrypted at system activation by sops-nix. Each
> host decrypts with an identity derived from its SSH host key; people
> edit with a personal admin key. This page is the reference for
> registering a host as a recipient.

**Goes on:** fern and yarrow, through the `workstation` role (the
`secrets` aspect, NixOS side). The work laptop has no sops integration.
yarrow is not yet a recipient: it is registered during its install.

## Identities

Both kinds of age identity are registered in `.sops.yaml` at the
repository root.

| Identity      | Private key                                   | Used for                 |
| ------------- | --------------------------------------------- | ------------------------ |
| `admin_ada`   | `~/.config/sops/age/keys.txt`                 | editing secrets          |
| `host_<name>` | `/etc/ssh/ssh_host_ed25519_key`, converted by ssh-to-age | decryption at activation |

A host has no separate age key file. sops-nix converts the machine's
ed25519 SSH host key into an age identity at activation
(`sops.age.sshKeyPaths` in `modules/secrets.nix`). The matching public
recipient is computed with
[ssh-to-age](https://github.com/Mic92/ssh-to-age) from the public half
of the host key.

Two consequences:

- There is no per-host key to distribute or back up, but the host key
  must exist, and be registered, before the first build that includes
  the `secrets` aspect.
- Reinstalling a machine without preserving `/etc/ssh` gives it a new
  host key. That is a key rotation: register the new recipient.

`sops`, `ssh-to-age` and `age` are in the repository's devShell
(`modules/dev.nix`).

## The `.sops.yaml` registry

`.sops.yaml` declares each recipient as a YAML anchor under `keys` and
maps secret files to recipients under `creation_rules`. `sops` consults
the rules whenever it creates or re-keys a file, so recipients are
never passed on the command line. After any change to the registry,
re-key the existing files:

```bash
sops updatekeys secrets/main.yaml
```

Every file must list at least two recipients: `admin_ada` and each host
that consumes it. Either side can then recover the other (see
[Recovery procedures](#recovery-procedures)).

## What is declared

| Secret              | Declared in            | Delivered to                             |
| ------------------- | ---------------------- | ---------------------------------------- |
| `ssh_id_ed25519`    | `modules/secrets.nix`  | `~/.ssh/github` of the host's user, mode 0600 |
| `radicale_htpasswd` | `modules/radicale.nix` | the radicale user, mode 0400; restarts the service on change |

The user-owned secret takes its owner and path from the den topology,
not a hard-coded name. sops-nix gives a secret one owner and one path,
so this assumes one user per host.

A service aspect declares its own secret next to the service that reads
it, as Radicale does, so the aspect stays self-contained; see
[Homelab](../services/homelab.md).

`sops.gnupg.sshKeyPaths` is set to the empty list so that sops-nix does
not import RSA host keys into a GPG keyring.

## Editing and adding secrets

Editing uses the admin key, with no sudo and no environment variables:

```bash
sops secrets/main.yaml   # decrypts into $EDITOR, re-encrypts on save
```

Never edit files under `secrets/` any other way.

To add a secret:

1. `sops secrets/main.yaml` and add the key and value.
2. Declare `sops.secrets.<name>` (path, owner, mode) in the aspect that
   consumes it, or in `modules/secrets.nix` if it is not tied to one
   service.
3. Test, then switch ([Day to day](../operations/day-to-day.md)).

The key must exist in the encrypted file before the switch; a declared
secret that is missing makes activation fail.

## Registering a new machine

**Do this before the machine's first build with the `secrets` aspect.**
A host that is not a recipient cannot decrypt anything and activation
fails. That is intended: a misregistered machine is caught at deploy
time instead of running without its secrets.

The steps are the same in every case; only how the recipient is
obtained differs.

### 1. Get the host's age recipient

**A machine that is already running** (an existing install, or one
reinstalled and booted):

```bash
ssh-keyscan -t ed25519 <host> | ssh-to-age       # over the network
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub   # or on the machine
```

**A fresh install.** `ssh-keyscan` needs a running sshd, and a machine
that has never booted has no host key at all, yet the very first
`nixos-install` already needs one that is registered. Create the key
by hand in the target filesystem, from the installer, before
installing:

```bash
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -C root@<name> -f /mnt/etc/ssh/ssh_host_ed25519_key
nix shell nixpkgs#ssh-to-age -c ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

The installed system finds the key at `/etc/ssh/ssh_host_ed25519_key`
and uses it. [Installing yarrow](../machines/installing-yarrow.md) is
the worked example, including how the registration commit reaches the
new machine.

Either way the output is one `age1…` line. It is a public key and can
be copied by any convenient means.

### 2. Register it

On a machine that holds the admin key:

1. In `.sops.yaml`, add `- &host_<name> age1…` under `keys` and add
   `*host_<name>` to the rule of every file the host must read.
2. `sops updatekeys secrets/main.yaml`
3. Commit `.sops.yaml` and the re-keyed file, and make sure the new
   host builds from that commit.

The rest of bringing up a machine is on
[Adding a host](../operations/adding-a-host.md).

## Recovery procedures

- **Lost or reinstalled host.** Nothing is lost. Register the host's new
  recipient and run `sops updatekeys` with the admin key.
- **Lost admin key.** While one registered host survives, its identity
  can still decrypt. On that host,
  `sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key`
  prints an age identity that can re-key the files to a new admin key:
  generate one with `age-keygen`, replace `admin_ada` in `.sops.yaml`,
  then `sops updatekeys`.
- **Both lost.** The encrypted files cannot be recovered. Recreate them
  and rotate every secret. Keep a backup of the admin key off the
  machine so it never comes to this.
- **A private key was exposed.** Treat it as burned: generate a
  replacement, update `.sops.yaml`, run `sops updatekeys`, and rotate
  every secret value the exposed key could decrypt.

## Key files

| File                            | Purpose                                     |
| ------------------------------- | ------------------------------------------- |
| `.sops.yaml`                    | Recipient registry and creation rules       |
| `modules/secrets.nix`           | sops-nix import, host identity, user SSH key |
| `modules/radicale.nix`          | A service-owned secret                      |
| `secrets/main.yaml`             | The encrypted secrets                       |
| `~/.config/sops/age/keys.txt`   | Admin age key; not in Git, keep a backup    |
| `/etc/ssh/ssh_host_ed25519_key` | Host identity; not in Git                   |
