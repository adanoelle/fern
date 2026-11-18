# Presenting (presenterm)

> Talks about code are given from the terminal with
> [presenterm](https://github.com/mfontanini/presenterm): a Markdown
> deck with step-through code highlighting, runnable snippets, columns
> and speaker notes. The aspect ships three matched looks (a deck theme
> plus a Ghostty and a Kitty overlay each), a `present` launcher that
> opens a deck fullscreen in the right terminal, a demo deck, and a
> Claude Code skill that knows the conventions.

**Goes on:** every host (`presenterm` is in the `cli` bundle).

## Pieces

presenterm draws text; the terminal decides the font and the palette.
Each theme is therefore three files with the same name:

| Piece | Installed at | Source in `modules/cli/_presenterm/` |
|---|---|---|
| Deck theme | `~/.config/presenterm/themes/<theme>.yaml` | `<theme>.yaml` |
| Ghostty overlay | `~/.config/ghostty/<theme>` | `ghostty-<theme>` |
| Kitty overlay | `~/.config/kitty/<theme>.conf` | `kitty-<theme>.conf` |

Plus `~/.config/presenterm/config.yaml`, the demo deck at
`~/.local/share/presenterm/pc98-demo.md`, and the fonts the overlays
name (`ark-pixel-font`, `ibm-plex`).

All three deck themes highlight code with bat's `base16` theme, which
maps tokens onto the terminal's ANSI colours, so the overlay's palette
is the code palette too.

## Themes

| Theme | Look | Use |
|---|---|---|
| `shitanuri` (default) | IBM Plex Mono on raw umber, gilt accent, earth colours | matches the garden desktop; any audience |
| `graphite` | IBM Plex Mono, warm near-black, one amber accent | professional audiences |
| `pc98` | Ark Pixel 16px font, sixteen-colour retro palette | playful, demos |

`shitanuri` is the garden palette of the same name at presentation
strength: every text colour and every ANSI slot the highlighter uses
clears 4.5:1 contrast against both the ground and a panel. `graphite`
follows the same rule.

`shitanuri` and `graphite` follow the garden mono face when one is set:
their overlays include `~/.config/garden/fonts/ghostty` or
`~/.config/garden/fonts/kitty.conf` after their own font lines, and fall
back to IBM Plex Mono when the file does not exist. `pc98` keeps its
pixel font. See [Garden](../desktop/garden.md) for where those files
come from.

Kitty implements the text sizing protocol, so headings render at double
size there. Ghostty ignores the size hint.

## Commands

```bash
present deck.md                # fullscreen Ghostty, shitanuri theme
present --kitty deck.md        # the same in Kitty (2x headings)
present --here deck.md         # current terminal, no new window
present --theme pc98 deck.md   # or graphite; picks overlay and deck theme
present                        # the bundled demo deck
presenterm --export-html deck.md   # one self-contained HTML file
```

Options must come before the deck path; anything after them is passed to
presenterm. `present` finds `ghostty` and `kitty` on `PATH` rather than
pinning store paths, so the same script works on NixOS and on the work
laptop, where the terminals are GL-wrapped.

presenterm queries the terminal, so neither `present --here` nor the
HTML export works from a non-interactive shell.

## Writing a deck

What `config.yaml` sets, and what follows from it:

- `implicit_slide_ends: true` — a slide title starts a new slide and
  ends the one before it. Do not put `---` between titled slides: the
  title has already ended the slide, so the `---` ends it a second time
  and leaves an empty slide.
- `end_slide_shorthand: true` — `---` ends a slide. With the rule above
  it is only useful after a slide that has no title.
  `<!-- end_slide -->` is never needed.
- The config does not set `h1_slide_titles`. On its own it treats only
  setext titles (`Title` over `===`) as slide titles. The demo deck
  turns on `h1_slide_titles` (and repeats `implicit_slide_ends`) in its
  front matter so that `# Title` is a slide title; do the same in new
  decks. Helix formats Markdown with prettier on save, and prettier
  rewrites setext titles as `#`, so `#` titles are the form that
  survives editing.
- `incremental_lists: false` — lists appear whole; use
  `<!-- pause -->` to reveal in steps.
- `snippet.exec.enable: true` — `+exec` blocks run with `Ctrl+E`. Only
  present decks you trust. `+exec_replace` still needs `presenterm -X`.

Theme-specific conventions:

- `{1-3|5-9}` after the fence language steps highlight groups;
  `+line_numbers` adds numbers.
- `<span class="hl">` and `<span class="dim">` are the two palette
  classes every theme defines.
- Columns, pauses and speaker notes work as in the
  [upstream documentation](https://mfontanini.github.io/presenterm/).

The demo deck exercises all of this; copy it to start a talk.

## Claude Code skill

The aspect installs `~/.claude/skills/pc98-deck/SKILL.md` (source:
`modules/cli/_presenterm/SKILL.md`). It is a user-level skill, so Claude
Code loads it in any repository and writes decks that fit this setup.

## Key files

| File | Purpose |
|---|---|
| `modules/cli/presenterm.nix` | packages, `present` launcher, file installation |
| `modules/cli/_presenterm/config.yaml` | presenterm defaults and slide-ending options |
| `modules/cli/_presenterm/*.yaml` | deck themes |
| `modules/cli/_presenterm/ghostty-*`, `kitty-*.conf` | terminal overlays |
| `modules/cli/_presenterm/pc98-demo.md` | demo deck |
| `modules/cli/_presenterm/SKILL.md` | Claude Code skill |
