# GPU Debugging

This chapter covers tools for debugging GPU rendering and monitoring graphics
performance.

## RenderDoc

RenderDoc captures a frame of GPU API calls and lets you inspect every draw
call, texture, shader, and pipeline state.

### Wayland Caveat

RenderDoc's capture injection does not support Wayland natively. Force XWayland
for your game:

```bash
SDL_VIDEODRIVER=x11 renderdoc
```

Or launch your game directly under RenderDoc with the environment variable set.

### Capture Workflow

1. Launch RenderDoc
2. Set the executable path to your game binary
3. Add `SDL_VIDEODRIVER=x11` to the environment variables panel
4. Click **Launch**
5. In the game, press **F12** (default) or **Print Screen** to capture a frame
6. Back in RenderDoc, double-click the captured frame to inspect

### What You Can Inspect

| Panel               | Shows                                               |
| ------------------- | --------------------------------------------------- |
| **Event Browser**   | Every API call in the frame, hierarchically grouped |
| **Texture Viewer**  | Any texture/render target at any point in the frame |
| **Pipeline State**  | Bound shaders, blend state, depth/stencil, viewport |
| **Mesh Viewer**     | Vertex data pre- and post-transform                 |
| **Shader Debugger** | Step through shader execution per-pixel             |

### Programmatic Capture API

For automated or conditional captures (e.g., capture on a specific frame or when
a bug triggers):

```cpp
#include <renderdoc_app.h>

RENDERDOC_API_1_1_2* rdoc = nullptr;

void init_renderdoc() {
    if (void* mod = dlopen("librenderdoc.so", RTLD_NOW | RTLD_NOLOAD)) {
        auto get_api = (pRENDERDOC_GetAPI)dlsym(mod, "RENDERDOC_GetAPI");
        get_api(eRENDERDOC_API_Version_1_1_2, (void**)&rdoc);
    }
}

void capture_frame() {
    if (rdoc) {
        rdoc->TriggerCapture();
    }
}
```

### Tips

- Name your OpenGL/Vulkan objects (`glObjectLabel`, `vkSetDebugUtilsObjectName`)
  — they show up in RenderDoc's event browser
- Use RenderDoc's **Overlay** to see draw call counts and triangle counts in
  real-time before capturing
- Compare two captures side-by-side to debug rendering regressions

## MangoHud

MangoHud is an FPS/frametime overlay for Vulkan and OpenGL applications. It's
installed system-wide via the gaming module (`nix/modules/gaming.nix`) as part
of Steam's extra packages, but works with any game.

### Usage

```bash
# Run any game with the overlay
mangohud ./my_game

# With Steam (set per-game launch options)
mangohud %command%
```

### What It Shows (Default)

- FPS counter
- Frame time graph
- CPU/GPU utilization and temperature
- VRAM usage

### Configuration

MangoHud reads `~/.config/MangoHud/MangoHud.conf`. Useful settings:

```ini
# Show frame time graph
frame_timing=1

# Show 1% and 0.1% lows
fps_metrics=avg,0.1,1

# Log to CSV for later analysis
output_folder=/tmp/mangohud
log_duration=60

# Compact display
no_display
log_interval=100
```

### Frametime Graph Interpretation

| Pattern                            | Likely Cause                                         |
| ---------------------------------- | ---------------------------------------------------- |
| Flat line at target (e.g., 16.6ms) | Good — hitting vsync                                 |
| Regular spikes                     | Periodic hitch (GC, asset loading, physics step)     |
| Gradual increase over time         | Memory pressure or resource leak                     |
| Random jitter                      | CPU contention, thermal throttling, or driver stalls |

### Logging for Analysis

```bash
# Record frametime data to CSV
mangohud --dlsym ./my_game
# Press F2 to start/stop logging
# Logs appear in output_folder
```

The CSV files can be opened in any spreadsheet tool or plotted with a script for
detailed analysis.

### Comparison with Tracy

MangoHud and Tracy serve different purposes:

|                 | MangoHud                                 | Tracy                          |
| --------------- | ---------------------------------------- | ------------------------------ |
| **Granularity** | Whole-frame metrics                      | Per-function, per-zone         |
| **Overhead**    | Negligible                               | Low (but measurable)           |
| **Setup**       | Zero (just prefix command)               | Requires code instrumentation  |
| **Best for**    | Quick health check, frametime monitoring | Deep performance investigation |

Typical workflow: use MangoHud to spot problems, then use Tracy to diagnose
them.
