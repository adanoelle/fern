{ pkgs, lib, ... }:

let
  gameLibs = with pkgs; [
    # --- ECS
    entt

    # --- Windowing / Rendering / Audio
    SDL2
    SDL2.dev
    SDL2_image
    SDL2_mixer
    SDL2_mixer.dev
    SDL2_ttf

    # --- Math
    glm

    # --- Debug UI
    imgui

    # --- Profiling
    tracy

    # --- Serialization
    nlohmann_json

    # --- Formatting / Logging
    fmt
    fmt.dev
    spdlog
    spdlog.dev

    # --- 2D Physics (v3 API)
    box2d

    # --- Scripting
    lua5_4
    sol2

    # --- Testing
    catch2_3

    # --- Utilities
    stb
  ];

  cmakePrefixPath = lib.concatMapStringsSep ":" (p: "${p}") gameLibs;
  pkgConfigPath = lib.concatMapStringsSep ":" (p: "${p}/lib/pkgconfig") gameLibs;
in
{
  home.packages = gameLibs ++ (with pkgs; [
    # --- Level editors
    tiled
    ldtk

    # --- Sprite editor
    aseprite

    # --- Profiling & debugging
    heaptrack # Heap allocation profiler (KDE)
    renderdoc # GPU frame debugger (force XWayland: SDL_VIDEODRIVER=x11)
    valgrind # Memory correctness checker
    linuxPackages.perf # Kernel sampling profiler
    flamegraph # Flame graph visualization scripts
  ]);

  home.sessionVariables = {
    CMAKE_PREFIX_PATH = cmakePrefixPath;
    PKG_CONFIG_PATH = pkgConfigPath;
  };
}
