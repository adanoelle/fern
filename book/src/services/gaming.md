# Gaming (Steam & Gamescope)

> Steam with Gamescope micro-compositor, GameMode CPU/GPU optimization, and
> controller support for Xbox, PlayStation, and Nintendo controllers.

The gaming configuration spans a system module (`nix/modules/gaming.nix`) for
Steam, Gamescope, and hardware support, and a home module
(`nix/home/desktop/gaming.nix`) for user-facing gaming utilities.

## System module

### Steam

Steam is enabled with:

- Remote Play firewall ports open
- Dedicated server ports closed
- Gamescope session support
- MangoHud and Gamescope as extra packages

### Gamescope

Gamescope is Valve's micro-compositor that provides:

- Frame limiting and upscaling
- HDR support
- Per-game display settings
- `capSysNice = true` for real-time scheduling priority

### GameMode

GameMode temporarily applies CPU and GPU optimizations while games are running:

```nix
programs.gamemode = {
  enable = true;
  settings = {
    general.renice = 10;
    gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
    };
  };
};
```

### Controller support

Kernel modules loaded for controller input:

| Module            | Controllers           |
| ----------------- | --------------------- |
| `xpad`            | Xbox controllers      |
| `hid_playstation` | DualShock / DualSense |
| `hid_nintendo`    | Switch Pro / Joy-Con  |

The `joycond` service is enabled for Nintendo controller pairing and management.
`steam-hardware` udev rules are enabled for broad controller compatibility.

## Home module

The home module (`nix/home/desktop/gaming.nix`) adds user-facing tools:

| Package        | Purpose                         |
| -------------- | ------------------------------- |
| `mangohud`     | FPS/frametime/GPU overlay       |
| `protonup-qt`  | Proton version manager (GUI)    |
| `lutris`       | Game launcher (GOG, Epic, etc.) |
| `protontricks` | Winetricks for Proton prefixes  |

## Key files

| File                          | Purpose                                  |
| ----------------------------- | ---------------------------------------- |
| `nix/modules/gaming.nix`      | Steam, Gamescope, GameMode, controllers  |
| `nix/home/desktop/gaming.nix` | MangoHud, Lutris, ProtonUp, Protontricks |
