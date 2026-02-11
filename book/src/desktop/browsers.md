# Browsers

> Two browsers are configured: Nyxt (keyboard-driven, default) and ungoogled
> Chromium (Wayland-native, privacy-hardened).

## Nyxt

Nyxt is a keyboard-driven, extensible browser set as the default for HTTP/HTTPS
URLs. It is wrapped with environment variables to work around NVIDIA/Wayland
rendering issues.

### NVIDIA/Wayland workarounds

The Nyxt package is wrapped with:

```bash
WEBKIT_DISABLE_COMPOSITING_MODE=1
WEBKIT_DISABLE_DMABUF_RENDERER=1
__GL_THREADED_OPTIMIZATIONS=0
```

These prevent WebKitGTK from using DMA-BUF and threaded GL rendering, which
cause visual glitches or crashes with NVIDIA's Wayland driver.

### Keybindings

The Nyxt configuration remaps controls from Ctrl to Super, matching the Hyprland
mod key convention:

| Binding                   | Action                   |
| ------------------------- | ------------------------ |
| `Super + L`               | Set URL                  |
| `Super + [` / `Super + ]` | History back / forward   |
| `Super + T`               | Open new buffer          |
| `Super + W`               | Close buffer             |
| `Super + Tab`             | Switch buffer            |
| `Super + G`               | Follow link (link hints) |

Configuration is written in Common Lisp and stored via Home Manager.

## Chromium

Ungoogled Chromium is configured as a secondary browser with Wayland support and
privacy hardening.

### Launch flags

```
--ozone-platform=wayland
--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,VaapiVideoDecoder
--disable-features=UseChromeOSDirectVideoDecoder,FedCm,IdentityInCanSignIn
--use-gl=egl
--disable-sync
--password-store=basic
```

The `NIXOS_OZONE_WL=1` environment variable is also set to signal Wayland mode
to Electron-based applications.

### Hardware acceleration

VAAPI video decoding is enabled via `--enable-features=VaapiVideoDecoder` and
EGL rendering via `--use-gl=egl`. This provides GPU-accelerated video playback
on both NVIDIA and Asahi.

## Key files

| File                            | Purpose                                          |
| ------------------------------- | ------------------------------------------------ |
| `nix/home/desktop/nyxt.nix`     | Nyxt browser with NVIDIA wrapper and Lisp config |
| `nix/home/desktop/chromium.nix` | Ungoogled Chromium with Wayland/privacy flags    |
