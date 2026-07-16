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
      den.aspects.git-claude-code
      den.aspects.git-claude-enhanced
      den.aspects.git-worktree
      den.aspects.git-worktree-enhanced
      den.aspects.git-helix
      den.aspects.git-prompts
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
          enableWorktree = mkOption {
            type = types.bool;
            default = false;
            description = "Enable enhanced worktree management";
          };
          enableWorktreeEnhanced = mkOption {
            type = types.bool;
            default = false;
          };
          enableHelix = mkOption {
            type = types.bool;
            default = false;
          };
          enablePrompts = mkOption {
            type = types.bool;
            default = false;
          };
          enableClaudeCode = mkOption {
            type = types.bool;
            default = false;
          };
          enableClaudeEnhanced = mkOption {
            type = types.bool;
            default = false;
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
          programs.gitWorktree.enable = cfg.enableWorktree;
          programs.gitWorktreeEnhanced.enable = cfg.enableWorktreeEnhanced;
          programs.gitHelix.enable = cfg.enableHelix;
          programs.gitPrompts.enable = cfg.enablePrompts;
          programs.gitClaudeCode.enable = cfg.enableClaudeCode;
          programs.gitClaudeEnhanced.enable = cfg.enableClaudeEnhanced;
          programs.gitGithub.editor = mkDefault cfg.editor;
        };
      };
  };
}
