# modules/core.nix — Nix daemon, flakes, and fleet-wide defaults
#
# Everything here uses mkDefault where a host could reasonably want to
# override (a host in another timezone just sets time.timeZone).
{ inputs, ... }:
{
  den.aspects.core = {
    # The host's topology users (modules/hosts.nix) are trusted by the
    # Nix daemon; nothing here names a user.
    includes = [
      (
        { host, ... }:
        {
          nixos.nix.settings.trusted-users = map (u: u.userName) (builtins.attrValues host.users);
        }
      )
    ];

    nixos =
      { lib, ... }:
      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          inputs.rust-overlay.overlays.default
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
        nix.settings.trusted-users = [ "root" ];

        programs.nix-ld.enable = lib.mkDefault true;
        time.timeZone = lib.mkDefault "America/New_York";
      };
  };
}
