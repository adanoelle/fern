# Tool Decision Matrix

Quick reference for choosing the right tool based on what you're investigating.

## Symptom to Tool

| Symptom | Tool | Why |
|---|---|---|
| Low FPS / general slowness | **MangoHud** | Quick frametime check with zero setup |
| Specific function is slow | **Tracy** | Per-zone CPU timing with call hierarchy |
| Frame time spikes | **Tracy** | Timeline view shows exactly which zone spiked |
| High memory usage | **heaptrack** | Tracks every allocation with call stack |
| Memory leak | **heaptrack** or **Valgrind** | heaptrack for allocation patterns, Valgrind for precision |
| Use-after-free / corruption | **Valgrind** | Memcheck catches invalid reads/writes |
| Uninitialized memory | **Valgrind** | `--track-origins=yes` traces the source |
| CPU hotspot identification | **perf + flamegraph** | Statistical sampling across entire call stack |
| Rendering artifact | **RenderDoc** | Inspect draw call state, textures, shaders |
| Wrong draw order / overdraw | **RenderDoc** | Step through draw calls, view render targets |
| Shader bug | **RenderDoc** | Per-pixel shader debugger |
| GPU performance | **MangoHud** | GPU utilization, temperature, VRAM |
| Physics collision issues | **Box2D debug draw** | Visual overlay of physics world |
| Entity state inspection | **ImGui + EnTT editor** | Runtime component viewer |
| Lua script performance | **Tracy** | Lua zones on same timeline as C++ |
| Lock contention | **Tracy** | `TracyLockable` shows mutex wait time |

## Recommended Workflow

Start broad, then narrow down:

1. **MangoHud** — Is there actually a problem? What does the frametime look like?
2. **Tracy** — Where in the frame is time being spent? Which system or zone?
3. **Specialized tool** — Based on what Tracy reveals:
   - CPU-bound in a specific function → **perf + flamegraph** for deeper stack analysis
   - Allocation-heavy → **heaptrack** for allocation profiling
   - Memory corruption → **Valgrind** for precise error detection
   - GPU-bound or visual bug → **RenderDoc** for frame capture

## Complementary Pairs

| Pair | When to Use Together |
|---|---|
| **Tracy + MangoHud** | Tracy for code-level detail, MangoHud for overall frame health |
| **Tracy + heaptrack** | Tracy finds the slow zone, heaptrack reveals it's allocation-heavy |
| **perf + Tracy** | perf for system-wide sampling, Tracy for targeted zones |
| **Valgrind + heaptrack** | Valgrind for correctness, heaptrack for allocation patterns |
| **RenderDoc + MangoHud** | MangoHud confirms GPU-bound, RenderDoc shows why |

## NixOS-Specific Tips

- All tools are installed globally via `home.packages` — no need for `nix-shell` or per-project setup
- `renderdoc` needs `SDL_VIDEODRIVER=x11` on Wayland (Hyprland)
- `perf` may need `kernel.perf_event_paranoid` sysctl adjustment (see [Profiling Tools](profiling.md))
- MangoHud is available both as a Steam extra package and usable standalone with any binary
- Tracy's viewer GUI is the same `tracy` package — just run `tracy` to open it
- `flamegraph` provides the `stackcollapse-perf.pl` and `flamegraph.pl` scripts on `PATH`
