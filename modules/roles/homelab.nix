# modules/roles/homelab.nix — always-on self-hosted services role
#
# The aspect set for the machine that hosts the homelab services.
# fern (always-on workstation) carries this role today; when a
# dedicated server exists it takes server + homelab and fern drops it.
{ den, ... }:
{
  den.aspects.homelab = {
    includes = [
      den.aspects.tailscale
      den.aspects.radicale
    ];

    nixos = {
      # IP forwarding on now, so enabling subnet-router / exit-node
      # later is a Tailscale admin-console toggle, not a rebuild.
      services.tailscale.useRoutingFeatures = "both";
    };
  };
}
