# modules/secrets-guard.nix — secret-scanning tools on the system
#
# The commit-time scan is NOT here: it is a user-level pre-commit hook
# (gitleaks) in modules/git/safety.nix, so it also covers machines that
# take no NixOS sides. This aspect only makes git and trufflehog
# available system-wide; trufflehog is for deeper scans by hand, since
# it can verify whether a found credential is live.
_: {
  den.aspects.secrets-guard.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.trufflehog ];

      programs.git.enable = true;
    };
}
