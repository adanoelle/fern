# modules/docs.nix — mdBook documentation
#
# Also defines the `aspect-index` flake check, which keeps the book's
# aspect index (book/src/reference/aspect-index.md) in step with the
# code: every den aspect needs a table row there whose first cell is the
# aspect's name in backticks, and every such row must name an aspect
# that exists. The names come from the evaluated `den.aspects`, so no
# source-scraping is involved. `just check` (nix flake check) runs it.
{ config, lib, ... }:
let
  aspectNames = builtins.attrNames config.den.aspects;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.aspect-index =
        pkgs.runCommand "aspect-index-check"
          {
            index = ../book/src/reference/aspect-index.md;
            aspects = lib.concatLines aspectNames;
            passAsFile = [ "aspects" ];
          }
          ''
            sort -u "$aspectsPath" > defined
            # First cell of each table row, when it is a single backticked name.
            sed -nE 's/^\| `([^`|]+)` \|.*/\1/p' "$index" | sort > rows
            sort -u rows > documented

            status=0
            missing=$(comm -23 defined documented)
            phantom=$(comm -13 defined documented)
            repeated=$(uniq -d rows)
            if [ -n "$missing" ]; then
              echo "Aspects with no row in book/src/reference/aspect-index.md:"
              echo "$missing" | sed 's/^/  /'
              status=1
            fi
            if [ -n "$phantom" ]; then
              echo "Rows in the aspect index that name no existing aspect:"
              echo "$phantom" | sed 's/^/  /'
              status=1
            fi
            if [ -n "$repeated" ]; then
              echo "Aspects with more than one row in the aspect index:"
              echo "$repeated" | sed 's/^/  /'
              status=1
            fi
            if [ "$status" -ne 0 ]; then
              echo
              echo "Add, remove or rename the rows so the index matches den.aspects."
              exit 1
            fi
            touch $out
          '';

      packages.book = pkgs.stdenv.mkDerivation {
        pname = "fern-docs";
        version = "0.1.0";
        src = ../book;
        nativeBuildInputs = [ pkgs.mdbook ];
        buildPhase = "mdbook build";
        installPhase = "cp -r build $out";
      };

      apps.book-serve = {
        type = "app";
        program = toString (
          pkgs.writeShellScript "book-serve" ''
            BOOK_DIR="''${BOOK_DIR:-book}"
            if [ ! -f "$BOOK_DIR/book.toml" ]; then
              echo "Error: book/book.toml not found. Run from the repository root."
              exit 1
            fi
            exec ${pkgs.mdbook}/bin/mdbook serve "$BOOK_DIR" --open
          ''
        );
      };

      apps.book-build = {
        type = "app";
        program = toString (
          pkgs.writeShellScript "book-build" ''
            BOOK_DIR="''${BOOK_DIR:-book}"
            if [ ! -f "$BOOK_DIR/book.toml" ]; then
              echo "Error: book/book.toml not found. Run from the repository root."
              exit 1
            fi
            exec ${pkgs.mdbook}/bin/mdbook build "$BOOK_DIR"
          ''
        );
      };
    };
}
