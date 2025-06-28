{ pkgs, ... }:
{
  home.packages = [
    pkgs.git
  ];

  programs.git = {
    enable = true;

    userName  = "adanoelle";
    userEmail = "adanoelleyoung@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.editor        = "hx";
      pull.rebase        = true;
      commit.gpgsign     = true;
      gpg.format         = "ssh";
      user.signingkey    = "~/.ssh/github";
      # optional includes
      # TODO(Ada): work git config
      # includeIf."gitdir:~/src/work/*".path = "~/.gitconfig-work";
    };

    delta.enable = true;
  };
}

