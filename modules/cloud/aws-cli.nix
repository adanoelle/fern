{ den, ... }:
{
  den.aspects.aws-cli.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      awscli2
      aws-vault
      ssm-session-manager-plugin
      aws-sam-cli
      eksctl
      cfn-nag
      terraform
      tfsec
      aws-nuke
      steampipe
    ];

    environment.variables = {
      AWS_SDK_LOAD_CONFIG = "1";
    };

    programs.zsh.shellAliases."awsdev" = "aws-vault exec dev -- zsh";
  };
}
