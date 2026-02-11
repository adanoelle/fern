# Stack Overview

The gamedev module (`nix/home/devtools/gamedev.nix`) provides a complete C++ game development environment. All packages are installed via `home.packages` and available globally — no per-project shell needed for the core toolchain.

## Core Libraries (`gameLibs`)

These libraries are added to both `CMAKE_PREFIX_PATH` and `PKG_CONFIG_PATH` so CMake and pkg-config find them automatically.

| Category | Package | Description |
|---|---|---|
| **ECS** | `entt` | Header-only entity-component-system library |
| **Windowing / Rendering** | `SDL2`, `SDL2.dev` | Cross-platform windowing, input, and rendering |
| **Rendering / Media** | `SDL2_image` | Image loading (PNG, JPG, etc.) |
| **Audio** | `SDL2_mixer`, `SDL2_mixer.dev` | Multi-channel audio mixing |
| **Text** | `SDL2_ttf` | TrueType font rendering |
| **Math** | `glm` | OpenGL Mathematics (header-only) |
| **Debug UI** | `imgui` | Immediate-mode GUI for debug interfaces |
| **Profiling** | `tracy` | Frame profiler with C++ instrumentation macros |
| **Serialization** | `nlohmann_json` | JSON for Modern C++ (header-only) |
| **Formatting** | `fmt`, `fmt.dev` | Fast, safe formatting library |
| **Logging** | `spdlog`, `spdlog.dev` | Fast logging (uses fmt internally) |
| **Physics** | `box2d` | 2D physics engine (v3 API) |
| **Scripting** | `lua5_4`, `sol2` | Lua 5.4 runtime + C++ binding library |
| **Testing** | `catch2_3` | C++ test framework (v3) |
| **Utilities** | `stb` | Single-file public domain libraries (image, truetype, etc.) |

## Additional Tools

| Category | Package | Notes |
|---|---|---|
| **Level Editors** | `tiled` | Tile map editor (TMX format) |
| | `ldtk` | Modern 2D level editor (JSON-based) |
| **Sprite Editor** | `aseprite` | Pixel art and animation |

## Profiling & Debugging Tools

| Package | Purpose |
|---|---|
| `heaptrack` | Heap allocation profiler (KDE) |
| `renderdoc` | GPU frame debugger (requires `SDL_VIDEODRIVER=x11` on Wayland) |
| `valgrind` | Memory correctness checker |
| `linuxPackages.perf` | Kernel sampling profiler |
| `flamegraph` | Flame graph visualization scripts |

See the [Profiling Tools](profiling.md) and [GPU Debugging](gpu-debugging.md) chapters for usage details.

## Related: Gaming Module

The system-level gaming module (`nix/modules/gaming.nix`) provides:

- **MangoHud** — FPS/frametime overlay (bundled with Steam)
- **GameScope** — Valve's micro-compositor for Wayland gaming
- **GameMode** — Feral Interactive CPU/GPU optimizer

MangoHud is particularly useful for gamedev — see [GPU Debugging](gpu-debugging.md).

## Environment Variables

The module sets two environment variables so build systems find all `gameLibs` packages:

```bash
CMAKE_PREFIX_PATH=<all gameLibs package paths, colon-separated>
PKG_CONFIG_PATH=<all gameLibs package paths>/lib/pkgconfig
```

This means a typical CMake project just works:

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## Typical Project Workflow

1. Create a project directory and `CMakeLists.txt`
2. `find_package()` or `pkg_check_modules()` will find libraries automatically via the session variables
3. Use Tracy macros (`ZoneScoped`, `FrameMark`) from the start — the overhead when not connected is negligible
4. Use ImGui for debug UI (entity inspectors, physics debug draw, etc.)
5. Profile with `tracy` connected, then reach for `heaptrack`, `perf`, or `renderdoc` as needed
