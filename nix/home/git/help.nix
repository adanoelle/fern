# git/help.nix - Git help system module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitHelp;
in
{
  options.programs.gitHelp = {
    enable = mkEnableOption "Git help system";
    
    claudeEnabled = mkOption {
      type = types.bool;
      default = false;
      description = "Whether Claude Code integration is enabled";
    };
  };

  config = mkIf cfg.enable {
    # Help command placeholder
    home.packages = [
      (pkgs.writeShellScriptBin "git-help" ''
        #!/usr/bin/env bash
        echo "Git Suite Help System"
        echo "===================="
        echo ""
        echo "Common commands:"
        echo "  g       - git status"
        echo "  ga      - git add"
        echo "  gc      - git commit"
        echo "  gp      - git push"
        echo ""
        echo "Worktree commands:"
        echo "  wtn     - new worktree"
        echo "  wtl     - list worktrees"
        echo "  wts     - switch worktree"
        echo "  wtr     - remove worktree"
        echo ""
        echo "Identity commands:"
        echo "  gid     - show/switch identity"
        echo ""
        echo "Run 'git-help <topic>' for more details on a specific topic"
      '')
    ];
  };
}