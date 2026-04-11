{ den, ... }:
{
  den.aspects.localstack.nixos =
    { lib, pkgs, ... }:
    let
      dataDir = "/var/localstack";
      edgePort = "4566";
      awsBin = "${pkgs.awscli2}/bin/aws";
    in
    {
      virtualisation.oci-containers.backend = "docker";

      virtualisation.oci-containers.containers.localstack = {
        image = "localstack/localstack:3";
        volumes = [
          "${dataDir}:/var/lib/localstack"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        ports = [ "${edgePort}:${edgePort}" ];

        environment = {
          EDGE_PORT = edgePort;
          SERVICES = lib.concatStringsSep "," [
            "cloudformation"
            "sts"
            "iam"
            "s3"
            "sqs"
            "sns"
            "dynamodb"
            "lambda"
            "apigateway"
            "logs"
            "events"
            "ssm"
            "cloudwatch"
          ];
          DISABLE_EVENTS = "1";
        };
      };

      systemd.tmpfiles.rules = [ "d ${dataDir} 0755 root root -" ];

      environment.systemPackages = with pkgs; [
        (pkgs.writeScriptBin "awslocal" ''
          #!${pkgs.nushell}/bin/nu
          def main [...aws_args] {
            let endpoint = "http://localhost:${edgePort}"

            $env.AWS_ACCESS_KEY_ID     = "test"
            $env.AWS_SECRET_ACCESS_KEY = "test"
            $env.AWS_DEFAULT_REGION    = "us-east-1"

            ^${awsBin} "--endpoint-url" $endpoint ...$aws_args
          }
        '')
      ];

      environment.etc."profile.d/awslocal.nu".text = ''
        alias awslocal = (^aws --endpoint-url http://localhost:${edgePort} ...$argv)
      '';

      environment.sessionVariables = {
        AWS_ENDPOINT_URL = "http://localhost:${edgePort}";
        AWS_ACCESS_KEY_ID = "test";
        AWS_SECRET_ACCESS_KEY = "test";
        AWS_DEFAULT_REGION = "us-east-1";
        LOCALSTACK_HOST = "localhost";
      };
    };
}
