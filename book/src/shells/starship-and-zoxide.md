# Starship & Zoxide

> Starship provides a cross-shell prompt with Git status and Nix indicators.
> Zoxide replaces `cd` with a frecency-based directory jumper.

## Starship

The `starship` aspect (`modules/shells/starship.nix`) configures the
[Starship](https://starship.rs) prompt using Home Manager's
`programs.starship` module:

```nix
den.aspects.starship.homeManager = { ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[>](bold green)";
      };
      nix_shell = {
        symbol = " ";
      };
    };
  };
};
```

### What the prompt shows

- **Git branch and status** -- Current branch, dirty/clean state, ahead/behind
  upstream
- **Nix shell indicator** -- Shows when inside a `nix develop` or `nix-shell`
  environment
- **Success/error symbol** -- Green `>` on success, red on error
- **Directory** -- Current path, truncated for readability

Starship integrates with Nushell through the activation hooks configured in the
Nushell aspect.

## Zoxide

The `zoxide` aspect (`modules/shells/zoxide.nix`) configures
[Zoxide](https://github.com/ajeetdsouza/zoxide), a smarter `cd` replacement
that learns your most-used directories:

```nix
den.aspects.zoxide.homeManager = { ... }: {
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
};
```

### Usage

| Command | Description |
|---------|-------------|
| `z <query>` | Jump to the best match for `<query>` |
| `zi <query>` | Interactive selection with fzf |
| `z -` | Jump to the previous directory |

Zoxide builds a database of visited directories ranked by frequency and recency
(frecency). `z proj` jumps to `/home/ada/personal/my-project` if that is your
most frequent match, without typing the full path.

### Nushell integration

Setting `enableNushellIntegration = true` adds `z` and `zi` as Nushell commands
rather than shell aliases. This makes them first-class citizens in Nushell's
command system.

## Key files

| File | Purpose |
|------|---------|
| `modules/shells/starship.nix` | Starship prompt configuration |
| `modules/shells/zoxide.nix` | Zoxide directory jumper |
| `modules/shells/bundle.nix` | Shells bundle (includes both) |
