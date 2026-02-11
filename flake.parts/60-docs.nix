{ ... }:
{
  perSystem = { pkgs, ... }: {
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
      program = toString (pkgs.writeShellScript "book-serve" ''
        BOOK_DIR="''${BOOK_DIR:-book}"
        if [ ! -f "$BOOK_DIR/book.toml" ]; then
          echo "Error: book/book.toml not found. Run from the repository root."
          exit 1
        fi
        exec ${pkgs.mdbook}/bin/mdbook serve "$BOOK_DIR" --open
      '');
    };

    apps.book-build = {
      type = "app";
      program = toString (pkgs.writeShellScript "book-build" ''
        BOOK_DIR="''${BOOK_DIR:-book}"
        if [ ! -f "$BOOK_DIR/book.toml" ]; then
          echo "Error: book/book.toml not found. Run from the repository root."
          exit 1
        fi
        exec ${pkgs.mdbook}/bin/mdbook build "$BOOK_DIR"
      '');
    };
  };
}
