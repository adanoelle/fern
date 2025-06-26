{ lib, ... }:

{
  # Tell the daemon and all users to enable the new CLI + flake syntax
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Optional: garbage‑collect weekly and keep a 10 × rollback safety net
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 10d";
  };
}

