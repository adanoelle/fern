# Module System

> NixOS modules are the building blocks of a system configuration. Each module
> declares options and provides configuration, and the module system merges them
> all together.

A NixOS module is a function that takes an attribute set (typically
`{ config, lib, pkgs, ... }`) and returns an attribute set with `options` and/or
`config`. Modules let you split a system configuration across many files, each
responsible for one concern: audio, graphics, Git, a language toolchain.

## Anatomy of a module

```nix
{ config, lib, pkgs, ... }:
{
  options.services.myThing = {
    enable = lib.mkEnableOption "my thing";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  config = lib.mkIf config.services.myThing.enable {
    systemd.services.my-thing = {
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.myThing}/bin/my-thing --port ${toString config.services.myThing.port}";
    };
  };
}
```

**Options** declare what the module can be configured with. They have types,
defaults, and descriptions. Other modules (or your host configuration) set these
options.

**Config** is the actual system configuration that gets applied when the module
is enabled. `mkIf` makes the config conditional -- it only takes effect when
`enable = true`.

## Key functions

- **`mkIf condition attrs`** -- Apply `attrs` only when `condition` is true.
  Used to gate an entire module behind an `enable` option.

- **`mkDefault value`** -- Set a value with low priority. Another module can
  override it without using `mkForce`. Good for sensible defaults.

- **`mkForce value`** -- Set a value with high priority, overriding everything
  else. Use sparingly -- it makes debugging priority conflicts harder.

- **`mkEnableOption "description"`** -- Shorthand for a boolean option that
  defaults to `false`.

- **`mkOption { type, default, description }`** -- Declare a typed option.

## How modules compose

When NixOS evaluates your configuration, it:

1. Collects all imported modules
2. Evaluates every module's `options` to build a schema
3. Merges all `config` values according to priority rules
4. Produces a final configuration attribute set

This means you can split configuration across files freely. Two modules can both
set `environment.systemPackages`, and NixOS merges the lists. Two modules can
both add systemd services, and they coexist.

## Example from this repo

The audio module (`nix/modules/audio.nix`) is a simple config-only module -- it
does not declare its own options, just provides configuration directly:

```nix
{ pkgs, lib, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol qpwgraph helvum
  ];
}
```

It sets PipeWire options (defined by NixOS itself), enables rtkit for real-time
scheduling, and adds audio utilities. When this module is imported in a host
configuration, its settings merge with everything else.
