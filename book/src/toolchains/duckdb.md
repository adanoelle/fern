# DuckDB (data inspection)

> A global, project-independent DuckDB on the ORNL work laptop for getting
> one's bearings in the research group's Parquet files and small datastores
> before (or without) entering a project's Python environment. Included by
> `ada-work` only; fern and moss don't carry it.

## What you get (`den.aspects.duckdb`)

| Command | Purpose |
| ------- | ------- |
| `duckdb` | interactive shell; `~/.duckdbrc` sets duckbox output, 50-row cap, syntax highlighting |
| `duckdb -c "…"` | one-shot query (fish abbreviation `dkq`) |
| `dpeek FILE...` | schema, row count, and first 10 rows of any parquet/csv/json file; table list with row counts for a `.duckdb`/`.db` database (opened read-only) |
| `harlequin FILE.duckdb` | TUI SQL IDE with the DuckDB adapter |

DuckDB infers the reader from the file extension, so the everyday query is
just `FROM 'path'`:

```sql
FROM 'runs/2026-09/metrics.parquet' LIMIT 20;
SELECT model, count(*) FROM 'runs/**/*.parquet' GROUP BY 1;   -- globs work
DESCRIBE SELECT * FROM 'export.csv';
ATTACH 'store.duckdb' AS s (READ_ONLY); SHOW ALL TABLES;
```

Known extensions (`httpfs` for S3/HTTP, `spatial`, `sqlite`, `postgres`,
…) auto-install into `~/.duckdb/extensions` on first `LOAD` or first use;
nothing is declared in Nix. That directory is mutable state and can be
deleted freely.

## Relationship to project environments

This is the CLI only. Python projects keep pinning their own `duckdb`
package per environment (devenv / uv); the CLI and a project's library can
differ in version, which only matters for `.duckdb` database files written
by a newer storage format. Parquet, CSV, and JSON are unaffected.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/cli/duckdb.nix` | packages, `dpeek`, `~/.duckdbrc`, fish abbreviations |
| `modules/user-ada-work.nix` | includes the aspect (work laptop only) |
