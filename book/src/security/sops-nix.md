# SOPS-nix

> Secrets are encrypted with age in `secrets/main.yaml` and decrypted
> automatically at system activation by sops-nix.

SOPS (Secrets OPerationS) encrypts secret values inside YAML files so they can
be committed to Git safely. sops-nix integrates this into NixOS, decrypting
secrets during system activation and placing them at specified paths with
correct ownership and permissions.

## How it works

1. An **age key** is generated and stored at `/var/lib/sops-nix/key.txt`
2. Secrets are encrypted in `secrets/main.yaml` using SOPS with the age public
   key
3. During `nixos-rebuild switch`, sops-nix decrypts each secret and writes it to
   its configured path
4. The decrypted files are owned by the specified user with restricted
   permissions

## Configuration

The secrets module (`nix/modules/secrets.nix`) imports sops-nix and configures
it:

```nix
imports = [ inputs.sops-nix.nixosModules.sops ];

sops.age = {
  generateKey = true;
  keyFile = "/var/lib/sops-nix/key.txt";
};

sops.defaultSopsFile = ../../secrets/main.yaml;

sops.secrets = {
  "ssh_id_ed25519" = {
    path  = "/home/ada/.ssh/github";
    owner = "ada";
    mode  = "0600";
  };
};
```

### What this does

- **`generateKey = true`** -- Creates the age key if it does not exist
- **`keyFile`** -- Location of the private age key
- **`defaultSopsFile`** -- The encrypted YAML file containing all secrets
- **`sops.secrets.*`** -- Individual secret definitions with target path, owner,
  and permissions

The SSH private key for GitHub is decrypted to `/home/ada/.ssh/github` with mode
`0600` (owner read/write only), owned by `ada`.

## Editing secrets

To edit the encrypted secrets file:

```bash
# Set the age key for SOPS
export SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt

# Edit (decrypts in-place, re-encrypts on save)
sops secrets/main.yaml
```

The `sudo` configuration preserves `SOPS_AGE_KEY_FILE` in the environment so you
can edit secrets with elevated privileges.

## Adding a new secret

1. Add the secret value to `secrets/main.yaml` using `sops`
2. Add a `sops.secrets.<name>` entry in `secrets.nix` with the target path
3. Rebuild with `nixos-rebuild switch`

## Key files

| File                        | Purpose                                    |
| --------------------------- | ------------------------------------------ |
| `nix/modules/secrets.nix`   | SOPS-nix configuration, secret definitions |
| `secrets/main.yaml`         | Encrypted secrets file                     |
| `/var/lib/sops-nix/key.txt` | Age private key (not in Git)               |
