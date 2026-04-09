# Cloud Platforms

> AWS CLI tools with credential management, infrastructure-as-code tooling,
> and security scanners.

Cloud platform tooling lives in the `den.aspects.aws-cli` aspect
(`modules/cloud/aws-cli.nix`).

## AWS

The AWS aspect (`modules/cloud/aws-cli.nix`) installs a comprehensive AWS
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

## Key files

| File                                  | Purpose                                        |
| ------------------------------------- | ---------------------------------------------- |
| `modules/cloud/aws-cli.nix`       | AWS CLI, vault, SAM, Terraform, security tools (`den.aspects.aws-cli`)   |
| `modules/devtools/localstack.nix` | Local AWS emulation (`den.aspects.localstack`; see [Docker](docker.md))  |
