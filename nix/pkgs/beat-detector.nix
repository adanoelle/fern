# nix/pkgs/beat-detector.nix
{ stdenv
, lib
, pkg-config
, pipewire
, aubio
, src
}:

stdenv.mkDerivation rec {
  pname    = "beatDetector";
  version  = "git-2025-07-07";
  inherit src;

  nativeBuildInputs = [ pkg-config ];             # stdenv brings its own cc
  buildInputs       = [ pipewire aubio ];

  # ---- Build ------------------------------------------------------------------
  buildPhase = ''
    runHook preBuild

    g++ -std=c++17 $CXXFLAGS \
        $(pkg-config --cflags libpipewire-0.3 aubio) \
        beat_detector.cpp \
        -o beat_detector \
        $(pkg-config --libs libpipewire-0.3 aubio)

    runHook postBuild
  '';

  # ---- Install ---------------------------------------------------------------
  installPhase = ''
    runHook preInstall
    install -Dm755 beat_detector $out/lib/caelestia/beat_detector
    runHook postInstall
  '';

  meta = with lib; {
    description = "PipeWire beat and spectrum detector for Caelestia Shell";
    license     = licenses.gpl3Plus;
    maintainers = [];         # add yourself
    platforms   = platforms.linux;
  };
}

