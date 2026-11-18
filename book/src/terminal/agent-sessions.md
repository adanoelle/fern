# Agent sessions (herdr and Claude Code hooks)

> Many Claude Code sessions run in parallel across many repositories.
> Three things keep that manageable: herdr as the one place where every
> agent pane and its state is visible, a desktop notification when a
> session is blocked or idle, and an opt-in per-repository "project
> brief" injected into context when a session starts.

**Goes on:** every host (`herdr` and `claude-code` are in the `cli`
bundle). The notifications need a running desktop notification daemon.

## The pieces

| Piece | Defined in | What it does |
|---|---|---|
| `herdr` | `modules/cli/herdr.nix` | Client/server terminal workspace manager that tracks agent panes. |
| herdr's Claude integration | same file, activation script | Runs `herdr integration install claude` on every Home Manager activation (when `~/.claude` exists). It registers a SessionStart hook so herdr learns each pane's session id and can resume it after a server restart. |
| `claude-notify` | `modules/cli/claude-code.nix` | Notification hook: turns Claude Code notifications into `notify-send` toasts titled with the repository directory name. |
| `claude-brief` | same file | SessionStart hook: prints selected sections of a project note so they land in the session context. |

Both hook scripts are linked into `~/.claude/hooks/` and are also on
`PATH`. An activation script registers them in `~/.claude/settings.json`
with `jq`, adding an entry only when one with the same command is
missing and leaving every other key alone. `settings.json` therefore
stays an ordinary writable file owned by Claude Code, and `/config`
keeps working.

## Notifications

`claude-notify` is registered for these notification types:

| Type | Urgency | Title |
|---|---|---|
| `permission_prompt` | critical | `<repo>: approval needed` |
| `idle_prompt` | normal | `<repo>: waiting for you` |
| `agent_needs_input`, `elicitation_dialog` | normal | `<repo>: input needed` |

`<repo>` is the last component of the session's working directory.

## Project briefs

`claude-brief` runs on session start, resume, clear and compact. It
looks for `.claude/brief` in the project directory
(`CLAUDE_PROJECT_DIR`, else the hook's `cwd`). If the file exists, its
first line is taken as the path of a Markdown note (`~` is expanded).
From that note the hook prints the `## Overview`, `## Current Focus` and
`## Open Questions` sections and only the newest `###` entry under
`## Log`, capped at 120 lines, preceded by an instruction to update the
note's log and focus before the session ends.

To give a repository a brief:

```bash
echo '<notes-dir>/projects/<project>.md' > <repo>/.claude/brief
```

If the pointer file is missing the hook does nothing; if the note it
names is missing it prints a warning on stderr and exits cleanly.

## herdr configuration

`~/.config/herdr/config.toml` is generated, so it is a read-only store
link.

| Setting | Value | Why |
|---|---|---|
| `onboarding` | `false` | dismissing onboarding would try to write the config file |
| `terminal.default_shell` | the fish binary, `shell_mode = "non_login"` | `$SHELL` is not fish on the work laptop |
| `keys.prefix` | `cmd+space` (Super+Space) | tmux keeps `Ctrl+Space`; Niri leaves Super+Space unbound |
| `keys.split_horizontal` | `prefix+s` | split down, as in tmux |
| `keys.settings` | `prefix+shift+s` | frees `prefix+s` |
| `theme.name` | `terminal` | follow the host terminal's palette, i.e. the garden theme |

Pane navigation (`h/j/k/l`), `v` to split right, `x` to close and `q` to
detach are herdr's defaults. Change the theme in `herdr.nix`, not in
herdr's in-app editor, which cannot write the file. After editing, run
`herdr config check`.

## Daily use

```bash
herdr                      # launch or attach to the persistent session
herdr agent list           # every agent pane and its state
herdr agent explain <pane> # why herdr thinks a pane is in that state
herdr integration status   # is the Claude hook installed and current
```

`Super+Space`, then `q`, detaches; the server and the agents keep
running. The module comment advises against nesting tmux and herdr.

## Keeping herdr and Claude Code current

Both packages come from their own flake inputs through
`modules/overlays.nix`, so a lock bump is a version bump:

```bash
just bump herdr
```

then rebuild ([Day to day](../operations/day-to-day.md)).
`.github/workflows/update-flake-lock.yml` opens a pull request every
Monday that bumps the `herdr` and `claude-code` inputs. Because the
integration install runs on every activation, the herdr hook script is
brought in step with the new binary by the same switch.

## Troubleshooting

- **No toast when a session is blocked.** Run the hook by hand:
  `echo '{"notification_type":"permission_prompt","message":"test","cwd":"/tmp/x"}' | ~/.claude/hooks/claude-notify`,
  and check that `jq .hooks ~/.claude/settings.json` lists it.
- **Brief not injected.** `.claude/brief` must exist in the directory
  the session was started in. A git worktree is a separate directory: an
  untracked pointer file in the main checkout is not present there. Test
  with `echo '{"cwd":"'$PWD'"}' | ~/.claude/hooks/claude-brief`.
- **"permission denied" saving herdr settings.** herdr tried to write
  its read-only `config.toml`; make the change in
  `modules/cli/herdr.nix`.
- **Integration out of date after a bump.** Any Home Manager switch
  re-runs the install; `herdr integration install claude` does it
  directly.

## Key files

| File | Purpose |
|---|---|
| `modules/cli/herdr.nix` | herdr package, config, Claude integration install |
| `modules/cli/claude-code.nix` | Claude Code package, the two hooks, their registration |
| `modules/overlays.nix` | where the `herdr` and `claude-code` packages come from |
| `.github/workflows/update-flake-lock.yml` | weekly bump of both inputs |
