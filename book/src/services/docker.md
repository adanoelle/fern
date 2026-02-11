# Docker & Containers

> Docker Engine with BuildKit, Compose v2, and a suite of container utilities
> for building, scanning, and debugging images.

Docker is configured in `nix/modules/devtools/docker.nix` as a system module
because the Docker daemon requires root access.

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

## LocalStack

LocalStack (`nix/modules/devtools/localstack.nix`) provides a local AWS cloud
stack running in Docker. It is configured as an OCI container:

```nix
virtualisation.oci-containers.containers.localstack = {
  image = "localstack/localstack:3";
  ports = [ "4566:4566" ];
  environment = {
    SERVICES = "cloudformation,sts,iam,s3,sqs,sns,dynamodb,lambda,...";
  };
};
```

### awslocal

A wrapper script (`awslocal`) calls `aws` CLI with the LocalStack endpoint:

```bash
awslocal s3 ls        # Lists S3 buckets on LocalStack
awslocal sqs list-queues  # Lists SQS queues on LocalStack
```

Environment variables are set for SDK auto-detection:

```bash
AWS_ENDPOINT_URL=http://localhost:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=us-east-1
```

## Key files

| File                                  | Purpose                        |
| ------------------------------------- | ------------------------------ |
| `nix/modules/devtools/docker.nix`     | Docker Engine, BuildKit, tools |
| `nix/modules/devtools/localstack.nix` | LocalStack container, awslocal |
