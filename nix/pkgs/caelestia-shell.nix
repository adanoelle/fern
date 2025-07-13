{ stdenv, lib, src, quickshell }:

stdenv.mkDerivation {
  # --- Calestia Shell
  pname = "caelestiaShell";
  version = "git-2025-07-07";
  inherit src;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/caelestia-shell
    cp -r $src/* $out/share/caelestia-shell/
  '';

  # keep a pointer for callers
  passthru.configPath = "$out/share/caelestia-shell";

  meta = with lib; {
    description = "QML configuration for QuickShell (Caelestia desktop)";
    license     = licenses.gpl3Plus;
    platforms   = platforms.linux;
  };
}
