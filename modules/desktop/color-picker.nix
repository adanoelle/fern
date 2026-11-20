# modules/desktop/color-picker.nix — pick a colour from the screen
#
# Mod+P turns the pointer into a picker; click anywhere and the
# colour's hex code is on the clipboard, with a notification showing a
# swatch. Escape cancels. The picking itself is niri's own
# (`niri msg pick-color`), so nothing has to capture the screen.
#
# Each pick is also appended to ~/.local/state/picked-colors, newest
# last, so a colour picked earlier can be found again.
_: {
  den.aspects.color-picker.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      niri = lib.getExe config.programs.niri.package;

      pick = pkgs.writeShellApplication {
        name = "pick-color";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
          pkgs.libnotify
          pkgs.wl-clipboard
        ];
        text = ''
          # niri answers {"rgb":[r,g,b]} with channels from 0 to 1, or
          # null when the pick was cancelled.
          rgb=$(${niri} msg -j pick-color \
            | jq -r 'if . == null then empty else .rgb | map(. * 255 | round) | join(" ") end')
          if [ -z "$rgb" ]; then
            exit 0
          fi
          read -r r g b <<<"$rgb"
          hex=$(printf '#%02x%02x%02x' "$r" "$g" "$b")

          wl-copy -- "$hex"

          state=''${XDG_STATE_HOME:-$HOME/.local/state}
          mkdir -p "$state"
          printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$hex" >> "$state/picked-colors"

          # A swatch of the colour as the notification's icon.
          swatch=''${XDG_RUNTIME_DIR:-/tmp}/pick-color-swatch.svg
          printf '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" rx="10" fill="%s"/></svg>\n' \
            "$hex" > "$swatch"
          notify-send --app-name "Colour" --expire-time 5000 --transient \
            --icon "$swatch" "$hex" "rgb($r, $g, $b) · copied" || true
        '';
      };
    in
    {
      home.packages = [ pick ];
      programs.niri.settings.binds."Mod+P".action.spawn = [ (lib.getExe pick) ];
    };
}
