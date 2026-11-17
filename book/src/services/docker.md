# Docker & Containers

> Docker Engine with BuildKit, Compose v2, and a suite of container utilities
> for building, scanning, and debugging images.

Docker is configured as the `den.aspects.docker` aspect in
`modules/devtools/docker.nix` because the Docker daemon requires root access.

## Docker Engine

```nix
virtualisation.docker = {
  enable = true;
  extraOptions = "--experimental";
  daemon.settings = {
    features = { buildkit = true; };
  };
};
```

BuildKit is enabled as the default builder, providing better caching, parallel
builds, and Dockerfile frontend features. The `ada` user is added to the
`docker` group for rootless CLI access.

## Container tools

| Package          | Purpose                               |
| ---------------- | ------------------------------------- |
| `docker-compose` | Multi-container orchestration         |
| `docker-buildx`  | Extended build capabilities           |
| `dive`           | Image layer explorer                  |
| `hadolint`       | Dockerfile linter                     |
| `ctop`           | Container resource monitor (top-like) |
| `lazydocker`     | Terminal UI for Docker                |
| `trivy`          | Container image vulnerability scanner |
| `stern`          | Multi-pod log tailing for Kubernetes  |

## Key files

| File                                  | Purpose                        |
| ------------------------------------- | ------------------------------ |
| `modules/devtools/docker.nix`     | Docker Engine, BuildKit, tools (`den.aspects.docker`)     |
