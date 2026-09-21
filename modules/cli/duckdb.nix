# modules/cli/duckdb.nix — DuckDB for poking at data outside any project env
#
# The research group's workflow centres on DuckDB over Parquet files and
# assorted small datastores. This gives a global, project-independent way
# to open any of them and get one's bearings before touching a Python
# environment:
#
#   duckdb                          interactive shell (~/.duckdbrc applied)
#   duckdb -c "FROM 'x.parquet'"    one-shot query; format inferred from
#                                   the extension (parquet/csv/json/…)
#   dpeek FILE...                   schema + row count + first rows of
#                                   parquet/csv/json files, or the table
#                                   list of a .duckdb/.db database
#   harlequin FILE.duckdb           TUI SQL IDE (DuckDB adapter built in)
#
# Known extensions (httpfs, spatial, …) auto-install into ~/.duckdb on
# first use; nothing to declare here.
_: {
  den.aspects.duckdb.homeManager =
    { pkgs, ... }:
    let
      dpeek = pkgs.writeShellApplication {
        name = "dpeek";
        runtimeInputs = [ pkgs.duckdb ];
        text = ''
          if [ $# -eq 0 ]; then
            echo "usage: dpeek FILE..." >&2
            echo "  parquet/csv/json/…: schema, row count, first rows" >&2
            echo "  .duckdb/.db:        tables and their row counts" >&2
            exit 64
          fi
          for f in "$@"; do
            echo "== $f"
            case "$f" in
              *.duckdb|*.db|*.ddb)
                duckdb -readonly "$f" -c "
                  SELECT table_name, estimated_size AS rows, column_count AS cols
                  FROM duckdb_tables() ORDER BY table_name;"
                ;;
              *)
                duckdb -c "DESCRIBE SELECT * FROM '$f';"
                duckdb -c "SELECT count(*) AS rows FROM '$f';"
                duckdb -c "SELECT * FROM '$f' LIMIT 10;"
                ;;
            esac
          done
        '';
      };
    in
    {
      home.packages = [
        pkgs.duckdb
        pkgs.harlequin
        dpeek
      ];

      # The CLI reads ~/.duckdbrc (dot-commands and SQL) at startup.
      home.file.".duckdbrc".text = ''
        -- ~/.duckdbrc — managed by home-manager (modules/cli/duckdb.nix)
        .mode duckbox
        .maxrows 50
        .highlight on
      '';

      programs.fish.shellAbbrs = {
        dk = "duckdb";
        dkq = "duckdb -c";
      };
    };
}
