# Defaults & Batteries

> `modules/defaults.nix` applies global defaults to all hosts and users. Den's
> built-in helpers (`define-user`, `primary-user`, `hostname`) handle the
> repetitive wiring that every host needs.

## The defaults file

```nix
# modules/defaults.nix
{ den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";

    includes = [
      den._.define-user
      den._.primary-user
      den._.hostname
    ];
  };
}
```

Everything under `den.default` applies to every host and every user in the
topology, unless explicitly overridden.

## State versions

```nix
nixos.system.stateVersion = "25.11";
homeManager.home.stateVersion = "25.11";
```

NixOS and Home Manager use `stateVersion` to maintain backwards compatibility
for stateful services. Setting it here avoids repeating it in every host and
user aspect. Both use `25.11` (the current NixOS release).

## Den helpers

The three helpers in `includes` are built into den (the `den._` namespace):

### `den._.define-user`

Creates the NixOS user account for each user declared in the topology. Without
this, you would need to manually write:

```nix
users.users.ada = {
  isNormalUser = true;
  # ...
};
```

in every host aspect. `define-user` reads the topology and generates these
declarations automatically.

### `den._.primary-user`

When a host has one user (which both fern and moss do), this helper designates
that user as the primary user. This is used by other den modules to determine
the default user for single-user systems. It makes `users.users.<primary>.home`
and related attributes accessible without hardcoding the username.

### `den._.hostname`

Sets `networking.hostName` from the topology. For the `fern` host, this
generates:

```nix
networking.hostName = "fern";
```

Without it, you would set the hostname in each host aspect manually.

## What defaults replace

In the old architecture, these concerns were scattered:

| Concern | Old location | New location |
|---------|-------------|--------------|
| `system.stateVersion` | `hosts/fern/configuration.nix` | `modules/defaults.nix` |
| `home.stateVersion` | `home-manager.users.ada` block | `modules/defaults.nix` |
| `networking.hostName` | `hosts/fern/configuration.nix` | Automatic via `den._.hostname` |
| User account creation | `nix/modules/users.nix` | Automatic via `den._.define-user` |

The `users.nix` module still exists for additional user configuration (groups,
shell, NetworkManager) beyond what `define-user` generates, but the basic
account creation is now automatic.

## Overriding defaults

A specific host aspect can override any default. For example, if a host needed
a different state version:

```nix
den.aspects.special-host = {
  nixos = { ... }: {
    system.stateVersion = "24.11";  # overrides the default 25.11
  };
};
```

NixOS priority rules apply -- `mkDefault` values can be overridden by direct
assignment, and `mkForce` overrides everything.

## Key files

| File | Purpose |
|------|---------|
| `modules/defaults.nix` | Global defaults (this page) |
| `modules/dendritic.nix` | Den bootstrap (where helpers become available) |
| `modules/users.nix` | Additional user configuration beyond define-user |
