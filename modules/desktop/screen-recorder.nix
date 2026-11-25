# modules/desktop/screen-recorder.nix — record short clips of the screen
#
# Mod+Shift+R: drag a box around what to record (Escape cancels). The
# same key again stops, and the clip is in ~/recordings as an MP4 that
# plays in a browser or a chat. For clips to share, not for streaming
# (that is den.aspects.obs).
#
# The recorder is wf-recorder, which copies the screen through the
# compositor's own screen-copy protocol. Recorders that go through the
# screen-cast portal and PipeWire (Kooha was tried) fail to agree on a
# video format with niri on the work laptop.
_: {
  den.aspects.screen-recorder.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      recordings = "${config.home.homeDirectory}/recordings";

      record = pkgs.writeShellApplication {
        name = "record-clip";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.libnotify
          pkgs.slurp
          pkgs.wf-recorder
        ];
        text = ''
          pidfile=''${XDG_RUNTIME_DIR:-/tmp}/record-clip.pid
          namefile=''${XDG_RUNTIME_DIR:-/tmp}/record-clip.name

          # A recording is running: stop it and say where the clip is.
          if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
            pid=$(cat "$pidfile")
            kill -INT "$pid"
            # wf-recorder finishes the file after the signal
            while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
            clip=$(cat "$namefile")
            rm -f "$pidfile" "$namefile"
            size=$(du -h "$clip" | cut -f1)
            notify-send --app-name "Recording" --expire-time 6000 --transient \
              "Clip saved ($size)" "$clip" || true
            exit 0
          fi

          # RECORD_CLIP_GEOMETRY="x,y WxH" skips the drag, for scripts.
          geometry=''${RECORD_CLIP_GEOMETRY:-$(slurp || true)}
          if [ -z "$geometry" ]; then
            exit 0
          fi
          # The video format wants an even width and height.
          position=''${geometry% *}
          size=''${geometry#* }
          width=$(( ''${size%x*} / 2 * 2 ))
          height=$(( ''${size#*x} / 2 * 2 ))

          mkdir -p "${recordings}"
          clip="${recordings}/clip-$(date +%Y-%m-%d_%H-%M-%S).mp4"
          # yuv420p: the pixel format every player and chat accepts
          wf-recorder -g "$position ''${width}x''${height}" -c libx264 -x yuv420p \
            -f "$clip" >/dev/null 2>&1 &
          echo $! > "$pidfile"
          echo "$clip" > "$namefile"
          notify-send --app-name "Recording" --expire-time 2000 --transient \
            "Recording" "Mod+Shift+R stops" || true
        '';
      };
    in
    {
      home.packages = [ record ];
      programs.niri.settings.binds."Mod+Shift+R".action.spawn = [ (lib.getExe record) ];
    };
}
