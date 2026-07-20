# modules/tailscale.nix — Tailscale mesh VPN client
#
# The exposure mechanism for homelab services: tailscale0 is a trusted
# firewall interface, so services can bind wide while staying reachable
# only from the tailnet (LAN/VLANs stay behind the default-deny
# firewall — never add allowedTCPPorts for tailnet-only services).
#
# Auth is a one-time interactive `sudo tailscale up` per host; state
# persists in /var/lib/tailscale. Deliberately no authKeyFile/sops:
# auth keys expire and are a standing liability for a tailnet this
# small.
_: {
  den.aspects.tailscale = {
    # Let the host's (single) topology user drive the tailscale CLI
    # without sudo. Same single-user assumption as modules/secrets.nix.
    includes = [
      (
        { host, ... }:
        let
          user = (builtins.head (builtins.attrValues host.users)).userName;
        in
        {
          nixos = {
            services.tailscale.extraSetFlags = [ "--operator=${user}" ];
          };
        }
      )
    ];

    nixos =
      { lib, ... }:
      {
        services.tailscale = {
          enable = true;
          # Plain client by default; the homelab role bumps this to
          # "both" so routing features are a console toggle there.
          useRoutingFeatures = lib.mkDefault "client";
          # UDP 41641 — direct peer paths instead of DERP relays.
          openFirewall = true;
        };

        networking.firewall.trustedInterfaces = [ "tailscale0" ];

        # systemd-resolved gives MagicDNS clean split-DNS alongside
        # NetworkManager. Escape hatch if DNS ever misbehaves (no
        # rebuild needed): `tailscale set --accept-dns=false`.
        services.resolved.enable = lib.mkDefault true;
      };
  };
}
