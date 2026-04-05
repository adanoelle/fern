# modules/devtools/bundle.nix — development toolchain bundle
{ den, ... }:
{
  den.aspects.devtools = {
    includes = [
      den.aspects.docker
      den.aspects.rust
      den.aspects.node-ts
      den.aspects.c-cpp
      den.aspects.python
      den.aspects.csharp
      den.aspects.ada-dev
      den.aspects.localstack
      den.aspects.zig
      den.aspects.gamedev
    ];
  };
}
