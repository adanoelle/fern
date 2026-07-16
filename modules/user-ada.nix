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
      { pkgs, ... }:
      {
        home.packages = [ pkgs.home-manager ];

        programs.gitSuite = {
          enable = true;
          userName = "adanoelle";
          userEmail = "adanoelleyoung@gmail.com";
          editor = "hx";
          enableGithub = true;
          enableTools = true;
          enableSafety = true;
          enableHelp = true;
        };

        programs.gitIdentities.identities = {
          personal = {
            name = "adanoelle";
            email = "adanoelleyoung@gmail.com";
            directory = "/home/ada/personal/";
            signingKey = "/home/ada/.ssh/github";
          };
        };

        programs.ssh = {
          enable = true;
          addKeysToAgent = "yes";
          matchBlocks."github.com" = {
            identityFile = "~/.ssh/github";
          };
        };

        services.ssh-agent.enable = true;
      };
  };
}
