{ pkgs, ... }:

{
  # --- Docker Engine                                      
  virtualisation.docker = {
    enable = true;
    # Enable BuildKit for faster, cache‑aware builds 🔥
    extraOptions = "--experimental";
    daemon.settings = {
      features = { buildkit = true; };
    };
  };

  users.users.ada.extraGroups = [ "docker" ];  # run docker without sudo

  # --- CLI, helper tools & TUIs                          
  environment.systemPackages = with pkgs; [
    docker-compose                      # Compose v2 plugin
    docker-buildx                       # multi‑arch builds
    dive                                # inspect image layers
    hadolint                            # Dockerfile linter
    ctop                                # container resource TUI
    lazydocker                          # all‑in‑one TUI (containers/images/logs)
    trivy                               # vulnerability scanner
    stern                               # tail logs from k8s pods (if you use EKS)
  ];
}

