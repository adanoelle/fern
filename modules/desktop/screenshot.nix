# modules/desktop/screenshot.nix — capture tools for the garden shell
#
# The niri Super+S binds hand off to the garden shell, which calls grim
# and slurp to capture, satty to annotate and wl-copy to copy.
# garden.shell installs those itself, so a host that forwards
# garden.shell must NOT also forward this aspect. It is for hosts whose
# shell QML is managed outside this flake (fern), which would otherwise
# have the binds and none of the tools.
_: {
  den.aspects.screenshot.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        grim
        slurp
        satty
        wl-clipboard
      ];

      # Annotation defaults for satty, however it is started.
      xdg.configFile."satty/config.toml".text = ''
        [general]
        save-after-copy = true
        early-exit = true
        corner-roundness = 12
        initial-tool = "brush"
        primary-highlighter = "block"
        copy-command = "${pkgs.wl-clipboard}/bin/wl-copy --type image/png"

        [font]
        family = "Roboto"

        [color-palette]
        palette = [
            "#00ffff",
            "#a52a2a",
            "#dc143c",
            "#ff1493",
            "#ffd700",
            "#008000",
        ]
      '';
    };
}
