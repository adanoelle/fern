# modules/foreign/docker-rootless.nix — rootless Docker on a foreign distro
#
# The work laptop is standalone home-manager on Ubuntu, so the nixos-side
# den.aspects.docker (virtualisation.docker, root daemon, docker group)
# is out of reach. Rootless Docker inverts the problem: the daemon runs
# entirely as the user under a systemd *user* service, which a standalone
# home CAN own. This is the NixOS virtualisation.docker.rootless unit
# translated to home-manager, using nixpkgs' dockerd-rootless wrapper
# (rootlesskit + slirp4netns already on its PATH).
#
# What must stay on the Ubuntu root side (see the one-time root checklist
# in book/src/operations/work-laptop.md):
#   - setuid newuidmap/newgidmap — the Nix store cannot hold setuid
#     binaries, so the service PATH falls through to the host: apt
#     uidmap in /usr/bin, or (apt unreachable off the lab network)
#     nix-built copies installed setuid into /usr/local/bin,
#   - /etc/subuid + /etc/subgid ranges for the user,
#   - an AppArmor profile granting userns to the Nix-store rootlesskit
#     (Ubuntu 24.04 restricts unprivileged user namespaces by default).
_: {
  den.aspects.docker-rootless.homeManager =
    { pkgs, ... }:
    {
      # Client CLI (and dockerd-rootless itself, handy for debugging).
      home.packages = [ pkgs.docker ];

      # Rootless docker serves on the user runtime dir, not
      # /var/run/docker.sock. Expanded at login by hm-session-vars.sh.
      home.sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";

      systemd.user.services.docker = {
        Unit = {
          Description = "Docker Application Container Engine (Rootless)";
          # docker-rootless doesn't support running as root.
          ConditionUser = "!root";
          StartLimitInterval = "60s";
          StartLimitBurst = 3;
        };
        Service = {
          Type = "notify";
          # The wrapper prefixes its own PATH (rootlesskit, slirp4netns,
          # dockerd); the host paths supply setuid newuidmap/newgidmap —
          # apt uidmap in /usr/bin, or the nix-built setuid copies the
          # root checklist installs into /usr/local/bin when apt is
          # unreachable (ORNL mirror needs the lab network).
          Environment = "PATH=${pkgs.docker}/bin:/usr/local/bin:/usr/bin:/bin";
          ExecStart = "${pkgs.docker}/bin/dockerd-rootless";
          ExecReload = "${pkgs.procps}/bin/kill -s HUP $MAINPID";
          TimeoutSec = 0;
          RestartSec = 2;
          Restart = "always";
          LimitNOFILE = "infinity";
          LimitNPROC = "infinity";
          LimitCORE = "infinity";
          Delegate = true;
          NotifyAccess = "all";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
