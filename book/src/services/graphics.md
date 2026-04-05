# Graphics & GPU

> GPU configuration with Mesa/AMDGPU for fern (inline in the host aspect) and a
> separate Asahi driver aspect for Apple Silicon on moss.

## AMD configuration (fern)

Fern's GPU setup is defined inline in the host aspect (`modules/host-fern.nix`)
rather than a separate graphics aspect. Mesa's AMDGPU driver requires no
proprietary packages — a single line enables it:

```nix
hardware.graphics.enable = true;
```

This gives fern:

| Setting      | Value             |
| ------------ | ----------------- |
| Video driver | Mesa (AMDGPU)     |
| Vulkan       | RADV via Mesa     |
| OpenGL       | Mesa's RadeonSI   |

### GPU tools

Fern installs diagnostic tools alongside the driver:

| Package        | Purpose                                     |
| -------------- | ------------------------------------------- |
| `mesa-demos`   | `glxinfo`, `eglinfo` for testing GL support |
| `vulkan-tools` | `vulkaninfo` for testing Vulkan support     |

## Asahi configuration (moss)

The `den.aspects.graphics-asahi` aspect (`modules/asahi/graphics.nix`) uses the
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

Both hosts enable `programs.hyprland.enable = true`, which installs the Hyprland
compositor and sets up the Wayland session. The actual Hyprland configuration
(keybindings, layout, animations) is handled by the Home Manager aspect in
`modules/desktop/hyprland.nix`.

## Key files

| File                               | Purpose                                           |
| ---------------------------------- | ------------------------------------------------- |
| `modules/host-fern.nix`           | AMD GPU setup (inline), Hyprland enable            |
| `modules/asahi/graphics.nix`      | Asahi GPU driver, Hyprland (`den.aspects.graphics-asahi`) |
| `modules/desktop/hyprland.nix`    | Hyprland user configuration (home aspect)          |
