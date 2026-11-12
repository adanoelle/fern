# modules/cli/theodolite.nix — theodolite, the research group's geocoder
#
# theodolite geocodes addresses to points and H3 cells, against indexes
# it builds from public address, parcel and street data. The program
# holds no data: everything it searches lives in one data directory,
# built in place by its own commands and never kept in a repo:
#
#   theodolite fetch ...      download a state's sources into it
#   theodolite build ...      build its indexes from them
#
# THEODOLITE_DATA names that directory for the tools that run theodolite
# against it, such as the BioHackathon's located cohort.
#
# The program itself is not here yet: it is built from its private
# repository with `cargo install --path crates/theodolite-cli`, until
# its flake exports a package to pin.
_: {
  den.aspects.theodolite.homeManager = {
    home.sessionVariables.THEODOLITE_DATA = "$HOME/work/src/theodolite/data";
  };
}
