# Pre-Flight Checklist: First Niri Session

> Run through this list **on the ORNL work laptop** after the first
> `home-manager switch` completes and the root files (niri.desktop, PAM
> swaylock) are in place, but **before** logging into the "Niri (garden)"
> GDM session for the first time.

## Status (2026-07-31)

Niri session boots and runs. Lock screen workaround in place.

- [x] 1. Rebuild with real values (`home-manager switch` done)
- [x] 2. System-level checks (all pass)
- [x] 3. User-level checks (all pass, font bug noted)
- [x] 4. First login into Niri (garden) — session works
- [x] 5. Post-login verification — lock screen resolved (see below)

### Non-blocking issues found

- **Font name mismatch in `modules/fonts.nix`**: the fontconfig
  `defaultFonts` reference `"M PLUS 1p"` (old name) but
  `mplus-outline-fonts.githubRelease` installs `"M PLUS 1"` (new name).
  `fc-match "M PLUS 1p"` falls back to DejaVu Sans. Fix: change
  `"M PLUS 1p"` to `"M PLUS 1"` in `modules/fonts.nix` (lines 29, 33).
  Cosmetic only — affects fern too.

- **SSH keys**: `~/.ssh/github` created and registered with GitHub
  (auth + signing). `~/.ssh/ornl` exists but not yet registered with
  ORNL GitLab (deferred). GitHub commit signing works.

### BLOCKER: Lock screen authentication fails (YubiKey PAM)

**Problem**: Neither garden lock nor swaylock can authenticate on the
ORNL laptop. Both accept input but reject password and YubiKey PIN.
GDM authenticates the same YubiKey successfully.

**Root cause analysis**:

1. **Garden lock** — garden's `PamContext` only handles single-response
   PAM conversations. ORNL's `pam_u2f` (or `pam_pkcs11` in
   `common-auth`) uses a multi-step conversation (PIN → touch).
   Garden cannot drive this flow. Symptom: full red screen, no input
   accepted.

2. **Swaylock** — uses the Nix-packaged `libpam.so`, not Ubuntu's
   system libpam. Even with absolute module paths in
   `/etc/pam.d/swaylock`, the Nix libpam may handle the PKCS#11 /
   YubiKey conversation differently from Ubuntu's libpam. Additionally,
   `pam_pkcs11` may need session context (pcscd socket, environment)
   that GDM provides but swaylock does not.

3. **`pam_unix` fallback also fails** — even typing the Ubuntu user
   password (not YubiKey PIN) does not unlock. The YubiKey being
   inserted may cause `pam_pkcs11` (marked `sufficient`) to intercept
   and fail before `pam_unix` is reached.

**Current `/etc/pam.d/swaylock`** (rewritten with absolute paths):
```
auth sufficient /usr/lib/x86_64-linux-gnu/security/pam_pkcs11.so nodebug quiet
auth [success=1 default=ignore] /usr/lib/x86_64-linux-gnu/security/pam_unix.so nullok
auth requisite /usr/lib/x86_64-linux-gnu/security/pam_deny.so
auth required  /usr/lib/x86_64-linux-gnu/security/pam_permit.so
```

**Approaches tested and results**:

| Approach | Result |
|----------|--------|
| Garden lock (`qs -c garden ipc call garden lock`) | Red screen, no input accepted (PamContext can't drive multi-step PAM) |
| Swaylock | Accepts input but rejects password and PIN (Nix libpam + pam_pkcs11 incompatibility) |
| `loginctl lock-session` | No-op — GDM doesn't listen for the Lock signal on Niri sessions (only gnome-shell handles it) |

**Solution: VT-switch to GDM greeter (verified working)**

Switching to tty1 (`Ctrl+Alt+F1`) triggers GDM to spawn a fresh
greeter. YubiKey authenticates normally. GDM then returns the user
to the existing Niri session on tty2. The Niri session stays running
throughout — no processes killed, no compositor lock screen involved.

**Tested 2026-07-31**: `Ctrl+Alt+F1` → GDM greeter → YubiKey auth
→ returned to Niri session on tty2. Works.

**Session facts** (from `loginctl session-status`):
- Session ID: 2, user tyo (24279)
- Niri runs on: **tty2** (seat0, vc2)
- Service: gdm-password, Type: wayland, Class: user
- Leader: gdm-session-worker (pid 2546)
- GDM greeter VT: **tty1** (spawns on demand, no persistent session)

**What still needs to happen**:

Manual `Ctrl+Alt+F1` works, but swayidle (idle timeout) and
before-sleep (lid close) currently fire `swaylock`, which **will trap
you** in a broken lock screen. These must be changed to trigger
`chvt 1` instead, so idle and lid-close are safe.

`chvt` requires root. The proposed solution is a narrowly-scoped
sudoers rule:

```
tyo ALL=(root) NOPASSWD: /usr/bin/chvt 1
```

This allows only `chvt 1` (switch to GDM's VT), nothing else.
`chvt` itself doesn't execute anything — it's a kernel ioctl that
changes the active virtual terminal.

**Status (2026-07-31): RESOLVED — workaround in place.**

swayidle is disabled entirely (`services.swayidle.enable = mkForce
false` in `user-ada-work.nix`). `Mod+Alt+L` is a no-op (`spawn
["true"]`). swaylock removed from `home.packages`. No idle or
lid-close lock triggers exist — the session cannot trap the user in
a broken lock screen.

**Lock workflow**: manually press `Ctrl+Alt+F1` before stepping away
or closing the lid. GDM spawns its greeter, YubiKey authenticates,
GDM returns to the Niri session on tty2.

**Automated lock is not possible** without a root-level `chvt 1`
call. A sudoers drop-in was considered but CFEngine manages
`/etc/sudoers.d/` on this machine, so any local rule could be
overwritten. This is accepted as a known limitation.

### If picking up from a new Claude session

The lock screen issue is resolved. swayidle is disabled, swaylock is
removed, `Mod+Alt+L` is a no-op. Lock manually with `Ctrl+Alt+F1`.

If revisiting automated lock in the future, the constraint is:
`chvt 1` requires root, and CFEngine manages `/etc/sudoers.d/` so
a local drop-in is unreliable. Alternatives to explore: polkit
action for VT switching, `CAP_SYS_TTY_CONFIG` capability, or an
upstream fix to garden's `PamContext` for multi-step PAM conversations.

Key files:
- `modules/user-ada-work.nix` -- swayidle disabled, lock keybind no-op
- `modules/desktop/niri.nix` -- base swayidle config (overridden)
- `modules/foreign/ubuntu-desktop.nix` -- nixGL wrapping, session shim
- `book/src/operations/work-laptop.md` -- runbook

---

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
ls -la ~/.ssh/github ~/.ssh/github.pub
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

### PAM swaylock (no longer used)

swaylock is disabled on the ORNL laptop (YubiKey PAM incompatibility).
`/etc/pam.d/swaylock` exists on the host but is not exercised.
See the BLOCKER section in Status above.

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
# Should list [preferred] default=gtk;gnome
```

### Fonts installed

```bash
fc-match "M PLUS 1"     # should resolve to Mplus1, NOT DejaVu
fc-match "IBM Plex Mono" # should resolve to IBMPlexMono
```

Note: the config currently references `"M PLUS 1p"` (old name) but the
installed font is `"M PLUS 1"`. See the status section for the fix.

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
| `Mod+Alt+L` | no-op (disabled — use `Ctrl+Alt+F1` to lock via GDM) |
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

### Lock screen

swayidle and swaylock are disabled on the ORNL laptop. The only lock
mechanism is `Ctrl+Alt+F1` (VT-switch to GDM greeter). See the
BLOCKER section in Status above for the full history.

If someone accidentally triggers garden lock (e.g., via `qs` IPC):
1. `Ctrl+Alt+F3` → TTY login
2. `pkill -f "qs.*garden"`
3. `Ctrl+Alt+F2` → back to Niri

### GNOME session broken after

- Shouldn't happen -- the Niri session is additive (separate .desktop file)
- If GDM itself is broken, recover via TTY: `sudo systemctl restart gdm`

## 6. Known limitations (first session)

- **Font name mismatch**: `"M PLUS 1p"` in fontconfig defaults doesn't
  match the installed `"M PLUS 1"`. Sans-serif falls back to DejaVu.
  Fix pending in `modules/fonts.nix`.
- **Garden BrightnessService** is DDC-only -- the panel brightness OSD
  won't show for brightnessctl changes; the brightness still changes,
  just without visual feedback from garden.
- **Screencast portal** is untested under `XDG_CURRENT_DESKTOP=niri`.
- **gnome-keyring**: Ubuntu may autostart one; the HM config may also
  enable it -- watch for double-daemon warnings in the journal.
- **Native Ubuntu apps** inherit the nixGL `LD_LIBRARY_PATH`; if one
  misbehaves, launch it with `env -u LD_LIBRARY_PATH <app>` instead.
