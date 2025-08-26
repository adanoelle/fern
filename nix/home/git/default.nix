# git/default.nix - Main git suite orchestrator (no scripts)
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitSuite;
in
{
  imports = [
    ./core.nix
    ./aliases.nix
    ./identities.nix
    ./github.nix
    ./tools.nix
    ./safety.nix
    ./help.nix
  ];

  options.programs.gitSuite = {
    enable = mkEnableOption "Complete Git suite configuration";

    userName = mkOption {
      type = types.str;
      default = "adanoelle";
      description = "Default git user name";
    };

    userEmail = mkOption {
      type = types.str;
      default = "adanoelleyoung@gmail.com";
      description = "Default git user email";
    };

    editor = mkOption {
      type = types.str;
      default = "hx";
      description = "Default editor for Git operations";
    };

    enableGithub = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GitHub CLI integration";
    };

    enableTools = mkOption {
      type = types.bool;
      default = true;
      description = "Enable additional git tools";
    };

    enableSafety = mkOption {
      type = types.bool;
      default = true;
      description = "Enable safety features";
    };

    enableHelp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable help system";
    };
  };

  config = mkIf cfg.enable {
    # Enable all submodules
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
    
    # Pass editor preference to GitHub
    programs.gitGithub.editor = mkDefault cfg.editor;
  };
}