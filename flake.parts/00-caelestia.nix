# flake.parts/00-caelestia.nix
{ self, inputs, ... }:

let
  overlay = final: prev: let
    quickshell = inputs.quickshell.packages.${prev.system}.default;

    caelestiaShell = prev.callPackage (self + "/nix/pkgs/caelestia-shell.nix") {
      src = inputs."caelestia-shell";
      inherit quickshell;
    };

    beatDetector = prev.callPackage (self + "/nix/pkgs/beat-detector.nix") {
      src = inputs."caelestia-shell" + "/assets";
    };
  in {
    # camel‑case keys (used by your module)
    quickshell      = quickshell;
    caelestiaShell  = caelestiaShell;
    beatDetector    = beatDetector;

    # optional dashed aliases for nix run or CLI users
    "caelestia-shell" = caelestiaShell;
    "beat-detector"   = beatDetector;
  };
in
{
  flake.overlays.caelestia = overlay;
}
