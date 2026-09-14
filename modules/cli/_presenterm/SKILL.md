---
name: pc98-deck
description: Write, run, and export terminal slide decks with presenterm using the PC-98 setup installed on this machine (pc98 theme, `present` launcher). Use when asked for slides, a talk, a deck, or a presentation, especially one about code.
---

# PC-98 decks with presenterm

This machine has presenterm installed with a PC-98 look. The look is
fixed by the terminal profile and theme, so a deck only needs to be a
plain markdown file. Managed by the fern repo, `modules/cli/presenterm.nix`.

Installed pieces:

| Path | Role |
|---|---|
| `~/.config/presenterm/config.yaml` | default theme `pc98`, `implicit_slide_ends`, `end_slide_shorthand`, `+exec` enabled |
| `~/.config/presenterm/themes/pc98.yaml` | colours, prefixes, footer, palette classes |
| `~/.config/ghostty/pc98`, `~/.config/kitty/pc98.conf` | pixel font and 16-colour palette |
| `~/.local/share/presenterm/pc98-demo.md` | reference deck that uses every feature below |
| `present` | launcher script |

## Workflow

1. Put the deck at `<repo>/talks/<name>.md` (or wherever the user says).
   One file, no assets needed; images are optional.
2. Write slides using the rules below. Copy structure from the demo deck
   when unsure.
3. Check it parses without opening a window:
   `present --here <deck>.md` runs presenterm in the current terminal
   (needs a real terminal; it will not work from a non-interactive shell).
   For a headless parse check use the HTML export:
   `presenterm --export-html -o /tmp/deck.html <deck>.md`.
4. Hand over the run command: `present <deck>.md` (fullscreen Ghostty) or
   `present --kitty <deck>.md` (Kitty, honours 2x headings).
5. To share: `presenterm --export-html <deck>.md` gives one self-contained
   file. `--export-pdf` needs weasyprint on PATH.

## Deck format

````markdown
---
title: Talk title
sub_title: one line
author: name
event: Conference 2026
date: 2026-10-01
---

First slide title
===

- bullets
- more

<!-- pause -->

Content that appears on the next keypress.

---

Second slide
===

```rust {1-3|5-9} +line_numbers
// highlight lines 1-3 first, then 5-9
```

---
````

- Front matter makes the intro slide. `title` is required for the footer.
- A setext title (`Text` over `===`) starts a slide. `---` ends it.
  Never write `<!-- end_slide -->`; the config handles slide ends.
- `#`, `##`, `###` inside a slide are section headings with prefixes
  `■`, `▶`, `»`, not slide titles.

## Code

- Fence with a language. `{1-3|5-9}` after the language steps highlight
  groups on successive keypresses. `+line_numbers` adds numbers.
- `+exec` makes a block runnable with Ctrl+E; output appears below.
  Only for commands safe to run on the presenter's machine.
- `+exec_replace` runs at load and replaces the block with output; it is
  off by default and needs `presenterm -X`.
- Include real source instead of pasting:

  ```file +line_numbers
  path: src/main.rs
  language: rust
  start_line: 1
  end_line: 40
  ```

- Code blocks are flat (no background) and left-aligned. Keep lines under
  70 columns; the pixel font is wide and the display budget is roughly
  110 columns by 30 rows at the shipped font size, less on a projector.

## Layout and emphasis

- Columns: `<!-- column_layout: [3, 2] -->`, then `<!-- column: 0 -->`,
  `<!-- column: 1 -->`, and `<!-- reset_layout -->` when done.
- `<!-- pause -->` reveals the rest of the slide on keypress.
- `<!-- speaker_note: text -->` for notes. Present with
  `present deck.md -P` and run `presenterm -l deck.md` in another terminal to see them.
- `<!-- font_size: 2 -->` doubles text until `<!-- font_size: 1 -->`
  (Kitty only; ignored in Ghostty).
- `<span class="hl">text</span>` is a yellow highlighter pen and
  `<span class="dim">text</span>` is grey. These are the only classes.
- Block quotes and GitHub alerts (`> [!note]`, `[!tip]`, `[!warning]`,
  `[!caution]`, `[!important]`) render as flat panels.
- Mermaid and D2 fences render as images only if `mmdc` or `d2` is on
  PATH; neither is installed by default, so prefer ASCII diagrams.

## Style for this look

- One idea per slide. A function, a diagram, a claim.
- Titles in a few words. The slide title is the only large text.
- Prefer code over prose; prefer a bullet list over a paragraph.
- No emoji, no nerd-font icons, no box-drawing tables wider than the
  column budget.
- Fifteen to twenty-five slides for a thirty minute talk.

## Colours

The palette is sixteen colours, four bits per channel. Do not invent
others. If a slide needs its own colour, use `<span style="color: #aaddff">`
with one of these:

| name | hex | use |
|---|---|---|
| pink | `#ffaabb` | titles |
| sky | `#aaddff` | headings, links |
| green | `#55dd55` | success, h2 |
| orange | `#ff9900` | warnings, dates |
| magenta | `#cc55cc` | emphasis |
| cyan | `#55ccdd` | author line |
| lavender | `#aaaaff` | quotes, h3 |
| cream | `#ffeecc` | body text |
| dust | `#ccbbcc` | secondary text |
