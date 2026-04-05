# Graphics & GPU

> GPU configuration with Mesa/AMDGPU for fern, an NVIDIA aspect for reference,
> a separate Asahi driver path for Apple Silicon, and VRR support.

The graphics configuration is split into separate aspects included by different
hosts: `den.aspects.graphics` (`modules/graphics.nix`) for AMD/NVIDIA GPUs and
`den.aspects.graphics-asahi` (`modules/graphics-asahi.nix`) for Apple Silicon.
Both enable the Hyprland compositor.

## AMD configuration (fern)

The graphics aspect (`modules/graphics.nix`) configures fern with
Mesa/AMDGPU. The `den.aspects.graphics` aspect provides:

| Setting            | Value                                |
| ------------------ | ------------------------------------ |
| Video driver       | Mesa (AMDGPU)                        |
| Modesetting        | Enabled (required for Wayland/GBM)   |
| Vulkan             | RADV via Mesa                        |

The NVIDIA driver path remains in the aspect for reference but fern now uses
AMD.

### Environment variables

```bash
__GL_GSYNC_ALLOWED=1          # Enable GSync/VRR
__GL_VRR_ALLOWED=1            # Enable variable refresh rate
```

### GPU tools

| Package        | Purpose                                     |
| -------------- | ------------------------------------------- |
| `mesa-demos`   | `glxinfo`, `eglinfo` for testing GL support |
| `vulkan-tools` | `vulkaninfo` for testing Vulkan support     |

## Asahi configuration (moss)

The `den.aspects.graphics-asahi` aspect (`modules/graphics-asahi.nix`) uses the
experimental GPU driver:

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
aspect in `modules/desktop/hyprland.nix`.

## Key files

| File                                 | Purpose                           |
| ------------------------------------ | --------------------------------- |
| `modules/graphics.nix`           | AMD/GPU driver, env vars, Hyprland (`den.aspects.graphics`)       |
| `modules/graphics-asahi.nix`     | Asahi GPU driver, Hyprland (`den.aspects.graphics-asahi`)         |
| `modules/desktop/hyprland.nix`   | Hyprland user configuration (home aspect)                         |
