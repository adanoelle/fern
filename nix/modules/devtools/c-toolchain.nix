{ pkgs, lib, ... }:

let
  # Common hardening flags shared by C/C++ builds
  safeFlags = [
    "-fstack-protector-strong"
    "-Wl,-z,relro,-z,now"
  ];
in
{
  # --- Core GCC + Clang tool‑chain                                     
  environment.systemPackages = with pkgs; [
    gcc                          # provides `cc`, `g++`, linker
    binutils
    clang                        # modern alternative compiler
    clang-tools                  # clangd, clang‑tidy, clang‑format  :contentReference[oaicite:0]{index=0}
    lld                          # LLVM linker
    cmake ninja                  # CMake + fast build driver  :contentReference[oaicite:1]{index=1}
    pkg-config
  ];

  #######################################################################
  ##  Global compilation flags (opt‑in)                                ##
  #######################################################################
  environment.variables = {
    # Most build systems respect these
    CFLAGS  = lib.concatStringsSep " " safeFlags;
    CXXFLAGS = lib.concatStringsSep " " safeFlags;
  };
}

