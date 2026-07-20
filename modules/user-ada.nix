# modules/user-ada.nix — user ada, base layer
#
# This is the machine-agnostic core of the ada identity: shells, CLI
# tools, git, and SSH. It must stay safe to apply on ANY host,
# including a headless server. Desktop and dev-toolchain layers live in
# user-ada-desktop.nix / user-ada-dev.nix and are forwarded per-host
# via provides.to-users (see host-fern.nix).
{ den, garden, ... }:
{
  den.aspects.ada = {
    includes = [
      den.aspects.cli
      den.aspects.git-suite
      den.aspects.shells
      den.aspects.workspace
      garden.terminal
    ];

    homeManager =
      { pkgs, config, ... }:
      {
        home.packages = [ pkgs.home-manager ];

        programs = {
          gitSuite = {
            enable = true;
            userName = "adanoelle";
            userEmail = "adanoelleyoung@gmail.com";
            editor = "hx";
            enableGithub = true;
            enableTools = true;
            enableSafety = true;
            enableHelp = true;
          };

          gitIdentities.identities = {
            personal = {
              name = "adanoelle";
              email = "adanoelleyoung@gmail.com";
              # No trailing slash: identities.nix appends one when building
              # the includeIf gitdir condition. ~/src is all personal today;
              # a future work identity adds "…/src/work" and wins as the
              # later, more-specific includeIf.
              directory = "${config.home.homeDirectory}/src";
              signingKey = "/home/ada/.ssh/github";
            };
          };

          ssh = {
            enable = true;
            # Old programs.ssh defaults (ForwardAgent no, ControlMaster no, …)
            # match OpenSSH's own defaults, so nothing is lost by opting out.
            enableDefaultConfig = false;
            settings = {
              "*".AddKeysToAgent = "yes";
              "github.com".IdentityFile = "~/.ssh/github";
            };
          };
        };

        services.ssh-agent.enable = true;
      };
  };
}
