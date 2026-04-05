# modules/workspace.nix — XDG user directories
{ den, ... }:
{
  den.aspects.workspace.homeManager = { lib, ... }: {
    xdg = {
      enable = true;
      userDirs.createDirectories = false;
      userDirs.extraConfig = {
        XDG_DESKTOP_DIR = "$HOME";
        XDG_DOWNLOAD_DIR = "$HOME/ada/media/downloads";
        XDG_PICTURES_DIR = "$HOME/ada/media/pictures";
        XDG_VIDEOS_DIR = "$HOME/ada/media/obs";
      };
    };

    home.activation.createObsDir =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/ada/media/obs"
      '';
  };
}
