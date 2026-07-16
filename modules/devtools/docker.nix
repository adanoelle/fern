{ den, ... }:
{
  den.aspects.docker.nixos =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        extraOptions = "--experimental";
        daemon.settings = {
          features = {
            buildkit = true;
          };
        };
      };

      # "docker" group membership is granted centrally in modules/users.nix,
      # conditional on virtualisation.docker.enable.

      environment.systemPackages = with pkgs; [
        docker-compose
        docker-buildx
        dive
        hadolint
        ctop
        lazydocker
        trivy
        stern
      ];
    };
}
