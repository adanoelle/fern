# modules/user-ada-dev.nix — user ada, development layer
#
# Language toolchains and dev tooling. Forwarded per-host via
# provides.to-users so servers and gaming machines don't carry ten
# toolchains they never use.
{ den, ... }:
{
  den.aspects.ada-dev = {
    includes = [
      den.aspects.devtools
    ];
  };
}
