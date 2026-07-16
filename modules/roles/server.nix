# modules/roles/server.nix — headless server role
#
# Landing zone for the homelab host: no greeter, no fonts, no audio,
# no desktop user layers. Before the first server host ships, this
# role still needs (tracked in the multi-machine review):
#   - hardened SSH (key-only auth, no root login)
#   - server networking (systemd-networkd instead of NetworkManager,
#     which currently comes bundled via den.aspects.users)
#   - the secrets aspect, once per-host sops keys exist
{ den, ... }:
{
  den.aspects.server.includes = [
    den.aspects.core
    den.aspects.nh
    den.aspects.users
    den.aspects.secrets-guard
  ];
}
