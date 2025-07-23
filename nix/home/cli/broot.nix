{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    broot
    nushell
  ];

  programs.broot= {
    enable = true;
    enableNushellIntegration = true;

    settings = {
      modal = false;
      show_git_status = true;
      quit_on_last_cancel = true;
      verbs = [
        {
          invocation = "edit";
          execution  = "$EDITOR {file}";
          leave_broot = true;
        }
      ];
    };
  };
}
