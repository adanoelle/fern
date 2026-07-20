# modules/users.nix — user accounts, group membership, and networking
#
# Design choice (see PR "remove single-machine assumptions"): instead of
# each service aspect reaching into users.users.<name>.extraGroups, ALL
# group membership is centralized here, keyed on whether the relevant
# service is actually enabled on the host. Exactly one file answers
# "what groups does a user get, and why".
#
# Usernames are not hardcoded: den resolves aspects in a host context,
# and any function in an includes tree whose required arguments are
# satisfied by that context gets called with it (den.lib.parametric
# fixedTo / take.atLeast). So `{ host, ... }:` below receives the den
# host, and host.users is the topology from modules/hosts.nix.
_: {
  den.aspects.users = {
    includes = [
      (
        { host, ... }:
        {
          nixos =
            {
              config,
              lib,
              pkgs,
              ...
            }:
            {
              users.users = lib.genAttrs (map (u: u.userName) (lib.attrValues host.users)) (_: {
                isNormalUser = true;
                shell = pkgs.fish;
                # Key-only sshd (below) needs at least one authorized key,
                # or hosts built from this config are unreachable over SSH.
                # This is ada's sops-managed key (~/.ssh/github); public
                # halves are safe to commit.
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFcuaT78TweAsGP6nqUmqIV2sx7mF1Jt0mqtMKV+4Ft ada@fern github"
                ];
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ]
                # DDC/CI brightness control; hardware.i2c is enabled by
                # the niri aspect (modules/desktop/niri.nix).
                ++ lib.optionals config.hardware.i2c.enable [ "i2c" ]
                ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
                ++ lib.optionals config.services.pipewire.enable [ "audio" ]
                ++ lib.optionals config.programs.gamemode.enable [ "gamemode" ]
                ++ lib.optionals config.services.greetd.enable [
                  "video"
                  "input"
                  "seat"
                ];
              });
            };
        }
      )
    ];

    nixos = {
      programs.fish.enable = true;

      networking.networkmanager.enable = true;
      # Key-only SSH fleet-wide: the workflow is entirely key-based, so
      # never accept passwords on port 22. PermitRootLogin already
      # defaults to "prohibit-password".
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
  };
}
