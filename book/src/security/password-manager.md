# Password manager

> Bitwarden is the password manager: the desktop application on the
> graphical NixOS machines, and `rbw`, a command-line client with a
> background agent, on every machine.

**Goes on:** `rbw` on every host (fern, yarrow, the work laptop);
`bitwarden` on fern and yarrow only.

| Aspect      | File                            | Arrives through                      | Machines             |
| ----------- | ------------------------------- | ------------------------------------ | -------------------- |
| `rbw`       | `modules/cli/rbw.nix`           | the `cli` bundle, in the base user layer | all              |
| `bitwarden` | `modules/desktop/bitwarden.nix` | the `desktop-apps` bundle, in `ada-desktop` | fern, yarrow  |

The work laptop does not take `ada-desktop`, so it has `rbw` and no
desktop application.

## Desktop application: `bitwarden`

The home-manager side installs `bitwarden-desktop`.

The aspect also has a NixOS side: it adds one specific Electron version
to `nixpkgs.config.permittedInsecurePackages`. The nixpkgs
`bitwarden-desktop` package currently depends on an Electron release
that is marked end-of-life, and evaluation refuses such packages unless
they are permitted by name. Keeping the exception inside the aspect
limits it to hosts that carry the application. The version string is
pinned, so a nixpkgs update that moves the package to another Electron
release needs the entry updated or removed.

## Command line: `rbw`

`programs.rbw` is enabled with these settings:

| Setting    | Value             | Note                                          |
| ---------- | ----------------- | --------------------------------------------- |
| `email`    | the account email | set in the module                             |
| `pinentry` | `pinentry-curses` | works without a graphical session; `rbw` is used from a terminal |
| `base_url` | unset             | the official Bitwarden service; pointing at a self-hosted server later is one line here |

Typical use:

```bash
rbw login                  # once per machine
rbw unlock                 # unlock the local database (starts the agent)
rbw sync                   # refresh the local copy
rbw get <entry>            # print an entry's password
rbw generate 32            # print a new 32-character password
rbw generate 32 <entry>    # the same, and save it as a new entry
```

`rbw generate` only stores the password when it is given an entry name.
See [rbw](https://github.com/doy/rbw) for the rest.

## Key files

| File                            | Purpose                                      |
| ------------------------------- | -------------------------------------------- |
| `modules/desktop/bitwarden.nix` | Desktop application and the Electron permit  |
| `modules/cli/rbw.nix`           | `rbw` client and agent settings              |
| `modules/desktop/bundle.nix`    | Includes `bitwarden`                         |
| `modules/cli/bundle.nix`        | Includes `rbw`                               |
