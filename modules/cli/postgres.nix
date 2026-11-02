# modules/cli/postgres.nix — a Postgres client for reaching the group's databases
#
# psql, and the settings it reads at startup. Which databases to reach,
# and the password for each, are NOT here: this repository is public, so
# connection details live in two hand-made files on the machine that
# needs them (see book/src/operations/work-laptop.md):
#
#   ~/.pg_service.conf   named connections: host, port, dbname, user
#   ~/.pgpass            passwords, mode 600
#
# Every libpq client reads both, so a connection is named, never spelled
# out or given a password on the command line:
#
#   psql service=NAME                          interactive session
#   duckdb -c "ATTACH 'service=NAME' AS db (TYPE postgres, READ_ONLY)"
#
# pkgs.postgresql also ships the server binaries; only the client is used.
_: {
  den.aspects.postgres.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.postgresql ];

      home.file.".psqlrc".text = ''
        -- ~/.psqlrc — managed by home-manager (modules/cli/postgres.nix)
        \set QUIET 1
        -- Wide rows switch to one column per line on their own.
        \x auto
        -- Show NULL as ∅, so it can't pass for an empty string.
        \pset null '∅'
        -- In an interactive transaction, a typo doesn't undo the work before it.
        \set ON_ERROR_ROLLBACK interactive
        \unset QUIET
      '';
    };
}
