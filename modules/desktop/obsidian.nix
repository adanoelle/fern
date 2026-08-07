# modules/desktop/obsidian.nix — Obsidian knowledge-base app
#
# Garden palette CSS snippet is provided at runtime by garden-themes,
# keeping Obsidian in sync when the user switches palettes.
_: {
  den.aspects.obsidian = {
    homeManager =
      { pkgs, config, ... }:
      let
        # On non-NixOS the Electron SUID sandbox binary in the Nix store
        # can't be setuid root. Disable it so Electron falls back to the
        # kernel namespace sandbox (supported on Ubuntu 24.04+).
        obsidian =
          if config.targets.genericLinux.enable then
            pkgs.obsidian.override { commandLineArgs = "--no-sandbox"; }
          else
            pkgs.obsidian;

        themesDir = "${config.xdg.configHome}/garden/themes";
      in
      {
        home.packages = [ (config.lib.nixGL.wrap obsidian) ];

        # Garden palette snippet — mutable, updated by `garden-themes apply`
        home.file."work/notes/.obsidian/snippets/garden.css".source =
          config.lib.file.mkOutOfStoreSymlink
            "${themesDir}/obsidian/garden-theme.css";

        # Route Obsidian to the writing workspace, full-width column
        programs.niri.settings.window-rules = [
          {
            matches = [ { app-id = "^obsidian$"; } ];
            open-on-workspace = "writing";
            default-column-width.proportion = 1.0;
          }
        ];
      };
  };
}
