# Graphics & NVIDIA

> NVIDIA GPU with modesetting for Wayland, VRR/GSync support, and a separate
> Asahi driver path for Apple Silicon.

The graphics configuration has two variants: `graphics.nix` for NVIDIA GPUs
(fern) and `graphics-asahi.nix` for Apple Silicon (moss). Both enable the
Hyprland compositor.

## NVIDIA configuration (fern)

The NVIDIA module (`nix/modules/graphics.nix`) configures:

| Setting            | Value                              |
| ------------------ | ---------------------------------- |
| Video driver       | `nvidia`                           |
| Modesetting        | Enabled (required for Wayland/GBM) |
| Power management   | Disabled                           |
| Open kernel module | Disabled (proprietary driver)      |
| Driver package     | Production release                 |

### Environment variables

```bash
__GL_GSYNC_ALLOWED=1          # Enable GSync/VRR
__GL_VRR_ALLOWED=1            # Enable variable refresh rate
WLR_NO_HARDWARE_CURSORS=1     # Software cursors (NVIDIA Wayland workaround)
__GLX_VENDOR_LIBRARY_NAME=nvidia  # Ensure NVIDIA GLX is used
```

### Wayland compatibility

Modesetting must be enabled for NVIDIA's Wayland/GBM backend to function. The
`WLR_NO_HARDWARE_CURSORS=1` variable works around a cursor rendering bug with
NVIDIA under wlroots-based compositors like Hyprland.

### GPU tools

| Package        | Purpose                                     |
| -------------- | ------------------------------------------- |
| `mesa-demos`   | `glxinfo`, `eglinfo` for testing GL support |
| `vulkan-tools` | `vulkaninfo` for testing Vulkan support     |

## Asahi configuration (moss)

The Asahi module (`nix/modules/graphics-asahi.nix`) uses the experimental GPU
driver:

```nix
hardware.asahi = {
  useExperimentalGPUDriver = true;
  experimentalGPUInstallMode = "replace";
};
```

This replaces the default Mesa driver with the Asahi-specific one that supports
the Apple GPU. The same GPU tools (`mesa-demos`, `vulkan-tools`) are installed.

## Hyprland

Both modules enable `programs.hyprland.enable = true`, which installs the
Hyprland compositor and sets up the Wayland session. The actual Hyprland
configuration (keybindings, layout, animations) is handled by the Home Manager
module in `nix/home/desktop/hyprland/`.

## Key files

| File                                 | Purpose                           |
| ------------------------------------ | --------------------------------- |
| `nix/modules/graphics.nix`           | NVIDIA driver, env vars, Hyprland |
| `nix/modules/graphics-asahi.nix`     | Asahi GPU driver, Hyprland        |
| `nix/home/desktop/hyprland/core.nix` | Hyprland user configuration       |
