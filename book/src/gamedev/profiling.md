# Profiling Tools

This chapter covers the CPU and memory profiling tools available in the Fern gamedev stack. For GPU-specific tooling, see [GPU Debugging](gpu-debugging.md).

## Tracy

Tracy is a frame profiler designed for games and real-time applications. It instruments your code with C++ macros and streams data to a separate viewer.

### Instrumentation

```cpp
#include <tracy/Tracy.hpp>

void game_loop() {
    FrameMark;                          // marks frame boundary

    {
        ZoneScopedN("update");          // named zone
        update(dt);
    }
    {
        ZoneScopedN("render");
        render();
    }
}
```

### Feature Overview

| Feature | Macro / API | What It Shows |
|---|---|---|
| **CPU zones** | `ZoneScoped`, `ZoneScopedN("name")` | Hierarchical function timing on timeline |
| **GPU zones** | `TracyGpuZone("name")` | GPU command timing (OpenGL / Vulkan) |
| **Frame marks** | `FrameMark` | Frame boundaries and frame time graph |
| **Memory tracking** | `TracyAlloc(ptr, size)` / `TracyFree(ptr)` | Allocation timeline, leak detection |
| **Lock contention** | `TracyLockable(std::mutex, name)` | Mutex wait time, contention hotspots |
| **Lua profiling** | `tracy.ZoneBeginN("name")` / `tracy.ZoneEnd()` | Lua script zones on same timeline |
| **Plots** | `TracyPlot("name", value)` | Custom value graphs (entity count, memory, etc.) |
| **Messages** | `TracyMessage(text, len)` | Text annotations on the timeline |
| **Frame screenshots** | `TracyEmitFrameImage(ptr, w, h, offset, flip)` | Thumbnail per frame in the viewer |

### Connecting

1. Start your game (instrumented with Tracy macros)
2. Launch the Tracy profiler GUI: `tracy`
3. Click **Connect** — it auto-discovers the local process

### Build Integration

With CMake, link against Tracy:

```cmake
find_package(Tracy REQUIRED)
target_link_libraries(my_game PRIVATE Tracy::TracyClient)
```

Add `-DTRACY_ENABLE` to your debug build's compile definitions. When `TRACY_ENABLE` is not defined, all macros compile to nothing.

## heaptrack

heaptrack profiles heap allocations over time — where they happen, how large they are, and when they leak.

### Basic Usage

```bash
# Profile from launch
heaptrack ./my_game

# Attach to a running process
heaptrack --pid $(pidof my_game)

# Open the GUI to analyze
heaptrack_gui heaptrack.my_game.*.zst
```

### What to Look For

- **Allocation hotspots** — functions that allocate most frequently (per-frame `new`/`malloc` in hot paths)
- **Temporary allocations** — short-lived allocations that could use stack or pool allocation instead
- **Leak candidates** — allocations that grow monotonically without corresponding frees
- **Peak memory** — the high-water mark and what caused it

### Tips

- Run for a representative session (load a level, play for a bit, exit)
- Compare before/after: heaptrack's diff mode can compare two profiles
- Focus on per-frame allocations first — these have the most impact on frame time consistency

## perf + flamegraph

`perf` is a kernel-level sampling profiler. Combined with `flamegraph`, it produces visual call-stack breakdowns.

### Basic Pipeline

```bash
# Record 10 seconds of profiling data
perf record -g --call-graph dwarf -p $(pidof my_game) -- sleep 10

# Generate a flame graph
perf script | c++filt | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

Open `flame.svg` in a browser — wider bars mean more CPU time.

### Differential Flame Graphs

Compare two profiles to see what changed:

```bash
# Record baseline
perf record -g --call-graph dwarf -o perf-before.data ./my_game_v1

# Record after optimization
perf record -g --call-graph dwarf -o perf-after.data ./my_game_v2

# Diff
perf script -i perf-before.data | c++filt | stackcollapse-perf.pl > before.folded
perf script -i perf-after.data  | c++filt | stackcollapse-perf.pl > after.folded
difffolded.pl before.folded after.folded | flamegraph.pl > diff.svg
```

Red = regression, blue = improvement.

### NixOS Note: `perf_event_paranoid`

By default, `perf` may require elevated permissions. If you get permission errors:

```bash
# Check current setting
cat /proc/sys/kernel/perf_event_paranoid

# Temporarily allow user profiling (resets on reboot)
sudo sysctl kernel.perf_event_paranoid=1
```

To make it permanent, add to your NixOS configuration:

```nix
boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
```

## Valgrind

Valgrind's memcheck tool detects memory errors at runtime: leaks, use-after-free, uninitialized reads, and buffer overflows.

### Basic Usage

```bash
# Full leak check
valgrind --leak-check=full --show-leak-kinds=all ./my_game

# Track origins of uninitialized values
valgrind --track-origins=yes ./my_game
```

### Build Flags

Valgrind works best with debug info but is usable with optimizations:

```bash
# Recommended: optimized + debug info
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
# or manually:
-O2 -g
```

Avoid `-O3` with Valgrind — aggressive inlining makes stack traces harder to read.

### Suppression Files

SDL, GPU drivers, and system libraries often produce false positives. Create a suppression file:

```
# sdl.supp
{
   SDL_Init_leak
   Memcheck:Leak
   ...
   fun:SDL_Init
}
```

Use it:

```bash
valgrind --suppressions=sdl.supp --leak-check=full ./my_game
```

### What to Look For

| Error | Meaning | Severity |
|---|---|---|
| **Invalid read/write** | Use-after-free or buffer overflow | Critical |
| **Conditional jump on uninitialised value** | Reading uninitialized memory | High |
| **Definitely lost** | Memory leak (no pointer to block exists) | High |
| **Indirectly lost** | Leaked via a definitely-lost block | Medium |
| **Possibly lost** | Ambiguous — interior pointer exists | Investigate |
| **Still reachable** | Not freed at exit but pointer exists | Usually fine |

### Performance Impact

Valgrind runs your program in a virtual CPU — expect 10-50x slowdown. For game testing, reduce resolution and disable heavy rendering to keep things interactive enough.
