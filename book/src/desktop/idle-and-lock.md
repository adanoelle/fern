# Idle & Lock

> hypridle manages idle timeouts (dim, lock, suspend) and hyprlock provides the
> lock screen with Catppuccin styling.

The idle and lock configuration lives in
`nix/home/desktop/hyprland/idlelock.nix` and is enabled via
`desktop.hyprland.idle.enable` and `desktop.hyprland.lock.enable`.

## Idle timeouts

hypridle watches for inactivity and triggers actions at three thresholds:

| Timeout    | Action                          |
| ---------- | ------------------------------- |
| 5 minutes  | Reduce screen brightness to 10% |
| 10 minutes | Launch hyprlock                 |
| 20 minutes | Suspend the system              |

When activity resumes before the lock triggers, brightness is restored to its
previous level.

## Lock screen

hyprlock displays a lock screen with:

- **Font**: FiraCode Nerd Font at 18pt
- **Text color**: `#c6d0f5` (Catppuccin text)
- **Input field background**: `#303446` (Catppuccin base)
- **Input field border**: `#ca9ee6` (Catppuccin mauve)

The lock screen shows a password input field. Entering the user password unlocks
the session.

## Configuration

Both are controlled by options in the host configuration:

```nix
desktop.hyprland = {
  idle.enable = true;   # hypridle
  lock.enable = true;   # hyprlock
};
```

Setting `idle.enable = false` disables all automatic timeout behavior. Setting
`lock.enable = false` removes the lock screen (hypridle would still dim the
screen but would not lock).

## Key files

| File                                     | Purpose                           |
| ---------------------------------------- | --------------------------------- |
| `nix/home/desktop/hyprland/idlelock.nix` | hypridle + hyprlock configuration |
