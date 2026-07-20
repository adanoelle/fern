# Fern Documentation

This repository has two documentation systems:

- **[The Book](../book/)** — comprehensive system reference built with mdBook.
  Covers architecture, modules, operations, shells, git, desktop, and more.
  Run `just book-serve` for live preview.
- **docs/** (this directory) — design planning documents.

## When to use which

| Question | Go to |
|----------|-------|
| How does the system work? | The Book — `book/src/` |
| How is the flake structured? | Book — [Architecture](../book/src/architecture/) |
| How do I use git identities / the git suite? | Book — [Git](../book/src/git/) |
| Day-to-day conventions and safety rules | [CLAUDE.md](../CLAUDE.md) |
| Garden shell / palette design planning | [plan/](./plan/) |

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
2. Design planning belongs in **docs/plan/**
3. Format with `nixfmt` and follow conventional commits
