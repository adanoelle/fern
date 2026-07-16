# modules/core.nix — Nix daemon, flakes, and fleet-wide defaults
#
# Everything here uses mkDefault where a host could reasonably want to
# override (a host in another timezone just sets time.timeZone).
{ den, inputs, ... }:
{
  den.aspects.core.nixos =
    { lib, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
        inputs.zig-overlay.overlays.default
        inputs.claude-code.overlays.default
      ];
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # No mkDefault here: nixpkgs itself *defines* trusted-users = [ "root" ]
      # at normal priority (nixos/modules/config/nix.nix), so an mkDefault
      # list silently loses instead of merging. A plain definition merges
      # with it, and hosts can still append (or mkForce to override).
      nix.settings.trusted-users = [
        "root"
        "ada"
      ];

      programs.nix-ld.enable = lib.mkDefault true;
      time.timeZone = lib.mkDefault "America/New_York";
    };
}
