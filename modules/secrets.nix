# modules/secrets.nix — SOPS-nix integration
{ den, inputs, ... }:
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

      sops.age = {
        generateKey = true;
        keyFile = "/var/lib/sops-nix/key.txt";
      };

      security.sudo.extraConfig = ''
        Defaults env_keep += "SOPS_AGE_KEY_FILE"
      '';

      sops.defaultSopsFile = ../secrets/main.yaml;
    };
  };
}
