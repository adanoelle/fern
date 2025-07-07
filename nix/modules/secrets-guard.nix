{ pkgs, ... }:

{
  # --- Guard against developers adding secrets in repositories
  environment.systemPackages = with pkgs; [
    git-secrets
    trufflehog
  ];

  # --- Global Git configuration for new repositories
  programs.git = {
    enable = true;

    # `config` (not extraConfig) is the correct option name
    config.init.templateDir =
      "${pkgs.git-secrets}/share/git-secrets";
  };
}
