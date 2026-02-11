# Helix Editor

> Helix is the default editor, configured with a Catppuccin theme, relative line
> numbers, and per-language LSP integration provided by each language toolchain
> module.

Helix is set as the default editor via `EDITOR=hx` and `VISUAL=hx`. The base
configuration lives in `nix/home/cli/helix.nix`, while language-specific LSP
servers are configured by each toolchain module in `nix/home/devtools/`.

## Base configuration

| Setting                    | Value               |
| -------------------------- | ------------------- |
| Theme                      | `catppuccin_frappe` |
| Line numbers               | Relative            |
| True color                 | Enabled             |
| Auto-save                  | Enabled             |
| Cursor shape (insert mode) | Bar                 |

## Keybindings

The configuration adds custom normal-mode keybindings:

| Binding       | Action      |
| ------------- | ----------- |
| `Space Space` | File picker |
| `Space w`     | Save        |
| `Space q`     | Quit        |

All other keybindings are Helix defaults (vim-like modal editing with `hjkl`
navigation, `i/a` for insert mode, `v` for visual mode).

## Language server integration

Each language toolchain module adds its LSP configuration to Helix. This means
enabling a language automatically adds editor support:

| Language              | LSP                        | Provided by                              |
| --------------------- | -------------------------- | ---------------------------------------- |
| Rust                  | rust-analyzer              | `nix/home/devtools/` (via system module) |
| C/C++                 | clangd                     | `nix/home/devtools/cpp.nix`              |
| Python                | pyright                    | `nix/home/devtools/python.nix`           |
| TypeScript/JavaScript | typescript-language-server | `nix/home/devtools/typescript.nix`       |
| C#                    | omnisharp                  | `nix/home/devtools/csharp.nix`           |
| Ada                   | ada_ls                     | `nix/home/devtools/ada.nix`              |

### clangd flags

The C/C++ LSP runs with `--background-index` and `--clang-tidy` enabled,
providing real-time static analysis and cross-file navigation.

## Language-specific overrides

```nix
# Rust: auto-format disabled (use cargo fmt manually)
languages.language = [{
  name = "rust";
  auto-format = false;
}];

# Markdown: prettier as formatter
languages.language = [{
  name = "markdown";
  formatter = { command = "prettier"; args = ["--parser" "markdown"]; };
}];
```

## Key files

| File                               | Purpose                          |
| ---------------------------------- | -------------------------------- |
| `nix/home/cli/helix.nix`           | Base Helix configuration         |
| `nix/home/devtools/cpp.nix`        | clangd LSP setup                 |
| `nix/home/devtools/python.nix`     | pyright LSP setup                |
| `nix/home/devtools/typescript.nix` | typescript-language-server setup |
| `nix/home/devtools/csharp.nix`     | omnisharp LSP setup              |
| `nix/home/devtools/ada.nix`        | ada_ls LSP setup                 |
