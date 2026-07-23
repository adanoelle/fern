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
| How the garden desktop is integrated | Book — [Garden](../book/src/desktop/garden.md) |
| Garden design references / open decisions | [plan/garden-design-docs/](./plan/garden-design-docs/) |
| What the garden build plan was (historical) | [plan/archive/](./plan/archive/) |

## Planning

Design documents for upcoming and in-flight work. These are living drafts,
not reference material — once something ships, the book documents it.

- **[plan/](./plan/)** — active plans (`art-bundle.md`) and the garden shell
  `.jsx` mockups
- **[plan/garden-design-docs/](./plan/garden-design-docs/)** — garden design
  references (00–08, 11); `06-open-questions.md` is the living decision record
- **[plan/archive/](./plan/archive/)** — completed plans from the garden
  build-out (build/session plans, handoffs, jam session); see its README
- Shell-internal planning lives in the **garden-shell repo**
  (`plan/core-services-plan.md`)

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
