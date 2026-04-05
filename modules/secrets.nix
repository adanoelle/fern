# modules/secrets.nix — SOPS-nix integration
{ den, inputs, ... }:
{
  den.aspects.secrets.nixos = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.age = {
      generateKey = true;
      keyFile = "/var/lib/sops-nix/key.txt";
    };

    security.sudo.extraConfig = ''
      Defaults env_keep += "SOPS_AGE_KEY_FILE"
    '';

    sops.defaultSopsFile = ../secrets/main.yaml;

    sops.secrets = {
      "ssh_id_ed25519" = {
        path = "/home/ada/.ssh/github";
        owner = "ada";
        mode = "0600";
      };
    };
  };
}
