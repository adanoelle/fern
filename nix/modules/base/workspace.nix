# nix/modules/workspace.nix
# Keeps $HOME intact but prevents xdg-user-dirs from recreating
# Downloads/, Pictures/, etc. and points the ones you still want
# into ~/ada/…
{ lib, ... }:

{
  xdg = {
    enable = true;

    # Don’t let the helper create *anything* automatically
    userDirs.createDirectories = false;

    # Re-map or disable selected dirs
    userDirs.extraConfig = {
      # Anything you *don’t* want: aim back at $HOME (spec disables it)
      XDG_DESKTOP_DIR  = "$HOME";

      # Anything you still want: move into your clean tree
      XDG_DOWNLOAD_DIR = "$HOME/ada/media/downloads";
      XDG_PICTURES_DIR = "$HOME/ada/media/pictures";
      XDG_VIDEOS_DIR   = "$HOME/ada/media/videos";
      # Add more if needed, e.g. MUSIC, PUBLICSHARE, DOCUMENTS…
    };
  };
}
