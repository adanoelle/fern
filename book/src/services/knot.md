# Tangled Knot

> A knot is the self-hosted half of [Tangled](https://tangled.org): it
> stores git repositories, and the issues and pull requests that belong
> to them, and serves them over HTTPS and SSH. The web interface stays
> at tangled.org. Unlike every other homelab service the knot has to be
> reachable from the internet, so it is the one service with a public
> edge in front of it.

**Goes on:** no host yet. The `knot` aspect is a draft that no role
includes; [Enabling it](#enabling-it) lists what has to exist first. It
is written to join the `homelab` role described in
[Homelab](homelab.md).

## Why this shape

- **The host still opens nothing.** The tailnet-only rule from
  [Homelab](homelab.md) holds. The knot binds wide and sits behind the
  default-deny firewall, reachable through `tailscale0` and nothing
  else. A separate machine with a public address does the public part.
- **The hostname is the identity.** A knot is known as
  `did:web:<hostname>`, and clone URLs and record references embed it.
  The name therefore belongs to a domain, not to a machine or a
  tailnet: when the homelab moves to a dedicated server, the edge is
  pointed at the new host and nothing else changes. This is also why
  Tailscale Funnel is not used; it can only serve a `ts.net` name.
- **The module's firewall default is turned off.** Tangled's NixOS
  module sets `openFirewall = true` and would open both listen ports on
  every interface. The aspect sets it to `false`.
- **SHA-1 repositories.** The knot creates SHA-256 repositories by
  default, and those cannot push to or fetch from a SHA-1 host. The
  repositories here are mirrored with GitHub, so the aspect sets
  `git.object_format = "sha1"`. The setting applies to repositories
  created after it is set, so it has to be right before the first one.

## What runs here

`modules/knot.nix`. One service, `knot-rs.service`, from the `tangled`
flake input: a single binary with its own SSH server and no database.

| Listener | Address        | Carries                                |
| -------- | -------------- | -------------------------------------- |
| HTTP     | `0.0.0.0:5555` | the XRPC API, git over HTTP, LFS       |
| SSH      | `[::]:2222`    | git and LFS over the knot's own server |

Neither port has an `allowedTCPPorts` entry. The host's own OpenSSH
keeps port 22.

State is under `/var/lib/knot`:

| Path               | Holds                                              |
| ------------------ | -------------------------------------------------- |
| `repos/`           | every repository, with its issues, pull requests and access lists stored as git objects |
| `lfs/`             | LFS objects and record attachments                 |
| `sealed-keys`      | the knot's and each repository's signing keys, encrypted with the master key |
| `ssh_host_key`     | the SSH host key people see when they clone        |

Nothing backs these up yet; the module carries a TODO for a backup
aspect, as Radicale does. A backup needs `repos/`, `lfs/`,
`sealed-keys` and the master key. The host key is the least serious
loss: people re-accept a new one.

## The master key

The knot reads `KNOT_MASTER_KEY` from an environment file and uses it
to unseal `sealed-keys`. The file is the sops secret `knot_env`,
declared in the aspect with `restartUnits`, and holds one line:

```
KNOT_MASTER_KEY=<output of: openssl rand -base64 32>
```

Add it with `sops secrets/main.yaml`; see
[SOPS-nix](../security/sops-nix.md). Losing the key makes the sealed
signing keys unreadable, and with them control of the repositories.
The copy in `secrets/main.yaml` is recoverable with the admin key, so
the admin key's own backup covers it.

## The public edge

The edge is a small machine with a public address that joins the
tailnet. It is not part of this repository yet. It has three jobs:

- **TLS for the knot's hostname**, proxied to `fern:5555` over the
  tailnet. The proxy must pass websocket upgrades, must not add CORS
  headers, and needs a request body limit large enough for a push.
  Caddy does the first two by default.
- **Overwrite `X-Forwarded-For`.** The knot rate-limits per client
  address and reads it from that header, trusting any tailnet peer.
  An edge that passed a client's own header through would let clients
  choose their rate-limit identity.
- **Forward TCP 22 to `fern:2222`.** Tangled builds SSH clone URLs
  without a port, so the knot's SSH has to answer on 22 at the public
  name. That means the edge's own OpenSSH moves to another port first.

Two refinements to make once the edge exists:

- The knot allows four concurrent SSH operations per client address
  (`server.ssh_max_inflight_per_peer`). Behind a plain TCP forward
  every client shares the edge's address. If the forwarder can send a
  PROXY v1 header, list the edge in `server.ssh_proxy_protocol_from` so
  the limit is per client again.
- Narrow `xrpc.trusted_proxies` from the whole tailnet range to the
  edge's tailnet address.

## What stays elsewhere

- **The web interface and index** are tangled.org. Pushing and cloning
  go straight to the knot and keep working if tangled.org is down;
  browsing, issues and review in the browser do not.
- **SSH keys** are read from each person's own PDS and cached for an
  hour (`keyfill.ttl_secs`). A newly added key can take that long to
  be accepted.
- **Everything is public.** Tangled has no private repositories yet.
- **Availability is the host's.** While the knot is down its
  repositories are unreachable for everyone. Keep the GitHub mirror,
  and keep this flake's own inputs pointed at the mirror: an input
  served from a knot on fern would make rebuilding fern depend on fern.

The `tangled` flake input is itself fetched from tangled.org, so
`just update` and `just bump tangled` need that site reachable. A build
from the existing lock does not.

## Enabling it

1. Choose the hostname and point its DNS at the edge.
2. In `modules/knot.nix`, replace the three placeholders: `hostname`,
   `admins` (your DID, shown in Tangled's settings) and `contactEmail`
   (served publicly).
3. Add the `knot_env` key with `sops secrets/main.yaml`. Activation
   fails without it.
4. Include `den.aspects.knot` in `modules/roles/homelab.nix`, then
   update the **Goes on** line above, the `knot` and `homelab` rows in
   the [Aspect Index](../reference/aspect-index.md) and the role's row
   on the [fern](../machines/fern.md) page.
5. `just check`, `just test`. The first build compiles the knot from
   source. The build also runs `knot-server validate` over the rendered
   configuration, so a bad setting fails there and not at start-up.
6. Set up the edge, then check from outside the tailnet:

   ```bash
   curl https://<hostname>/xrpc/_health
   ```

7. On the host, `knot-server --config /etc/knot/config.toml doctor`
   reports whether relays can crawl the knot.
8. In Tangled, **Settings → Knots**, add the hostname. New repositories
   can then be created on it.

## Key files

| File                        | Purpose                                        |
| --------------------------- | ---------------------------------------------- |
| `modules/knot.nix`          | The knot service, its settings and its secret  |
| `flake.nix`                 | The `tangled` input, deliberately not following `nixpkgs` |
| `modules/tailscale.nix`     | The trusted interface that carries edge traffic |
| `modules/roles/homelab.nix` | Where the aspect is included once enabled      |
