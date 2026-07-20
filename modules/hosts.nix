# modules/hosts.nix — den topology
_: {
  den.hosts.x86_64-linux.fern.users.ada = { };

  # moss (Apple Silicon / Asahi) is parked: its hardware.nix is still the
  # installer placeholder and several aspects pull x86_64-only packages
  # (gnat13, ldtk, renderdoc), so the config cannot evaluate on
  # aarch64-linux. Re-enable after generating the real hardware.nix and
  # platform-gating those packages — or retire it for the Framework 13.
  # den.hosts.aarch64-linux.moss.users.ada = { };
}
