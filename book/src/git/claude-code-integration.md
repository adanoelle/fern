# Claude Code Integration

> Claude Code is integrated with safety wrappers, automatic snapshotting, and a
> worktree-based session manager for isolated AI-assisted development.

The configuration provides two levels of Claude Code integration: a safety
wrapper (`claude`) and an enhanced session manager (`claude-wt`). Both are
aspects in the git suite (`modules/git/`).

## Safety wrapper (`claude`)

The `git-claude-code` aspect (`modules/git/claude-code.nix`) wraps the Claude
Code CLI with several safety checks:

1. **Uncommitted change detection** -- Warns if the working tree has unstaged or
   staged changes
2. **Main branch warning** -- Suggests using a worktree when on the main branch
3. **Automatic snapshots** -- Creates a `claude-snapshot/*` tag before each
   session so you can roll back
4. **Context display** -- Shows the current directory, branch, and worktree
   status before launching

### Flags

| Flag | Effect |
|------|--------|
| `--force` | Skip all safety checks |
| `--in-worktree` | Assert you are in a worktree (errors if not) |
| `--sandbox` | Run with restricted file access |

### Helper scripts

The `claude-helpers` script provides:

- `claude-helpers worktree <name>` -- Create a worktree and open Claude in it
- `claude-helpers review` -- Review changes made during a session
- `claude-helpers undo` -- Revert to the pre-session snapshot
- `claude-helpers snapshots` -- List all Claude snapshots

## Session manager (`claude-wt`)

The `git-claude-enhanced` aspect (`modules/git/claude-enhanced.nix`) provides
`claude-wt`, a full session lifecycle manager:

| Command | Description |
|---------|-------------|
| `claude-wt new <name>` | Create worktree, start session with metadata file |
| `claude-wt finish` | Interactive end: keep changes, merge to main, or archive |
| `claude-wt list` | Show all active Claude worktree sessions |
| `claude-wt clean` | Remove finished/abandoned sessions |
| `claude-wt snapshot` | Manual snapshot within a session |
| `claude-wt diff` | Show all changes in the current session |

### Session workflow

1. `ccn feature-name` -- Creates a worktree, records session metadata, launches
   Claude
2. Work with Claude in the isolated worktree
3. `ccf` -- Finish the session: review changes, choose to keep/merge/archive
4. `ccc` -- Clean up old sessions

## Monitoring

`claude-monitor` watches for file changes in real time during a session, showing
which files Claude modifies as it works.

## Shell aliases

| Alias | Command |
|-------|---------|
| `cc` | `claude` (safety wrapper) |
| `ccs` | `claude-safe` (requires worktree) |
| `ccw` | `claude-wt` (session manager) |
| `ccn` | `claude-wt new` (new session) |
| `ccf` | `claude-wt finish` |
| `ccl` | `claude-wt list` |
| `ccc` | `claude-wt clean` |
| `ccm` | `claude-monitor` |

## Claude Code package

The Claude Code CLI itself is provided by the `claude-code` aspect in the CLI
bundle (`modules/cli/claude-code.nix`), which installs the package via the
`claude-code` flake input overlay. The git aspects add the safety wrappers
around it.

## Key files

| File | Purpose |
|------|---------|
| `modules/git/claude-code.nix` | Safety wrapper, helpers, snapshot aliases |
| `modules/git/claude-enhanced.nix` | Session manager, monitor, templates |
| `modules/cli/claude-code.nix` | Claude Code package installation |
