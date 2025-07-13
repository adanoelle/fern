{ stdenv, lib, pkg-config, pipewire, aubio, gcc, src }:

stdenv.mkDerivation {
  # --- Beat Detector
  pname    = "beatDetector";
  version  = "git-2025-07-07";
  inherit src;

  nativeBuildInputs = [ pkg-config gcc ];
  buildInputs       = [ pipewire aubio ];  # libs required by upstream README :contentReference[oaicite:5]{index=5}

  buildPhase = ''
    g++ -std=c++17 beat_detector.cpp -o beat_detector \
      $(pkg-config --cflags --libs libpipewire-0.3) \  # PW compile flags :contentReference[oaicite:6]{index=6}
      $(pkg-config --cflags --libs aubio)
  '';

  installPhase = ''
    install -Dm755 beat_detector $out/lib/caelestia/beat_detector
  '';

  meta = with lib; {
    description = "PipeWire beat and spectrum detector for Caelestia Shell";
    license     = licenses.gpl3Plus;
    platforms   = platforms.linux;
  };
}

