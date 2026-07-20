# modules/cli/btop.nix — btop system monitor
_: {
  den.aspects.btop.homeManager = _: {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "garden";
        theme_background = false;
        vim_keys = true;
        rounded_corners = false;
        update_ms = 1000;
        proc_sorting = "cpu lazy";
        proc_tree = true;
      };
    };
  };
}
