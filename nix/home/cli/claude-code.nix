# cli/claude-code.nix - Claude Code CLI (system-wide)
{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];
}
