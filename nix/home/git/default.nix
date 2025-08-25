# git/default.nix - Main orchestrator with help system
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitSuite;
in
{
  imports = [
    ./core.nix
    ./identities.nix
    ./worktree.nix
    ./github.nix
    ./helix.nix
    ./claude-code.nix
    ./aliases.nix
    ./tools.nix
    ./help.nix  # Add the help system
  ];

  options.programs.gitSuite = {
    enable = mkEnableOption "Modular Git suite for Home Manager";

    primaryIdentity = mkOption {
      type = types.str;
      default = "personal";
      description = "Primary Git identity to use by default";
    };

    editor = mkOption {
      type = types.str;
      default = "hx";
      description = "Default editor for Git operations";
    };

    workspaceDirs = mkOption {
      type = types.attrsOf types.str;
      default = {
        personal = "~/personal";
        work = "~/src/work";
      };
      description = "Directory mappings for different Git identities";
    };

    enableClaudeCode = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Claude Code integration with safety features";
    };

    enableAdvancedTools = mkOption {
      type = types.bool;
      default = true;
      description = "Enable advanced Git tools (lazygit, tig, etc.)";
    };

    enableHelp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable comprehensive help system";
    };

    enableTutorial = mkOption {
      type = types.bool;
      default = true;
      description = "Enable interactive tutorial system";
    };
  };

  config = mkIf cfg.enable {
    # Ensure all submodules are enabled
    programs.gitCore.enable = true;
    programs.gitIdentities.enable = true;
    programs.gitWorktree.enable = true;
    programs.gitGithub.enable = true;
    programs.gitHelix.enable = true;
    programs.gitAliases.enable = true;
    programs.gitTools.enable = mkDefault cfg.enableAdvancedTools;
    programs.gitClaudeCode.enable = mkDefault cfg.enableClaudeCode;
    programs.gitHelp.enable = mkDefault cfg.enableHelp;

    # Pass configuration to submodules
    programs.gitCore.editor = cfg.editor;
    programs.gitIdentities.primary = cfg.primaryIdentity;
    programs.gitIdentities.workspaceDirs = cfg.workspaceDirs;
    programs.gitHelix.editor = cfg.editor;
    programs.gitHelp.claudeEnabled = cfg.enableClaudeCode;

    # Add convenient aliases for help
    home.shellAliases = mkIf cfg.enableHelp {
      "?" = "git-help menu";
      "g?" = "git-help";
      "git?" = "git-help";
      
      # Quick access to sections
      "?wt" = "git-help worktree";
      "?id" = "git-help identity";
      "?hx" = "git-help helix";
      "?gh" = "git-help github";
    } // mkIf cfg.enableTutorial {
      "git-learn" = "git-tutorial";
      "learn-git" = "git-tutorial";
    };

    # Add first-run message
    home.activation.gitSuiteWelcome = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f "$HOME/.config/git/.suite-welcomed" ]; then
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "       🎉 Git Suite Successfully Configured! 🎉"
        echo "════════════════════════════════════════════════════════"
        echo ""
        echo "Quick Start Commands:"
        echo "  • git-help      - Show all available commands"
        echo "  • git-help menu - Interactive help browser"
        echo "  • git-tutorial  - Interactive learning experience"
        echo "  • git?          - Quick help menu"
        echo ""
        echo "Key Features:"
        echo "  • Worktrees:  wt new <name>"
        echo "  • Identities: gid list"
        echo "  • Helix:      hxm (open modified files)"
        echo "  • GitHub:     gh pr create"
        echo ""
        echo "Run 'git-tutorial' to learn the workflow!"
        echo "════════════════════════════════════════════════════════"
        echo ""
        touch "$HOME/.config/git/.suite-welcomed"
      fi
    '';
  };
}
