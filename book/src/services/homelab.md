# Homelab: Tailscale and Radicale

> fern, the always-on workstation, doubles as the homelab. Services are
> exposed only over the tailnet, never the LAN, so a misconfigured
> service is reachable from the owner's own devices and nothing else.
> When a dedicated server exists it takes the `server` and `homelab`
> roles and fern drops `homelab`.

**Goes on:** fern (the `homelab` role: Tailscale with routing features,
plus Radicale). yarrow includes `tailscale` directly as a plain client
and runs no services.

## Why this shape

- **A role boundary.** Everything the service host needs is in
  `modules/roles/homelab.nix`, so moving the homelab to another machine
  is moving one include.
- **Tailnet-only exposure.** `tailscale0` is a trusted firewall
  interface. Services bind wide and stay behind the default-deny
  firewall on every other interface. The rule that follows: never add
  `allowedTCPPorts` for a tailnet-only service, because that opens it
  to the LAN.
- **Self-contained aspects.** Each service aspect includes its own
  dependencies (`tailscale`, `secrets`), so it can move to another host
  unchanged.

## Tailscale

`modules/tailscale.nix`.

| Setting                                | Value                  | Why                          |
| -------------------------------------- | ---------------------- | ---------------------------- |
| `services.tailscale.enable`            | `true`                 |                              |
| `services.tailscale.openFirewall`      | `true`                 | UDP 41641, so peers connect directly instead of through relays |
| `networking.firewall.trustedInterfaces` | `[ "tailscale0" ]`    | what makes tailnet-only exposure work |
| `services.resolved.enable`             | `mkDefault true`       | split DNS for MagicDNS alongside NetworkManager |
| `services.tailscale.useRoutingFeatures` | `mkDefault "client"`  | the `homelab` role raises it to `"both"` |
| `services.tailscale.extraSetFlags`     | `--operator=<user>`    | the host's topology user can run the `tailscale` CLI without sudo |

If DNS misbehaves, `tailscale set --accept-dns=false` turns MagicDNS
off without a rebuild.

The operator is the host's single topology user, the same single-user
assumption `modules/secrets.nix` makes.

### Authentication is interactive

There is deliberately no `authKeyFile` and no sops wiring. Each host is
authenticated once with `sudo tailscale up`, and the state persists in
`/var/lib/tailscale`. The module's reasoning: auth keys expire and are a
standing credential, which is not worth it for a tailnet this small.

### The diamond-include `key` pattern

On fern the `tailscale` aspect is reached twice: through the `homelab`
role and through the `radicale` aspect's own includes. den resolves
includes into a plain `imports` tree and does not deduplicate, so the
aspect's NixOS modules carry explicit module keys
(`"den-aspect:tailscale"`, `"den-aspect:tailscale-operator"`) and the
NixOS module system collapses the two instances into one. Without the
keys, list options such as `extraSetFlags` and `trustedInterfaces` get
repeated entries, and `tailscale set` rejects a repeated flag.

`secrets` and `audio` use the same pattern for the same reason. Use it
for any aspect that can be included by two paths; the general
discussion is in [Aspects](../architecture/aspects.md).

## Radicale

`modules/radicale.nix`. A CalDAV and CardDAV server for calendars and
contacts, reachable from every tailnet device at:

```
http://fern.<tailnet>.ts.net:5232/
```

- **Binds `0.0.0.0:5232` on purpose.** Exposure is controlled by the
  firewall, not the bind address; binding the Tailscale address instead
  would race `tailscaled` at boot. There is no `allowedTCPPorts` entry,
  so the LAN cannot reach it.
- **Authentication** is an htpasswd file with bcrypt hashes. `auth.type`
  is set explicitly because, as the module notes, Radicale 3.5 and later
  default to denying everyone.
- **The secret** is `sops.secrets.radicale_htpasswd`, declared in the
  aspect itself: owned by the radicale user, mode 0400, with
  `restartUnits` so a changed credential restarts the service. Edit the
  line with `sops secrets/main.yaml`; see [SOPS-nix](../security/sops-nix.md).
- **Storage and rights** are Radicale's defaults: collections under
  `/var/lib/radicale/collections`, `owner_only` rights. Nothing backs
  the collections up yet; the module carries a TODO for a backup aspect.
- **HTTPS**, if a client insists on it, can be added at runtime with
  `tailscale serve`; no Nix change is involved.

## The `homelab` role

`modules/roles/homelab.nix` is composition plus one setting: it
includes `tailscale` and `radicale`, and sets
`services.tailscale.useRoutingFeatures = "both"`. That turns IP
forwarding on now, so acting as a subnet router or exit node later is a
toggle in the Tailscale admin console and not a rebuild.

A new service is a new self-contained aspect plus one include in the
role.

One is drafted and not yet included: the [Tangled Knot](knot.md), the
first service that also needs a public edge in front of the tailnet.

## Operations

- **Secrets come first.** The host must be a sops recipient and the
  `radicale_htpasswd` key must exist in `secrets/main.yaml` before the
  rebuild that enables Radicale; activation fails otherwise. See
  [SOPS-nix](../security/sops-nix.md).
- **Joining the tailnet.** Include the `tailscale` aspect in the host
  aspect (as `modules/host-yarrow.nix` does), rebuild, then run
  `sudo tailscale up` once.

## Key files

| File                        | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `modules/tailscale.nix`     | Tailscale client, trusted interface, operator   |
| `modules/radicale.nix`      | Radicale server and its htpasswd secret         |
| `modules/roles/homelab.nix` | Role composition and routing features           |
| `modules/roles/server.nix`  | The headless role a dedicated server would take |
| `modules/host-fern.nix`     | Includes the `homelab` role                     |
| `modules/host-yarrow.nix`   | Includes `tailscale` as a plain client          |
| `.sops.yaml`                | Recipients for the htpasswd secret              |
