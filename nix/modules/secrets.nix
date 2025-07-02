{ pkgs, lib, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # --- Configure age key generation                                
  sops.age = {
    generateKey = true;                # ← first boot creates /var/lib/sops-nix/key.txt
    keyFile     = "/var/lib/sops-nix/key.txt";
  };

  # keep SOPS_AGE_KEY_FILE when sudo’ing so root can decrypt user secrets
  security.sudo.extraConfig = ''
    Defaults env_keep += "SOPS_AGE_KEY_FILE"
  '';

  # --- Point to encrypted secrets file
  # Path relative to repo root; commit this file to Git!
  sops.defaultSopsFile = ../../secrets/main.yaml;

  # --- Map each secret to its target path
  sops.secrets = {
    # SSH key for GitHub
    "ssh_id_ed25519" = {
      path  = "/home/ada/.ssh/github";
      owner = "ada";
      mode  = "0600";
    };
  };
}

