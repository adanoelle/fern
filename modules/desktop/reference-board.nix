# modules/desktop/reference-board.nix — a board of reference images
#
# BeeRef: drop images on an endless canvas, arrange and scale them, and
# keep the board beside the painting. Boards save as single .bee files.
#
# Mod+I brings the board up: it focuses the open one, or starts BeeRef
# if none is open. The window floats, so it stays above the tiled
# painting application.
_: {
  den.aspects.reference-board.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # BeeRef's EXIF dependency fails its tests on the default Python
      # (3.14) in this nixpkgs, so it is built against 3.13, where the
      # dependencies come from the cache. Drop the override once
      # `pkgs.beeref` builds on its own.
      beeref = pkgs.beeref.override { python3Packages = pkgs.python313Packages; };

      niri = lib.getExe config.programs.niri.package;

      # BeeRef sets no application id of its own (niri sees "python3"),
      # so the window is found by its title.
      board = pkgs.writeShellApplication {
        name = "reference-board";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          id=$(${niri} msg -j windows 2>/dev/null \
            | jq -r 'first(.[] | select(.app_id == "python3" and (.title | test("BeeRef"))) | .id) // empty' \
            || true)
          if [ -n "$id" ]; then
            exec ${niri} msg action focus-window --id "$id"
          fi
          exec ${lib.getExe beeref} "$@"
        '';
      };
    in
    {
      home.packages = [
        beeref
        board
      ];

      # The package ships no launcher entry.
      xdg.desktopEntries.beeref = {
        name = "BeeRef";
        genericName = "Reference board";
        comment = "Arrange reference images on a canvas";
        exec = "${lib.getExe beeref} %f";
        icon = "${beeref}/${pkgs.python313.sitePackages}/beeref/assets/logo.png";
        categories = [ "Graphics" ];
        mimeType = [ "application/x-beeref" ];
      };

      programs.niri.settings = {
        binds."Mod+I".action.spawn = [ (lib.getExe board) ];
        window-rules = [
          {
            matches = [
              {
                app-id = "^python3$";
                title = "BeeRef";
              }
            ];
            open-floating = true;
            default-column-width.fixed = 900;
            default-window-height.fixed = 700;
          }
        ];
      };
    };
}
