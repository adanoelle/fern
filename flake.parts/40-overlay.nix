{ self, inputs, ... }: {
  # --- Caelestia Overlay: A quickshell desktop environment
  # 
  # 1.  Define the overlay itself
  flake.overlays.default = final: prev: {
    # Re‑export Quickshell from its flake
    quickshell = inputs.quickshell.packages.${prev.system}.default;

    # Caelestia Shell – QML config packaged into /share
    caelestia-shell = prev.callPackage ../pkgs/caelestia-shell.nix {
      quickshell = final.quickshell;
    };

    # Beat detector helper (will be Rust later)
    beat-detector = prev.callPackage ../pkgs/beat-detector.nix { };

    # TODO(Ada): Add fern‑shell packages here later
  };

  # 2.  Tell per‑system modules to use that overlay for pkgs
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ self.overlays.default ];
      config.allowUnfree = true;
    };
  };
}
