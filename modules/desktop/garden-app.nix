# modules/desktop/garden-app.nix — the Garden collection app
#
# Garden (github:adanoelle/garden) keeps finds in channels: images,
# scans, links, notes, video and audio, all stored on this machine. It
# is the place things go instead of a pinboard site.
#
# Mod+C brings the collection up: it focuses the open window, or starts
# Garden if it is not running.
#
# This is a different thing from garden-shell, which provides the
# palette and the bar (modules/garden.nix).
{ inputs, ... }:
{
  den.aspects.garden-app.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      garden = inputs.garden.packages.${pkgs.stdenv.hostPlatform.system}.default;

      niri = lib.getExe config.programs.niri.package;

      collection = pkgs.writeShellApplication {
        name = "garden-collection";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          id=$(${niri} msg -j windows 2>/dev/null \
            | jq -r 'first(.[] | select(.app_id == "garden-desktop") | .id) // empty' \
            || true)
          if [ -n "$id" ]; then
            exec ${niri} msg action focus-window --id "$id"
          fi
          exec ${lib.getExe garden} "$@"
        '';
      };
    in
    {
      # The package ships its own launcher entry.
      home.packages = [
        garden
        collection
      ];

      programs.niri.settings.binds."Mod+C".action.spawn = [ (lib.getExe collection) ];
    };
}
