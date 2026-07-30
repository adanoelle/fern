# modules/hosts.nix — den topology
{ inputs, withSystem, ... }:
{
  den.hosts.x86_64-linux.fern.users.ada = { };

  # ORNL work laptop — Ubuntu 24.04, standalone home-manager only (no
  # nixosConfiguration). The "<user>@<host>" key makes the flake attr
  # match `whoami@hostname` so the home-manager CLI auto-selects it,
  # while aspect = "ada" maps the ORNL login onto the existing ada
  # aspect. Its work layer is forwarded via
  # den.aspects.ada.provides."_work-host_" (modules/user-ada-work.nix).
  # Replace the _ornlid_/_work-host_ placeholders once assigned.
  den.homes.x86_64-linux."_ornlid_@_work-host_" = {
    aspect = "ada";
    # den's default pkgs is plain inputs.nixpkgs.legacyPackages — no
    # overlays, no allowUnfree. Reuse the flake's perSystem pkgs
    # (modules/overlays.nix) so the cli bundle's claude-code overlay
    # and unfree packages resolve.
    pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
    # den's default instantiate passes no extraSpecialArgs; several
    # homeManager sides (e.g. devtools/devenv.nix) take `inputs`.
    instantiate =
      { pkgs, modules }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules;
        extraSpecialArgs = { inherit inputs; };
      };
  };

  # moss (Apple Silicon / Asahi) is parked: its hardware.nix is still the
  # installer placeholder and several aspects pull x86_64-only packages
  # (gnat13, ldtk, renderdoc), so the config cannot evaluate on
  # aarch64-linux. Re-enable after generating the real hardware.nix and
  # platform-gating those packages — or retire it for the Framework 13.
  # den.hosts.aarch64-linux.moss.users.ada = { };
}
