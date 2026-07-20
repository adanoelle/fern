# modules/secrets.nix — SOPS-nix integration
{ inputs, ... }:
{
  den.aspects.secrets = {
    # The user-owned secret derives its owner/path from the den topology
    # (host.users) instead of hardcoding a username. sops-nix can only
    # give a secret one path/owner, so this assumes a single-user host —
    # true for every host today. A multi-user host should move user
    # secrets to home-manager-side sops (planned follow-up PR).
    includes = [
      (
        { host, ... }:
        let
          user = (builtins.head (builtins.attrValues host.users)).userName;
        in
        {
          nixos = {
            sops.secrets."ssh_id_ed25519" = {
              path = "/home/${user}/.ssh/github";
              owner = user;
              mode = "0600";
            };
          };
        }
      )
    ];

    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../secrets/main.yaml;

        # Canonical per-host identity: the SSH host key, converted to
        # age at activation (ssh-to-age). Register new hosts in
        # .sops.yaml and run `sops updatekeys` BEFORE enabling this
        # aspect — otherwise activation fails loudly (by design).
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # Don't import RSA host keys into a throwaway GPG keyring
        # (sops-nix defaults this from services.openssh.hostKeys).
        gnupg.sshKeyPaths = [ ];
      };
    };
  };
}
