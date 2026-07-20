_: {
  den.aspects.gamedev.homeManager =
    { lib, pkgs, ... }:
    let
      gameLibs = with pkgs; [
        entt
        SDL2
        SDL2.dev
        SDL2_image
        SDL2_mixer
        SDL2_mixer.dev
        SDL2_ttf
        glm
        imgui
        tracy
        nlohmann_json
        fmt
        fmt.dev
        spdlog
        spdlog.dev
        box2d
        lua5_4
        sol2
        catch2_3
        stb
      ];

      cmakePrefixPath = lib.concatMapStringsSep ":" (p: "${p}") gameLibs;
      pkgConfigPath = lib.concatMapStringsSep ":" (p: "${p}/lib/pkgconfig") gameLibs;
    in
    {
      home.packages =
        gameLibs
        ++ (with pkgs; [
          tiled
          ldtk
          aseprite
          heaptrack
          renderdoc
          valgrind
          perf
          flamegraph
        ]);

      home.sessionVariables = {
        CMAKE_PREFIX_PATH = cmakePrefixPath;
        PKG_CONFIG_PATH = pkgConfigPath;
      };
    };
}
