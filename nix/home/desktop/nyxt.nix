# nix/home/desktop/nyxt.nix
#
# Nyxt browser - keyboard-driven, extensible browser
{ pkgs, ... }:

let
  # Wrap nyxt with environment variables for NVIDIA + Wayland compatibility
  nyxt-wrapped = pkgs.symlinkJoin {
    name = "nyxt-wrapped";
    paths = [ pkgs.nyxt ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nyxt \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set __GL_THREADED_OPTIMIZATIONS 0
    '';
  };
in
{
  home.packages = [ nyxt-wrapped ];

  # Set Nyxt as default browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"              = [ "nyxt.desktop" ];
      "x-scheme-handler/http"  = [ "nyxt.desktop" ];
      "x-scheme-handler/https" = [ "nyxt.desktop" ];
    };
  };

  # Nyxt configuration - remap Ctrl to Super
  xdg.configFile."nyxt/config.lisp".text = ''
    (in-package #:nyxt-user)

    ;; Remap control to super for all keybindings
    (define-configuration input-buffer
      ((override-map
        (let ((map (make-keymap "override-map")))
          ;; Navigation
          (define-key map "super-l" 'set-url)
          (define-key map "super-b" 'set-url-from-bookmark)
          (define-key map "super-d" 'bookmark-current-url)
          (define-key map "super-t" 'make-buffer)
          (define-key map "super-w" 'delete-current-buffer)
          (define-key map "super-r" 'reload-current-buffer)
          (define-key map "super-space" 'execute-command)
          (define-key map "super-tab" 'switch-buffer-next)
          (define-key map "super-shift-tab" 'switch-buffer-previous)
          ;; History
          (define-key map "super-[" 'history-backwards)
          (define-key map "super-]" 'history-forwards)
          ;; Clipboard
          (define-key map "super-c" 'copy)
          (define-key map "super-v" 'paste)
          (define-key map "super-x" 'cut)
          ;; Search
          (define-key map "super-f" 'search-buffer)
          (define-key map "super-g" 'search-buffers)
          map))))
  '';
}
