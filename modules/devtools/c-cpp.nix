_: {
  den.aspects.c-cpp = {
    nixos =
      { lib, pkgs, ... }:
      let
        safeFlags = [
          "-fstack-protector-strong"
          "-Wl,-z,relro,-z,now"
        ];
      in
      {
        environment.systemPackages = with pkgs; [
          gcc
          binutils
          clang
          clang-tools
          lld
          cmake
          ninja
          pkg-config
        ];

        environment.variables = {
          CFLAGS = lib.concatStringsSep " " safeFlags;
          CXXFLAGS = lib.concatStringsSep " " safeFlags;
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          gdb
          lldb
          valgrind
          rr
          bear
          ccache
          cmake-format
          pkg-config
          clang-tools
          cppcheck
          include-what-you-use
          cmake
          ninja
          meson
          doxygen
          graphviz
          ripgrep
          fd
        ];

        programs.helix = {
          enable = true;
          languages = {
            language-server.clangd = {
              command = "clangd";
              args = [
                "--background-index"
                "--clang-tidy"
              ];
            };
            language = [
              {
                name = "cpp";
                language-servers = [ "clangd" ];
                roots = [ "compile_commands.json" ];
                formatter = {
                  command = "clang-format";
                };
              }
            ];
          };
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config.global.hide_env_diff = true;
        };
      };
  };
}
