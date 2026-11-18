# modules/_lib/overlays.nix — the one list of nixpkgs overlays
#
# Two package sets are built in this flake and both must see the same
# overlays: the NixOS hosts' (modules/core.nix, via nixpkgs.overlays) and
# the perSystem one that the standalone home and the dev shell use
# (modules/overlays.nix). Each imports this file, so a package can no
# longer come from an input on one and from plain nixpkgs on the other.
inputs: [
  inputs.rust-overlay.overlays.default
  inputs.claude-code.overlays.default
  # herdr straight from upstream's flake (see modules/cli/herdr.nix)
  (final: _prev: {
    herdr = inputs.herdr.packages.${final.stdenv.hostPlatform.system}.default;
  })
]
