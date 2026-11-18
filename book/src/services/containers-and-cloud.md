# Containers and cloud tooling

> The NixOS machines run the ordinary root Docker daemon, with the user
> in the `docker` group. The work laptop cannot own a system daemon, so
> it runs rootless Docker as a user service instead. AWS and
> infrastructure tooling is a separate system aspect that arrives with
> the `dev-machine` role.

**Goes on:** `docker` and `aws-cli` on fern and yarrow; `docker-rootless`
on the work laptop only.

| Aspect            | File                                  | Side  | Reached through                     |
| ----------------- | ------------------------------------- | ----- | ----------------------------------- |
| `docker`          | `modules/devtools/docker.nix`         | nixos | the `workstation` role, and the `devtools` bundle |
| `docker-rootless` | `modules/foreign/docker-rootless.nix` | home  | `ada-work` (`modules/user-ada-work.nix`) |
| `aws-cli`         | `modules/cloud/aws-cli.nix`           | nixos | the `dev-machine` role              |

## Docker on NixOS: `docker`

`virtualisation.docker` is enabled with the daemon flag
`--experimental` and BuildKit turned on in the daemon settings.

**This is the root daemon, not rootless.** Access is by membership of
the `docker` group, which is equivalent to root on the machine. The
group is not granted in this aspect: `modules/users.nix` adds it to
every topology user of a host on which `virtualisation.docker.enable`
is true. See
[Defaults, core and users](../architecture/defaults-core-users.md).

Installed alongside, system-wide: `docker-compose`, `docker-buildx`,
`dive`, `hadolint`, `ctop`, `lazydocker`, `trivy`, `stern`.

### Two include paths

The aspect is included by the `workstation` role and again by the
`devtools` bundle, which reaches the host through the `ada-dev` user
layer. Its module has no dedup `key` (compare
[the pattern on the homelab page](homelab.md#the-diamond-include-key-pattern)),
so on fern and yarrow it is applied twice. As evaluated,
`virtualisation.docker.extraOptions` is `--experimental --experimental`
and each of the tool packages above appears twice in
`environment.systemPackages`. The other Docker options are not lists
and are unaffected. `modules/roles/dev-machine.nix` describes this
hazard in its header comment.

## Rootless Docker on the work laptop: `docker-rootless`

A standalone home-manager configuration cannot set
`virtualisation.docker`, so this aspect runs the daemon entirely as the
user:

- installs the `docker` package (client, and `dockerd-rootless`)
- defines a systemd **user** service `docker` running
  `dockerd-rootless`, wanted by `default.target` and restarted whenever
  it exits
- sets `DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock`, because the
  socket is in the user runtime directory and not at
  `/var/run/docker.sock`

No `docker` group is involved. The companion tools from the NixOS
aspect (compose, buildx and the rest) are not part of this one.

Some pieces cannot come from the Nix store and are set up once on the
Ubuntu side as root: setuid `newuidmap`/`newgidmap` (the service's
`PATH` deliberately falls through to `/usr/local/bin` and `/usr/bin`
for them), subordinate uid and gid ranges for the user, and an AppArmor
profile allowing user namespaces for the Nix-store `rootlesskit`. The
checklist is on [the work laptop page](../machines/work-laptop.md).

```bash
systemctl --user status docker    # the daemon
docker info                       # reports rootless under Security Options
```

## AWS and infrastructure tooling: `aws-cli`

A system-side package set, with no configuration beyond one variable:

| Package                      | Area                           |
| ---------------------------- | ------------------------------ |
| `awscli2`, `aws-vault`, `ssm-session-manager-plugin` | CLI, credentials, sessions |
| `aws-sam-cli`, `eksctl`      | serverless and EKS             |
| `terraform`, `tfsec`, `cfn-nag` | infrastructure as code and its linters |
| `aws-nuke`, `steampipe`      | account cleanup and querying   |

`AWS_SDK_LOAD_CONFIG=1` is set in `environment.variables`; it is listed
with the others in
[Environment variables](../reference/environment-variables.md).

Because the aspect is NixOS-side, the work laptop does not receive it
even though it takes the `ada-dev` layer. No credentials or profiles
are managed by this repository.

## Key files

| File                                  | Purpose                                 |
| ------------------------------------- | --------------------------------------- |
| `modules/devtools/docker.nix`         | Docker daemon, BuildKit, container tools |
| `modules/users.nix`                   | `docker` group membership               |
| `modules/roles/workstation.nix`       | First include path for `docker`         |
| `modules/devtools/bundle.nix`         | Second include path for `docker`        |
| `modules/foreign/docker-rootless.nix` | Rootless daemon as a user service       |
| `modules/cloud/aws-cli.nix`           | AWS and infrastructure tools            |
| `modules/roles/dev-machine.nix`       | Includes `aws-cli`                      |
