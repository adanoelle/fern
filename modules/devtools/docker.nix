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

      users.users.ada.extraGroups = [ "docker" ];

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
