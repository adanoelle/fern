{ pkgs, ... }:

{
  # --- Core AWS CLI & credentials helpers                 
  environment.systemPackages = with pkgs; [
    awscli2
    aws-vault                       # secure, session‑cached creds
    ssm-session-manager-plugin      # AWS SSM port‑forward + shell
    aws-sam-cli                         # local Lambda/API Gateway emulation
    eksctl                          # EKS cluster manager
    cfn-nag                         # CloudFormation static analysis
    terraform
    tfsec                           # IaC security scanner
    aws-nuke                        # nuke stray resources in dev accounts
    steampipe                       # query AWS via SQL
  ];

  # --- Credentials model – recommend aws‑vault           
  environment.variables = {
    AWS_SDK_LOAD_CONFIG = "1";     # let SDKs use ~/.aws/config profiles
  };

  # Simple wrapper so `aws-vault exec dev -- zsh` opens your shell
  programs.zsh.shellAliases."awsdev" = "aws-vault exec dev -- zsh";
}

