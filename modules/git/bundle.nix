# modules/git/bundle.nix — git suite bundle with orchestrator
{ den, ... }:
{
  den.aspects.git-suite = {
    includes = [
      den.aspects.git-core
      den.aspects.git-aliases
      den.aspects.git-identities
      den.aspects.git-github
      den.aspects.git-tools
      den.aspects.git-safety
      den.aspects.git-help
    ];

    homeManager =
      { config, lib, ... }:
      with lib;
      let
        cfg = config.programs.gitSuite;
      in
      {
        options.programs.gitSuite = {
          enable = mkEnableOption "Complete Git suite configuration";
          # No defaults: git identity is personal, not a module opinion.
          # Each user layer must set these (see user-ada.nix).
          userName = mkOption {
            type = types.str;
            description = "Git user name (required)";
          };
          userEmail = mkOption {
            type = types.str;
            description = "Git user email (required)";
          };
          editor = mkOption {
            type = types.str;
            default = "hx";
          };
          enableGithub = mkOption {
            type = types.bool;
            default = true;
          };
          enableTools = mkOption {
            type = types.bool;
            default = true;
          };
          enableSafety = mkOption {
            type = types.bool;
            default = true;
          };
          enableHelp = mkOption {
            type = types.bool;
            default = true;
          };
        };

        config = mkIf cfg.enable {
          programs.gitCore = {
            enable = true;
            userName = cfg.userName;
            userEmail = cfg.userEmail;
            editor = cfg.editor;
          };
          programs.gitAliases.enable = true;
          programs.gitIdentities.enable = true;
          programs.gitGithub.enable = cfg.enableGithub;
          programs.gitTools.enable = cfg.enableTools;
          programs.gitSafety.enable = cfg.enableSafety;
          programs.gitHelp.enable = cfg.enableHelp;
          programs.gitGithub.editor = mkDefault cfg.editor;
        };
      };
  };
}
