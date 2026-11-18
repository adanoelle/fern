# Git

> Git is configured by one bundle, `git-suite`, made of small Home
> Manager modules: core settings with SSH commit signing and the delta
> pager, directory-based identities, a pre-push guard for protected
> branches, the GitHub CLI, a few extra tools, and help aliases. The
> user layer turns it on with one option block. The guard refuses
> pushes to protected branches outright when there is no terminal to
> confirm on, which matters for agents and scripts.

**Goes on:** every host (`git-suite` is included by the base user layer,
`modules/user-ada.nix`).

## The suite

`modules/git/bundle.nix` defines `den.aspects.git-suite`, which includes
one aspect per file in `modules/git/` and declares a single front-door
option set, `programs.gitSuite`. Each sub-aspect declares its own
`programs.git<Name>` options and only acts when enabled; the suite's
`config` enables them.

| Aspect | File | Options | Enabled by the suite |
|---|---|---|---|
| `git-core` | `core.nix` | `programs.gitCore` | always |
| `git-aliases` | `aliases.nix` | `programs.gitAliases` | always |
| `git-identities` | `identities.nix` | `programs.gitIdentities` | always |
| `git-github` | `github.nix` | `programs.gitGithub` | `enableGithub` (default on) |
| `git-tools` | `tools.nix` | `programs.gitTools` | `enableTools` (default on) |
| `git-safety` | `safety.nix` | `programs.gitSafety` | `enableSafety` (default on) |
| `git-help` | `help.nix` | `programs.gitHelp` | `enableHelp` (default on) |

All git configuration is written through Home Manager's
`programs.git.settings` (plus `programs.git.includes` and
`programs.git.ignores`), so it ends up in `~/.config/git/config`.

### How it is enabled

`modules/user-ada.nix` sets `programs.gitSuite.enable = true` together
with `userName`, `userEmail` and `editor = "hx"`. Name and email have no
default: the suite forwards them to `gitCore`, and evaluation fails if a
user layer leaves them out. The same file declares the identities
described below.

## Core settings

From `modules/git/core.nix`. Only the settings that change everyday
behaviour are listed; read the file for the rest (performance flags,
colours, the global ignore list).

| Area | Setting | Effect |
|---|---|---|
| Signing | `commit.gpgsign = true`, `gpg.format = "ssh"` | every commit is signed with an SSH key |
| | `user.signingkey` | `gitCore.signingKey` if set, otherwise `~/.ssh/github` |
| | `gpg.ssh.allowedSignersFile` | `~/.config/git/allowed_signers` (see below) |
| Push | `push.default = "current"`, `autoSetupRemote`, `followTags` | `git push` on a new branch creates and tracks the same-named remote branch |
| Pull | `pull.rebase = true` | `git pull` rebases |
| Fetch | `prune`, `pruneTags` | deleted remote branches and tags disappear locally |
| Merge | `conflictStyle = "diff3"` | conflicts show the common ancestor |
| Rebase | `autoStash`, `autoSquash`, `updateRefs` | dirty trees are stashed; `fixup!` commits are folded; stacked branch refs move with a rebase |
| Other | `rerere.enabled`, `diff.algorithm = "histogram"`, `help.autocorrect = 10`, `init.defaultBranch = "main"` | |

Tags are not signed automatically; only `commit.gpgsign` is set.

`~/.config/git/allowed_signers` is written at Home Manager activation
by `identities.nix`: one line per identity, pairing its email with the
public half of its signing key (`<signingKey>.pub`). The key material
stays on the machine and out of this repository. An identity whose
`.pub` file is absent on a machine is skipped. With it,
`git log --show-signature` and `git verify-commit` report your own
commits as good signatures; commits signed by keys not in the file
show as unverified.

### URL rewrites

```nix
url."ssh://git@github.com/".insteadOf = "https://github.com/";
url."ssh://git@gist.github.com/".insteadOf = "https://gist.github.com/";
```

Any `https://github.com/...` remote is fetched and pushed over SSH, so
cloning a pasted HTTPS URL needs a working GitHub SSH key. The base user
layer points `github.com` at `~/.ssh/github` in `programs.ssh`.

### Delta

Two modules configure the delta pager and their options merge:

- `core.nix` enables it for git with navigation, line numbers,
  side-by-side view and hyperlinks. Because the editor is `hx`, file
  links use the form `hx://{path}:{line}`.
- `modules/cli/delta.nix` forces `syntax-theme = "garden"`, removes the
  line-length limit, and selects a delta feature named `ada-theme`
  whose colours (added and removed lines, hunk headers, line numbers)
  are garden palette values fixed at build time.

`garden` is a bat syntax theme supplied by the garden theming layer; see
[Garden](../desktop/garden.md).

## Identities

`modules/git/identities.nix` turns each entry of
`programs.gitIdentities.identities` into a git `includeIf` block keyed on
the repository's location. An identity has a `name`, `email` and
`directory`, and optionally a `signingKey`, an `sshCommand` and free-form
`extraConfig`. The shape, with placeholders:

```nix
programs.gitIdentities.identities = {
  personal = {
    name = "<name>";
    email = "<personal-email>";
    directory = "${config.home.homeDirectory}/src";
    signingKey = "${config.home.homeDirectory}/.ssh/<personal-key>";
  };
  work = {
    name = "<name>";
    email = "<work-email>";
    directory = "${config.home.homeDirectory}/src/work";
    signingKey = "${config.home.homeDirectory}/.ssh/<work-key>";
    sshCommand = "ssh -i ~/.ssh/<work-key> -o IdentitiesOnly=yes";
  };
};
```

`user-ada.nix` declares three: `personal` for `~/src`, `work` for
`~/src/work`, and `work-vault` for `~/work`, the last two sharing one
email and key.

What a matching identity overrides inside its directory: `user.name`,
`user.email`; with a `signingKey`, also `user.signingkey`,
`commit.gpgsign` and `gpg.format = "ssh"`; with an `sshCommand`,
`core.sshCommand`, so fetches and pushes use that key only.

Rules that are easy to get wrong:

- **No trailing slash on `directory`.** The module appends one when it
  builds `gitdir:<directory>/`. With the trailing slash git matches
  every repository below that directory.
- **Ordering is by attribute name.** The include blocks are emitted in
  alphabetical order of the identity names, and when several conditions
  match, git applies them in order so the last one wins. `~/src/work`
  is inside `~/src`, so both `personal` and `work` match there; `work`
  wins only because it sorts after `personal`. A nested identity must
  have a name that sorts after the identity of the enclosing directory.
- **Outside every directory** the global `user.*` from `gitCore`
  applies: the suite's `userName`, `userEmail` and the default signing
  key.
- **`primary`** (default `"personal"`) copies that identity's name,
  email and key into the global `user.*` at `mkDefault` priority. Under
  the suite `gitCore` already sets all three at normal priority, so
  `primary` currently has no effect.

To check which identity is active in a repository: `git whoami` or
`git id` (also the shell alias `gid`).

## Safety

`modules/git/safety.nix`.

### Protected branches and the pre-push hook

`programs.gitSafety.protectedBranches` defaults to `main`, `master`,
`prod` and `production`. The hook is installed at
`~/.config/git/hooks/pre-push` and behaves as follows:

- It checks the **destination** ref of each ref being pushed, not the
  branch that is checked out. `git push origin feature` while on `main`
  passes; `git push origin HEAD:main` from a feature branch is caught.
  Tags and other non-branch refs are ignored.
- If a protected branch is among the destinations and a terminal is
  available, it asks `Are you sure you want to push? (y/n)` on
  `/dev/tty`.
- If there is **no terminal** (an agent, a script, CI, a GUI client),
  it does not prompt: it prints "No terminal to confirm on; push
  refused." and exits non-zero.

For non-interactive work the intended route is to push a feature branch
and merge a pull request. `git push --no-verify` skips the hook. When
the push is allowed, the repository's own `pre-push` hook runs next.

### Secret scan before each commit

A `pre-commit` hook scans the staged changes with gitleaks and refuses
the commit if they contain a credential. See
[Secret guard](../security/secret-guard.md).

### Repository hooks still run

The module sets `core.hooksPath = ~/.config/git/hooks` globally. Git
then looks for hooks only in that directory and ignores each
repository's `.git/hooks`. To keep project hooks working, every hook in
the global directory ends by running the repository's hook of the same
name, when one exists and is executable:

- `pre-commit`, `pre-push` and (when enabled) `commit-msg` run their own
  check first. The repository's hook runs only if that check passes,
  and its exit status decides the outcome.
- For the other client-side hooks (`post-checkout`, `post-merge`,
  `prepare-commit-msg` and so on) a shim does nothing but hand over.
  `reference-transaction` and the fsmonitor and p4 hooks have no shim.
- The repository's hooks are looked up in the common Git directory, so
  linked worktrees use the main checkout's hooks, as Git does itself.

A repository that sets its own `core.hooksPath` in local configuration
overrides the global one, and none of the hooks above run there.

### Other safety settings

- `merge.ff = "only"`: `git merge` refuses anything that is not a
  fast-forward. Rebase first, or pass `--no-ff` when a merge commit is
  wanted. `git pull` is unaffected because it rebases.
- The commit-message hook (conventional-commit format check) exists but
  is off: `enableCommitMsgHook` defaults to `false` and nothing turns
  it on.
- Aliases that explain themselves in use: `git pushf` is
  `push --force-with-lease`; `git undo` is `reset --soft HEAD~1` (the
  commit's changes stay staged); `git uncommit` is `reset HEAD~1` (they
  become unstaged); `git cleanup` deletes local branches already merged
  into the current one, except `main` and `master`.

The full alias list is in [Aliases](../reference/aliases.md).

## GitHub CLI

`modules/git/github.nix` installs `gh` and sets `git_protocol = "ssh"`,
the editor (the suite's editor), `prompt = "enabled"`, `pager = "less"`
and four `gh` aliases: `co` (`pr checkout`), `pv` (`pr view --web`),
`prm` and `prr` (pull requests authored by / awaiting review from you).
It also adds `git pr-*`, `git issue-*`, `git repo-*` and `git my-*`
aliases that shell out to `gh`, and shell aliases such as `prc` and
`myprs`.

### Writable `config.yml`

`gh` rewrites `~/.config/gh/config.yml` whenever it saves state, and it
saves that file before `hosts.yml`, which holds the token. Home Manager
would normally link `config.yml` read-only from the store, which made
every save fail and left refreshed tokens unwritten. The module
therefore disables the link and installs the same generated settings as
an ordinary file (mode 600) from an activation script, replacing it when
it is a symlink or differs from the declared settings. The declared
settings stay authoritative: a `gh config set` lasts until the next
switch. `hosts.yml` is never touched.

## Tools

`modules/git/tools.nix`, behind `programs.gitTools`:

| Tool | Default | What comes with it |
|---|---|---|
| lazygit | on | delta as its pager, file tree view; `git lg`, shell alias `lg`. Colours are overridden by `modules/cli/lazygit.nix` with the garden palette. |
| tig | on | `git t`, `git ta`, `git ts`, `git tb` |
| git-absorb | on | `git absorb`, `git fix` (`--and-rebase`) |
| git-filter-repo | **off** | package only |
| git-lfs | **off** | package and the `filter.lfs` settings |

Nothing in the user layer turns the last two on. To enable one, set
`programs.gitTools.gitLfs.enable = true` (or
`gitFilterRepo.enable`) in a user layer.

## Help

`modules/git/help.nix` installs `tldr` and adds:

- `git la` / `git list-aliases` — every git alias, sorted;
  `git help-config` — every setting with the file it came from.
- `~/.config/git/quick-ref.txt`, a one-page cheat sheet; `g-help`
  prints it.
- `git-help` and `g-examples`, both `tldr git`.

The cheat sheet lists the shell aliases. In interactive fish a few of
those names are abbreviations with different expansions; see
[Shells](../terminal/shells.md).

## Key files

| File | Purpose |
|---|---|
| `modules/git/bundle.nix` | `git-suite` bundle and the `programs.gitSuite` options |
| `modules/git/core.nix` | signing, delta, URL rewrites, push/pull/merge defaults, ignores |
| `modules/git/aliases.nix` | git aliases and shell aliases |
| `modules/git/identities.nix` | `includeIf` identities, `allowed_signers` |
| `modules/git/safety.nix` | `pre-commit` secret scan, `pre-push` hook, hook chaining, `merge.ff`, safety aliases |
| `modules/git/github.nix` | `gh` settings, writable config, GitHub aliases |
| `modules/git/tools.nix` | lazygit, tig, git-absorb, optional lfs and filter-repo |
| `modules/git/help.nix` | help aliases, quick reference, tldr |
| `modules/cli/delta.nix` | garden delta theme |
| `modules/user-ada.nix` | enables the suite; declares identities and `programs.ssh` |
