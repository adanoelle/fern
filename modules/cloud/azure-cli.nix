{ den, ... }:
{
  den.aspects.azure-cli.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      (azure-cli.withExtensions [
        azure-cli.extensions.account
        azure-cli.extensions.aks-preview
        azure-cli.extensions.cosmosdb-preview
        azure-cli.extensions.datafactory
        azure-cli.extensions.storage-preview
      ])
      azure-storage-azcopy
    ];

    environment.variables = {
      PYTHONWARNINGS = "ignore::FutureWarning";
    };
  };
}
