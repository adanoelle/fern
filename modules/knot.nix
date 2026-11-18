# modules/knot.nix — Tangled knot (git, issues and pull requests)
#
# A knot stores repositories for tangled.org and serves them over HTTP
# and its own built-in SSH server. Unlike the other homelab services it
# has to be reachable from the internet: relays crawl it over HTTPS and
# people clone over SSH.
#
# This host still opens nothing. The knot binds wide and stays behind
# the default-deny firewall, reachable only through the trusted
# tailscale0 interface (see modules/tailscale.nix). A separate public
# edge machine on the tailnet terminates TLS for the hostname below and
# forwards HTTPS and SSH here. Book: services/knot.md.
#
# DRAFT: not included by any role yet. Before adding it to
# modules/roles/homelab.nix, replace the three placeholders below and
# add the `knot_env` key with `sops secrets/main.yaml`.
#
# TODO: fold /var/lib/knot into a future backup aspect (same gap as
# radicale).
{ den, inputs, ... }:
let
  # The knot's permanent identity (did:web:<hostname>). Clone URLs and
  # at:// references embed it, so choose a name that outlives this
  # machine.
  hostname = "knot.example.com";

  # Admin DIDs; the first is advertised as the service owner.
  admins = [ "did:plc:replace-me" ];

  # Served publicly by org.tangled.knot.describeKnot.
  contactEmail = "admin@example.com";

  # Tailscale's address ranges. Only tailnet peers can reach the knot
  # at all, so this trusts the forwarded-for header from any of them;
  # narrow it to the edge's own tailnet address once that exists.
  tailnet = [
    "100.64.0.0/10"
    "fd7a:115c:a1e0::/48"
  ];
in
{
  den.aspects.knot = {
    # Self-contained for a future dedicated server host; tailscale and
    # secrets are safe to diamond-include via their module `key`s.
    includes = [
      den.aspects.tailscale
      den.aspects.secrets
    ];

    nixos =
      { config, ... }:
      {
        key = "den-aspect:knot";
        imports = [ inputs.tangled.nixosModules.knot-rs ];

        config = {
          # An env file holding `KNOT_MASTER_KEY=<base64, 32 bytes>`.
          # Generate the value with `openssl rand -base64 32` and keep a
          # second copy off this machine: without it the sealed signing
          # keys are unreadable and the repositories cannot be
          # controlled. systemd reads the file as root, so it stays
          # root-owned.
          sops.secrets.knot_env = {
            restartUnits = [ "knot-rs.service" ];
          };

          services.tangled.knot-rs = {
            enable = true;
            environmentFile = config.sops.secrets.knot_env.path;

            # The module defaults this to true and would open every
            # non-loopback listen port on the LAN. Exposure is the
            # tailnet's job here.
            openFirewall = false;

            settings = {
              server = {
                inherit hostname admins;
                # Bind wide so the edge can reach it over the tailnet;
                # binding the tailscale address would race tailscaled
                # at boot. SSH keeps the module default, [::]:2222.
                listen_addr = "0.0.0.0:5555";
              };

              atproto.plc_directory = "https://plc.directory";
              contact.email = contactEmail;

              # New repositories default to SHA-256, which cannot push
              # to or fetch from SHA-1 hosts. Repositories here are
              # mirrored with GitHub, so stay on SHA-1. Only affects
              # repositories created after the change.
              git.object_format = "sha1";

              # Rate-limit per visitor, not per proxy. The edge must
              # overwrite this header, never pass a client's through.
              xrpc = {
                trusted_proxy_header = "x-forwarded-for";
                trusted_proxies = tailnet;
              };
            };
          };
        };
      };
  };
}
