# modules/cli/yazi.nix — Yazi file manager
_: {
  den.aspects.yazi.homeManager = _: {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
        preview = {
          image_filter = "lanczos3";
          max_width = 600;
          max_height = 900;
        };
      };
    };
  };
}
