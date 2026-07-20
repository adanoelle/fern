# modules/secrets-guard.nix — git-secrets and trufflehog
_: {
  den.aspects.secrets-guard.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git-secrets
        trufflehog
      ];

      programs.git = {
        enable = true;
        config.init.templateDir = "${pkgs.git-secrets}/share/git-secrets";
      };
    };
}
