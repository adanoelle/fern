{ inputs, flake-parts-lib, self, ... }:

{
  systems = inputs.flake-utils.lib.defaultSystems;

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.rust-overlay.overlays.default
        self.overlays.default
      ];
    };
  };
}
