# Presenting (presenterm)

Talks about code are given from the terminal with
[presenterm](https://github.com/mfontanini/presenterm): a markdown deck,
step-through code highlighting, live snippets, columns, speaker notes and
HTML/PDF export. The aspect is `modules/cli/presenterm.nix`; its static
files live in `modules/cli/_presenterm/`.

## The PC-98 look

presenterm draws text; the terminal decides how it looks. The aesthetic is
therefore split in two:

| Piece | File | What it does |
|---|---|---|
| Deck theme | `~/.config/presenterm/themes/pc98.yaml` | colours, heading prefixes, flat code blocks, footer |
| Ghostty overlay | `~/.config/ghostty/pc98` | Ark Pixel 16px font, 16-colour palette, fullscreen, amber block cursor |
| Kitty overlay | `~/.config/kitty/pc98.conf` | the same for Kitty |

Every colour is 4 bits per channel, one of the 4096 colours the PC-9801
could display, sixteen at a time. Code is highlighted with bat's `base16`
theme, which maps tokens onto the terminal's ANSI slots, so the overlay's
palette is the code palette too.

Kitty implements the text sizing protocol, so headings render at 2x there.
Ghostty ignores the size hint and shows headings in the normal cell size.

## Commands

```bash
present deck.md            # fullscreen PC-98 Ghostty running presenterm
present --kitty deck.md    # same in Kitty (2x headings)
present --here deck.md     # current terminal, no new window
present                    # the bundled demo deck
presenterm --export-html deck.md   # self-contained HTML
presenterm --export-pdf deck.md    # needs weasyprint on PATH
```

The demo deck at `~/.local/share/presenterm/pc98-demo.md` exercises every
feature used above; copy it to start a new talk.

## Writing a deck

- A setext title (`Title` over `===`) starts a slide, `---` ends it.
  No `<!-- end_slide -->` needed (`implicit_slide_ends`, `end_slide_shorthand`).
- `{1-3|5-9}` after the language steps highlight groups; `+line_numbers`,
  `+exec`, `+no_background` are the usual snippet flags.
- `<!-- pause -->`, `<!-- column_layout: [3, 2] -->`, `<!-- column: 0 -->`,
  `<!-- speaker_note: … -->` work as in upstream docs.
- `<span class="hl">` and `<span class="dim">` are palette classes defined
  in the theme.

`+exec` blocks are enabled in the config, so only present decks you trust.
