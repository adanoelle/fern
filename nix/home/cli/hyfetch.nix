{
  config,
  pkgs,
  ...
}: {
  programs.hyfetch = {
    enable = true;

    settings = {
      backend = "fastfetch";
      color_align = {
        mode = "horizontal";
      };

      light_dart = "dark";
      lightness = 0.65;
      mode = "rgb";
      preset = "transfeminine";
    };
  };
}
