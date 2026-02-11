# Cloud Platforms

> AWS and Azure CLI tools with credential management, infrastructure-as-code
> tooling, and security scanners.

Cloud platform tooling is split across two system modules: `cloud/aws-cli.nix`
for AWS and `azure-cli.nix` for Azure.

## AWS

The AWS module (`nix/modules/cloud/aws-cli.nix`) installs a comprehensive AWS
toolkit:

| Package                      | Purpose                                          |
| ---------------------------- | ------------------------------------------------ |
| `awscli2`                    | AWS CLI v2                                       |
| `aws-vault`                  | Credential manager (stores creds in OS keychain) |
| `ssm-session-manager-plugin` | SSH-over-SSM for EC2 instances                   |
| `aws-sam-cli`                | Serverless Application Model CLI                 |
| `eksctl`                     | EKS cluster management                           |
| `cfn-nag`                    | CloudFormation security linter                   |
| `terraform`                  | Infrastructure as code                           |
| `tfsec`                      | Terraform security scanner                       |
| `aws-nuke`                   | Account resource cleanup                         |
| `steampipe`                  | SQL interface to cloud APIs                      |

### Environment

```bash
AWS_SDK_LOAD_CONFIG=1
```

The `awsdev` alias launches a shell with dev credentials via aws-vault:
`aws-vault exec dev -- zsh`.

## Azure

The Azure module (`nix/modules/azure-cli.nix`) installs:

| Package                | Purpose                                 |
| ---------------------- | --------------------------------------- |
| `azure-cli`            | Azure CLI with extensions               |
| `azure-storage-azcopy` | High-performance Azure storage transfer |

### Extensions

The Azure CLI is installed with these extensions:

- `account` -- Subscription management
- `aks-preview` -- AKS preview features
- `cosmosdb-preview` -- Cosmos DB preview features
- `datafactory` -- Data Factory management
- `storage-preview` -- Storage preview features

### Environment

```bash
PYTHONWARNINGS=ignore::FutureWarning
```

This suppresses Python deprecation warnings from the Azure CLI, which uses
Python internally.

## Key files

| File                                  | Purpose                                        |
| ------------------------------------- | ---------------------------------------------- |
| `nix/modules/cloud/aws-cli.nix`       | AWS CLI, vault, SAM, Terraform, security tools |
| `nix/modules/azure-cli.nix`           | Azure CLI with extensions, azcopy              |
| `nix/modules/devtools/localstack.nix` | Local AWS emulation (see [Docker](docker.md))  |
