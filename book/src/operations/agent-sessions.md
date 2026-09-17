# Agent Sessions (herdr + Claude Code hooks)

> How many parallel Claude Code sessions across many repos stay
> manageable: herdr as the single pane of glass, desktop toasts for
> blocked sessions, and a per-repo "project brief" pulled from the
> notes vault at session start.

## The pieces

| Piece | Where | What it does |
|-------|-------|--------------|
| `herdr` | `modules/cli/herdr.nix` | Client/server terminal workspace manager. One workspace per repo; sidebar shows each agent as working / blocked / done / idle. |
| herdr Claude integration | same file, activation script | `herdr integration install claude` on every `home-manager switch`. Registers a SessionStart hook so herdr knows each pane's session id and can `claude --resume` it after a server restart. |
| `claude-notify` | `modules/cli/claude-code.nix` | Notification hook → `notify-send`. Fires on permission prompts and idle prompts; the toast is titled with the repo name. |
| `claude-brief` | same file | SessionStart hook. If `<repo>/.claude/brief` names a vault project note, its Overview, Current Focus, newest Log entry and Open Questions are injected into context (max 120 lines). |

Both hooks live in `~/.claude/hooks/` and are registered in
`~/.claude/settings.json` by an activation script that only adds what
is missing. `settings.json` stays a normal mutable file, so `/config`
inside Claude Code keeps working.

## Daily use

```bash
herdr                      # attach (starts the server on first run)
# Super+Space is the prefix (tmux keeps Ctrl+Space). Press it, release,
# then the key: Super+Space q detaches; the server and agents keep running.
herdr agent list           # every agent pane and its state
herdr integration status   # confirm the claude hook is installed/current
```

One workspace per repo. Never start tmux inside a herdr pane: herdr then
sees `tmux` as the foreground process and loses agent state.

To give a repo a brief:

```bash
echo '~/work/notes/projects/theodolite.md' > ~/work/src/theodolite/.claude/brief
```

The next `claude` or `claude --resume` in that repo starts with the
note's current focus already in context.

## Keeping herdr fresh

The package is built from upstream's own flake (`inputs.herdr`), so a
lock bump is a version bump:

```bash
just bump herdr            # nix flake update herdr
home-manager switch --flake ~/src/fern    # work laptop
just switch                               # fern
```

`.github/workflows/update-flake-lock.yml` opens a PR every Monday
bumping `herdr` and `claude-code`. It needs the repo setting
*Allow GitHub Actions to create and approve pull requests* enabled once.

Nix-installed herdr cannot self-update (`herdr update` is disabled) and
cannot do a live server handoff, so a bump restarts the herdr server on
the next attach. Detached panes lose their processes; Claude panes come
back through native session restore.

## Troubleshooting

- **No toast when a session is blocked** — run
  `echo '{"notification_type":"permission_prompt","message":"test","cwd":"/tmp/x"}' | ~/.claude/hooks/claude-notify`
  and check `jq .hooks ~/.claude/settings.json` lists the hook.
- **Brief not injected** — `.claude/brief` must be a real file in the
  repo root (not the worktree) with the note path on line 1. Run the hook
  by hand: `echo '{"cwd":"'$PWD'"}' | ~/.claude/hooks/claude-brief`.
- **herdr shows the wrong state** — `herdr agent explain <pane>`.
- **"failed to save ... permission denied" inside herdr** — it tried to
  write `~/.config/herdr/config.toml`, which is a read-only store
  symlink. Onboarding is declared off in `modules/cli/herdr.nix`; change
  the theme there too rather than in herdr's settings overlay.
- **Integration outdated after a bump** — `home-manager switch` re-runs
  the install; or run `herdr integration install claude` directly.
