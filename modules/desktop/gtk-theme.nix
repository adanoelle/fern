# modules/desktop/gtk-theme.nix — graphical applications follow the palette
#
# garden-themes writes two files for applications outside the terminal:
# named colours for GTK and a colour scheme for Krita. This aspect
# points the applications at them. Both are read when an application
# starts, so a palette switch shows the next time it is opened.
#
# The files live in the mutable ~/.config/garden/themes/, so they are
# imported or linked by path rather than copied into the store.
_: {
  den.aspects.gtk-theme.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      themes = "${config.xdg.configHome}/garden/themes";
      colors = ''@import url("file://${themes}/gtk/garden-colors.css");'';
    in
    {
      gtk = {
        enable = true;
        # adw-gtk3 is libadwaita's look for GTK 3, written against the
        # same colour names the generated file defines. The colours
        # file overrides every one of them, so the dark and the light
        # variant end up nearly the same; this one is fixed. GTK 4 is
        # left on libadwaita's own theme, which reads the names itself.
        gtk3 = {
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          extraCss = colors;
        };
        gtk4.extraCss = colors;
      };

      # `garden-themes apply` sets the dark or light preference with
      # this.
      home.packages = [ pkgs.dconf ];

      # Krita looks for colour schemes here. "Garden" is chosen once
      # under Settings → Themes; the scheme keeps that name for every
      # palette.
      xdg.dataFile."krita/color-schemes/Garden.colors".source =
        config.lib.file.mkOutOfStoreSymlink "${themes}/krita/Garden.colors";
    };
}
