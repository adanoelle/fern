# Fern Documentation

This repository has two documentation systems:

- **[The Book](../book/)** — comprehensive system reference built with mdBook.
  Covers architecture, modules, operations, shells, git, desktop, and more.
  Run `just book-serve` for live preview.
- **docs/** (this directory) — operational quick-reference guides and design
  planning documents.

## When to use which

| Question | Go to |
|----------|-------|
| How does the system work? | The Book — `book/src/` |
| How is the flake structured? | Book — [Architecture](../book/src/architecture/) |
| How do I use git worktrees / identities? | Book — [Git](../book/src/git/) |
| Quick command cheat-sheet for git | [guides/git-suite.md](./guides/git-suite.md) |
| Claude Code workflow tips | [guides/claude-workflow.md](./guides/claude-workflow.md) |
| CLAUDE.md system design guide | [guides/CLAUDE-DEVELOPER-GUIDE.md](./guides/CLAUDE-DEVELOPER-GUIDE.md) |
| Garden shell / palette design planning | [plan/](./plan/) |

## Guides

Operational quick-reference — these complement the book with copy-paste
commands and concise workflows.

- **[git-suite.md](./guides/git-suite.md)** — Aliases, worktrees, identities,
  Claude integration, troubleshooting
- **[claude-workflow.md](./guides/claude-workflow.md)** — Working with Claude
  Code in worktrees, safety features, templates
- **[CLAUDE-DEVELOPER-GUIDE.md](./guides/CLAUDE-DEVELOPER-GUIDE.md)** — Design
  philosophy and maintenance guide for the CLAUDE.md system

## Planning

Active design documents for upcoming work. These are living drafts, not
reference material.

- **[plan/](./plan/)** — Garden design system: shell mockups, palette editor,
  session handoff notes, jam sessions

## Common Commands

```bash
just              # list all recipes
just switch       # rebuild and switch
just test         # test without switching
just test-trace   # test with --show-trace
just fmt          # format Nix files
just check        # nix flake check
just book-serve   # serve book with live reload
```

## Contributing

1. System reference content belongs in the **book** (`book/src/`)
2. Quick-reference cheat sheets belong in **docs/guides/**
3. Design planning belongs in **docs/plan/**
4. Format with `nixpkgs-fmt` and follow conventional commits
