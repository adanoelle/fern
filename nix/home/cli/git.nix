{ pkgs, ... }:
{
  home.packages = [
    pkgs.git
    pkgs.delta
  ];

  programs.git = {
    enable = true;

    userName  = "adanoelle";
    userEmail = "adanoelleyoung@gmail.com";

    delta.enable = true;  # pretty pager

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = true;
      commit.gpgsign     = true;
      gpg.format         = "ssh";
      user.signingkey    = "~/.ssh/github";
      # optional includes
      # TODO(Ada): work git config
      # includeIf."gitdir:~/src/work/*".path = "~/.gitconfig-work";
    };
  };
}

