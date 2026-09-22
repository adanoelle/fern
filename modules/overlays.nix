# modules/overlays.nix — nixpkgs configuration and overlays
{ inputs, ... }:
{
  # Support both architectures
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.rust-overlay.overlays.default
          inputs.zig-overlay.overlays.default
          inputs.claude-code.overlays.default
          # TEMPORARY: pin Claude Code to 2.1.280 ahead of the overlay.
          # Anthropic's API rejects Claude Opus 5.5 from anything older
          # ("claude_code_version_too_old", 2.1.280 or newer required) and
          # the overlay had only packaged 2.1.278 on 2026-09-22. The
          # sources file mirrors the overlay's own schema (Anthropic's
          # native binaries, hashes cross-checked against the release
          # manifest). Drop this override and the JSON once
          # `nix flake update claude-code` brings >= 2.1.280.
          (_final: prev: {
            claude-code = prev.claude-code.override {
              sourcesFile = ./cli/_claude-code/2.1.280.json;
            };
          })
          (final: _prev: {
            herdr = inputs.herdr.packages.${final.system}.default;
          })
        ];
      };
    };
}
