# Pre-Flight Checklist: First Niri Session

> Run through this list **on the ORNL work laptop** after the first
> `home-manager switch` completes and the root files (niri.desktop, PAM
> swaylock) are in place, but **before** logging into the "Niri (garden)"
> GDM session for the first time.

## 1. Rebuild with real values

If the last `home-manager switch` was run before the `_ornlid_`/`_work-host_`
placeholders were replaced with `tyo`/`LAP155464`, the session shim and
systemd units reference wrong paths. Rebuild:

```bash
cd ~/src/fern
home-manager switch --flake .
```

Then reload systemd so it picks up the new unit symlinks:

```bash
systemctl --user daemon-reload
```

Verify the shim exists and bootstraps the Nix env:

```bash
cat ~/.local/bin/niri-session-shim
# Should source the nix profile, set PATH/XDG_DATA_DIRS, exec niri-session
```

Verify linked systemd units:

```bash
ls -la ~/.config/systemd/user/niri.service
ls -la ~/.config/systemd/user/niri-shutdown.target
# Both should be symlinks into /nix/store
```

## 2. System-level checks (most need sudo)

### SSH keys

```bash
ls -la ~/.ssh/ornl ~/.ssh/ornl.pub
ls -la ~/.ssh/github ~/.ssh/github.pub   # optional
```

If `~/.ssh/ornl` is missing, generate it before the session (git
operations from the Niri session use this identity):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ornl
```

### video group (brightnessctl)

```bash
groups | grep -q video && echo "OK: in video group" || echo "MISSING: video group"
```

If missing:

```bash
sudo usermod -aG video tyo
```

The group change takes effect at next login (which the Niri session
will be). Alternatively, `brightnessctl` may work without the `video`
group if Ubuntu 24.04's udev rules are permissive enough.

### GDM session file

```bash
cat /usr/share/wayland-sessions/niri.desktop
# Exec= must be /home/tyo/.local/bin/niri-session-shim
```

### PAM swaylock

```bash
cat /etc/pam.d/swaylock
# Should contain: auth include common-auth
```

### Ubuntu dependencies

These should all be present on a default Ubuntu GNOME install:

```bash
dpkg -l xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome \
  pipewire wireplumber 2>/dev/null | grep '^ii'
```

All five should show as installed.

### wpctl (volume keys depend on it)

```bash
which wpctl   # from wireplumber, should be /usr/bin/wpctl
wpctl status   # should show sinks/sources
```

## 3. User-level checks

### niri-session is on PATH

```bash
which niri-session
# Should be in ~/.nix-profile/bin/ or the Nix profile
```

### GL wrapping works

```bash
nixGLMesa glxinfo 2>/dev/null | grep -i renderer
# Should show real GPU (e.g., "Mesa Intel..." or "AMD..."), NOT llvmpipe
```

If this shows software rendering or fails, nixGL wrapping has an issue
and the Niri session will also fail to render.

### quickshell (garden shell) is available

```bash
which qs
qs --version
```

### Portal config is in place

```bash
cat ~/.config/xdg-desktop-portal/niri-portals.conf
# Should list [niri] default=gtk;gnome
```

### Fonts installed

```bash
fc-list | grep -i "M PLUS 1p" | head -1
fc-list | grep -i "IBM Plex Mono" | head -1
# Both should return results after home-manager activation
```

### ssh-agent conflict check

```bash
pgrep -a ssh-agent
# Home-manager enables services.ssh-agent. If Ubuntu/GNOME also starts
# one, there may be two. Usually harmless but worth noting. The Niri
# session starts fresh so the HM-managed agent should take over.
```

## 4. First login: what to expect

1. Log out of GNOME -> GDM greeter appears
2. Click the gear/session selector -> choose **"Niri (garden)"**
3. The shim bootstraps the Nix env and runs `niri-session`
4. Expected startup:
   - Niri compositor starts (scrollable-tiling desktop)
   - xwayland-satellite launches (X11 app support)
   - quickshell starts the garden shell (bar, launcher, notifications)
   - Two kitty terminals open: one on "research", one btop on "system"
   - swayidle begins its 600s idle timer

### Verify after login

| Binding | Action |
|---------|--------|
| `Mod+Slash` | garden launcher opens |
| `Mod+Tab` | garden switcher |
| `Mod+N` | new kitty terminal |
| `Mod+B` | Firefox |
| `Mod+1`--`Mod+5` | switch workspaces (studio/research/writing/music/system) |
| `Mod+S` | screenshot (region mode) |
| `Mod+Alt+L` | lock screen (PAM unlock with Ubuntu password) |
| Brightness keys | panel brightness (brightnessctl) |
| Volume keys | wpctl adjusts default sink |
| `Mod+Shift+E` | quit niri (back to GDM) |

## 5. If things go wrong

### Black screen / niri doesn't start

1. Switch to TTY: `Ctrl+Alt+F3`
2. Log in, then check the journal:

   ```bash
   journalctl --user -u niri.service -b --no-pager | tail -40
   systemctl --user status niri.service
   ```

3. Common causes:
   - **nixGL wrap failure** -- fall back to unwrapping niri and wrapping
     the ExecStart instead (see the comment in `ubuntu-desktop.nix`)
   - **Missing GL libs** -- run `nixGLMesa glxinfo` from TTY to diagnose
   - **niri validate failure** -- run `niri validate` from the Nix env

### Garden shell doesn't appear (no bar)

```bash
journalctl --user -u quickshell -b 2>/dev/null || \
  journalctl --user --grep quickshell -b --no-pager | tail -20
```

Garden may need a moment to connect via IPC. If it never appears,
check that `qs -c garden` works from a terminal inside Niri.

### Lock screen doesn't unlock

- PAM issue: verify `/etc/pam.d/swaylock` exists with `auth include common-auth`
- Try `swaylock` directly from a terminal to test PAM independently

### GNOME session broken after

- Shouldn't happen -- the Niri session is additive (separate .desktop file)
- If GDM itself is broken, recover via TTY: `sudo systemctl restart gdm`

## 6. Known limitations (first session)

- **Garden BrightnessService** is DDC-only -- the panel brightness OSD
  won't show for brightnessctl changes; the brightness still changes,
  just without visual feedback from garden.
- **Screencast portal** is untested under `XDG_CURRENT_DESKTOP=niri`.
- **gnome-keyring**: Ubuntu may autostart one; the HM config may also
  enable it -- watch for double-daemon warnings in the journal.
- **Native Ubuntu apps** inherit the nixGL `LD_LIBRARY_PATH`; if one
  misbehaves, launch it with `env -u LD_LIBRARY_PATH <app>` instead.
