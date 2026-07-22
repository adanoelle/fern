# Homelab (Tailscale & Radicale)

> Fern (the always-on workstation) currently doubles as the homelab. Services
> are exposed **only over the tailnet** — never the LAN — so the blast radius
> of a misconfigured service is "my own devices", not "everything on the
> network". When a dedicated server exists, it takes `server` + `homelab` and
> fern drops the role.

## Why this shape

- **Interim by design.** A homelab role on the workstation beats waiting for
  server hardware; the role boundary (`modules/roles/homelab.nix`) means the
  eventual migration is moving one include, not untangling a host config.
- **Tailnet-only exposure.** `tailscale0` is a trusted firewall interface;
  services bind wide but stay behind the default-deny firewall on every other
  interface. The rule: **never add `allowedTCPPorts` for tailnet-only
  services** — that would punch a LAN hole for something meant to be private.
- **Self-contained aspects.** Each service aspect includes its own
  dependencies (`tailscale`, `secrets`) so it can move to a future server
  host unchanged.

## Tailscale (`modules/tailscale.nix`)

The mesh VPN that *is* the exposure mechanism:

- `services.tailscale.enable` with `openFirewall = true` (UDP 41641, so peers
  connect directly instead of relaying through DERP).
- `networking.firewall.trustedInterfaces = [ "tailscale0" ]` — the one line
  that makes tailnet-only exposure work.
- `services.resolved.enable` (mkDefault) — systemd-resolved gives MagicDNS
  clean split-DNS alongside NetworkManager. Escape hatch without a rebuild:
  `tailscale set --accept-dns=false`.
- `useRoutingFeatures = mkDefault "client"`; the homelab role bumps it to
  `"both"` so subnet-router/exit-node become admin-console toggles, not
  rebuilds.

### Auth is interactive, on purpose

There is deliberately **no** `authKeyFile`/sops wiring. Auth is a one-time
`sudo tailscale up` per host; state persists in `/var/lib/tailscale`. Auth
keys expire and are a standing credential liability — for a tailnet this
small, interactive login is simpler and safer. The host's single topology
user is set as `--operator`, so the tailscale CLI works without sudo.

### The diamond-include `key` pattern

This aspect is reached twice: via the homelab role *and* via the radicale
aspect's own includes. den resolves includes into a plain `imports` tree and
does **not** dedupe diamonds — so the aspect's modules carry explicit module
`key`s (`"den-aspect:tailscale"`, `"den-aspect:tailscale-operator"`), letting
the NixOS module system deduplicate the instances. Without the keys, list
options like `extraSetFlags` get duplicated entries and `tailscale set`
rejects the repeated flag. Reuse this pattern for any aspect that can be
double-included.

## Radicale (`modules/radicale.nix`)

CalDAV/CardDAV (calendar + contacts) server. One URL from every tailnet
device:

```
http://fern.<tailnet>.ts.net:5232/
```

- **Binds `0.0.0.0:5232` on purpose.** Exposure is controlled by the
  firewall, not the bind address — binding the tailscale IP instead would
  race `tailscaled` at boot. No `allowedTCPPorts`, so the LAN never sees it.
- **Auth**: bcrypt htpasswd via sops. Radicale ≥ 3.5 requires an explicit
  `auth.type` (the default became `denyall`), so it is pinned to `htpasswd`
  with `htpasswd_encryption = "bcrypt"`.
- **Secret**: `sops.secrets.radicale_htpasswd`, owned by the radicale user,
  mode 0400, with `restartUnits` so a rotated credential restarts the
  service. Add/edit the line via `sops secrets/main.yaml`.
- **Storage**: defaults — collections in `/var/lib/radicale/collections`
  (StateDirectory), `owner_only` rights. TODO: fold into a future backup
  aspect.
- **HTTPS if needed**: iOS CalDAV sometimes nags about plaintext; front it
  with `tailscale serve` — a runtime toggle, no Nix change.

## The homelab role (`modules/roles/homelab.nix`)

Pure composition:

```nix
den.aspects.homelab = {
  includes = [ den.aspects.tailscale den.aspects.radicale ];
  nixos.services.tailscale.useRoutingFeatures = "both";
};
```

fern carries it via `modules/host-fern.nix`. A future service = new
self-contained aspect + one include here.

## Operations

- **Secrets before switch**: the host must be a sops recipient and the
  `radicale_htpasswd` key must exist in `secrets/main.yaml` *before*
  rebuilding — sops activation fails loudly otherwise (by design). See
  [SOPS-nix](../security/sops-nix.md).
- **New machine joins the tailnet**: include the `tailscale` aspect, rebuild,
  then one interactive `sudo tailscale up`.
- **Future**: backup aspect for radicale collections; dedicated server host
  takes `server` + `homelab`.

## Key files

| File | Purpose |
|------|---------|
| `modules/tailscale.nix` | Tailscale client + trusted interface + operator |
| `modules/radicale.nix` | Radicale server + sops htpasswd |
| `modules/roles/homelab.nix` | Role composition + routing features |
| `modules/host-fern.nix` | Includes the homelab role today |
| `.sops.yaml` | Recipient registry for the htpasswd secret |
