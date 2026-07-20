# modules/workspace.nix — archivist home taxonomy (see ~/docs/FILING.md)
#
# One capture point (~/inbox), filed by kind (docs/notes/media/src),
# cold storage by year (~/archive). Desktop/Public/Templates are
# disabled per the xdg-user-dirs spec by pointing them at $HOME.
_: {
  den.aspects.workspace.homeManager =
    { config, lib, ... }:
    let
      home = config.home.homeDirectory;
    in
    {
      xdg.enable = true;
      xdg.userDirs = {
        enable = true; # was false — the old block was inert
        createDirectories = true;
        download = "${home}/inbox";
        documents = "${home}/docs";
        pictures = "${home}/media/pictures";
        videos = "${home}/media/video";
        music = "${home}/media/music";
        # "disabled" idiom: a user dir equal to $HOME is off per spec
        desktop = home;
        publicShare = home;
        templates = home;
      };

      # Non-XDG taxonomy dirs — same mkdir idiom HM's createDirectories uses.
      # (No .keep files: inbox must be able to LOOK empty.)
      home.activation.archivistTree = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p $VERBOSE_ARG \
          "${home}/docs/career" \
          "${home}/notes" \
          "${home}/archive" \
          "${home}/media/screenshots" \
          "${home}/media/wallpapers"
      '';

      home.file."docs/FILING.md".source = ./_workspace/FILING.md;
    };
}
