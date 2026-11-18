# Data tools: DuckDB, PostgreSQL client, object-store client

> Three command-line clients for looking at data outside any project
> environment: DuckDB (with a `dpeek` helper and the Harlequin TUI),
> `psql`, and `rc` for S3-compatible object stores. The repository holds
> the tools and their display settings only; every connection detail and
> credential is set up by hand on the machine.

**Goes on:** work laptop only. Each aspect is included directly by the
work layer (`modules/user-ada-work.nix`), not by a bundle. All three are
home-manager only.

The rest of that machine's setup is on the
[Work laptop](../machines/work-laptop.md) page.

## DuckDB (`duckdb`)

`modules/cli/duckdb.nix` installs `duckdb`, `harlequin` and a small
wrapper script, and writes `~/.duckdbrc`.

| Command                  | What it does |
| ------------------------ | ------------ |
| `duckdb`                 | Interactive shell with `~/.duckdbrc` applied (`.mode duckbox`, `.maxrows 50`, `.highlight on`) |
| `duckdb -c "FROM 'x.parquet'"` | One-shot query; the reader is inferred from the file extension |
| `dpeek FILE...`          | For Parquet/CSV/JSON files: schema, row count and first 10 rows. For `.duckdb`, `.db` or `.ddb` files: the table list with estimated rows and column counts, opened read-only |
| `harlequin FILE.duckdb`  | TUI SQL IDE |

Fish abbreviations `dk` (`duckdb`) and `dkq` (`duckdb -c`) are defined
here; see [Aliases](../reference/aliases.md).

DuckDB extensions are not declared in Nix. Known extensions install
themselves into `~/.duckdb` on first use, and that directory is mutable
state.

This is the CLI only. Projects pin their own DuckDB library per
environment, and the two versions can differ.

## PostgreSQL client (`postgres`)

`modules/cli/postgres.nix` installs the `postgresql` package for its
client, `psql`. The package also contains the server binaries; no server
is configured or run.

The package is taken from the `nixpkgs-uv` flake input rather than the
shared pin, to get a release with security fixes that the shared pin
does not carry yet. That input and when to remove it are described under
[Python](python.md#why-uv-has-its-own-nixpkgs-input); the override here
can go once the shared pin is at PostgreSQL 18.6 or later.

`~/.psqlrc` is managed and sets:

| Setting                             | Effect |
| ----------------------------------- | ------ |
| `\x auto`                           | Wide rows switch to expanded display on their own |
| `\pset null '∅'`                    | `NULL` cannot be mistaken for an empty string |
| `\set ON_ERROR_ROLLBACK interactive`| In an interactive transaction, an error does not discard the work before it |

Connection details are not in the repository. They live in two
hand-made, per-user files that every libpq client reads:

| File                 | Holds |
| -------------------- | ----- |
| `~/.pg_service.conf` | Named connections: host, port, database, user |
| `~/.pgpass`          | Passwords; must be mode 600 |

A connection is then referred to by name, with no password on the
command line:

```
psql service=NAME
duckdb -c "ATTACH 'service=NAME' AS db (TYPE postgres, READ_ONLY)"
```

## Object-store client (`rustfs`)

`modules/cli/rustfs.nix` installs `rc`, the
[rustfs/cli](https://github.com/rustfs/cli) client for S3-compatible
stores. It is not in nixpkgs, so the aspect builds a small derivation
around the upstream release: a static x86_64 binary, pinned by hash,
plus its bash, fish and zsh completions.

Stores and keys are not in the repository. Each store is registered by
hand, and `rc` keeps the result in `~/.config/rc/config.toml`:

```
rc alias set NAME URL ACCESS_KEY SECRET_KEY
rc ls NAME/BUCKET
rc cp NAME/BUCKET/KEY .
```

Two traps:

- An alias name may not start with a digit.
- nixpkgs also has a package called `rc`, the Plan 9 shell. It is an
  unrelated program with the same binary name; do not install both.

Updating means changing `version` and both hashes in the module.

## Key files

| File                        | Purpose                                         |
| --------------------------- | ----------------------------------------------- |
| `modules/cli/duckdb.nix`    | DuckDB, Harlequin, `dpeek`, `~/.duckdbrc`       |
| `modules/cli/postgres.nix`  | `psql` from `nixpkgs-uv`, `~/.psqlrc`           |
| `modules/cli/rustfs.nix`    | `rc` derivation and completions                 |
| `modules/user-ada-work.nix` | Includes the three aspects                      |
| `flake.nix`                 | `nixpkgs-uv` input                              |
