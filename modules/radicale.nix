# modules/radicale.nix — Radicale CalDAV/CardDAV server
#
# Tailnet-only: deliberately NO allowedTCPPorts — the service is
# reachable exclusively through the trusted tailscale0 interface
# (see modules/tailscale.nix). One URL from every device:
#   http://fern.<tailnet>.ts.net:5232/
#
# TODO: fold /var/lib/radicale/collections into a future backup
# aspect. If iOS CalDAV nags about HTTPS, front it with
# `tailscale serve` (runtime toggle, no Nix change needed).
{ den, ... }:
{
  den.aspects.radicale = {
    # Kept self-contained for a future dedicated server host. den does
    # NOT dedupe diamond includes itself; tailscale and secrets stay
    # safe to double-include via their module `key`s (see the note in
    # modules/tailscale.nix).
    includes = [
      den.aspects.tailscale
      den.aspects.secrets
    ];

    nixos =
      { config, ... }:
      {
        # Bcrypt htpasswd line, added via `sops secrets/main.yaml`.
        # The key must exist before switching — sops activation fails
        # loudly otherwise (by design).
        sops.secrets.radicale_htpasswd = {
          owner = config.services.radicale.user;
          mode = "0400";
          restartUnits = [ "radicale.service" ];
        };

        services.radicale = {
          enable = true;
          settings = {
            # Bind wide; exposure is controlled by the firewall.
            # Binding the tailscale IP instead would race tailscaled
            # at boot.
            server.hosts = [ "0.0.0.0:5232" ];

            # Radicale >=3.5 requires an explicit auth.type (default
            # became denyall). Pinned nixpkgs radicale ships
            # passlib[bcrypt].
            auth = {
              type = "htpasswd";
              htpasswd_filename = config.sops.secrets.radicale_htpasswd.path;
              htpasswd_encryption = "bcrypt";
            };

            # storage/rights stay at defaults: collections live in
            # /var/lib/radicale/collections (StateDirectory), rights
            # are owner_only.
          };
        };
      };
  };
}
