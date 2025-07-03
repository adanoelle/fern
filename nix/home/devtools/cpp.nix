{ pkgs, ... }:

{
  # --- User‑level C / C++ developer tools
  home.packages = with pkgs; [
    # --- Debug & profiling
    gdb                   # GNU debugger
    lldb                  # LLVM debugger (great for Clang builds)
    valgrind              # memory / thread race checker
    rr                    # time‑travel debugger (record & replay)

    # --- Build helpers
    bear                  # emits compile_commands.json for clangd
    ccache                # compiler cache for faster rebuilds
    cmake-format          # auto‑formatter for CMakeLists.txt
    pkg-config            # dependency discovery in autotools/CMake

    # --- Static analysis & lint
    clang-tools           # clangd, clang‑tidy, clang‑format, include‑what‑you‑use
    cppcheck              # lightweight analyser
    include-what-you-use  # header optimiser

    # --- Generators & project helpers
    cmake
    ninja                # generator + fast build backend
    meson
    doxygen
    graphviz             # API docs generation

    # --- Modern CLI productivity
    ripgrep
    fd
  ];

  # --- Editor / LSP integration (Helix example)
  programs.helix = {
    enable = true;

    languages = {
      # 1. language-server table (key = server‑id)
      language-server.clangd = {
        command = "clangd";
        args    = [ "--background-index" "--clang-tidy" ];
      };

      # 2. language array
      language = [
        {
          name             = "cpp";
          language-servers = [ "clangd" ];
          roots            = [ "compile_commands.json" ];
          formatter        = { command = "clang-format"; };
        }
      ];
    };
  };

  # --- Optional direnv + nix‑direnv for auto devShells          
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

