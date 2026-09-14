---
title: presenterm × PC-98
sub_title: a terminal deck for talks about code
author: ada
event: demo deck
date: 2026-09-13
---

Why present from a terminal
===

<!-- speaker_note: This deck lives at ~/.local/share/presenterm/pc98-demo.md. Copy it as a starting point. -->

- the slides are a markdown file next to the code
- every code block is real, highlighted source
- nothing to alt-tab to: the demo *is* the slide

<!-- pause -->

> [!tip]
> Press `?` for keybindings, `Ctrl+P` for the slide index.

---

Walk through a function
===

Highlight groups step with the arrow keys.

```rust {1-2|4-9|11-14} +line_numbers
use std::collections::HashMap;
use std::io;

fn count_words(input: &str) -> HashMap<&str, usize> {
    let mut counts = HashMap::new();
    for word in input.split_whitespace() {
        *counts.entry(word).or_insert(0) += 1;
    }
    counts
}

fn main() -> io::Result<()> {
    let counts = count_words("a b a");
    println!("{counts:?}");
    Ok(())
}
```

---

Run it live
===

`+exec` blocks run on `Ctrl+E`; output lands below the block.

```bash +exec
nix --version
uname -m
```

---

Two columns
===

<!-- column_layout: [3, 2] -->

<!-- column: 0 -->

```nix
{ den, ... }:
{
  den.aspects.presenterm.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.presenterm ];
    };
}
```

<!-- column: 1 -->

## The aspect

- one file under `modules/`
- auto-imported
- composed into a bundle

<span class="dim">no central import list</span>

<!-- reset_layout -->

---

Text and emphasis
===

Body text is <span class="hl">highlighted</span> with a palette class,
**bold** goes bright, and `inline code` sits on a panel.

> A block quote for the one sentence you want people to write down.

> [!warning]
> Alerts use the GitHub `[!note]` / `[!tip]` / `[!warning]` syntax.

---

<!-- font_size: 2 -->

Thanks
===

<!-- font_size: 1 -->

- `present deck.md` — this look, fullscreen Ghostty
- `present --kitty deck.md` — same in Kitty, with 2x headings
- `presenterm --export-html deck.md` — a single file to send around
