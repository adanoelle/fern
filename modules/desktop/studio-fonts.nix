# modules/desktop/studio-fonts.nix — a serif and a handwriting face
#
# Two faces for the art machine, on top of the shared set in
# modules/fonts.nix: Cormorant, a light high-contrast serif, which
# becomes the default serif, and Reenie Beanie, a thin scratchy pen
# hand for lettering. Opt-in per host; system side only.
_: {
  den.aspects.studio-fonts.nixos =
    { lib, pkgs, ... }:
    let
      # Not packaged on its own in nixpkgs (only inside the 1 GiB
      # google-fonts source), so the one file is fetched from a pinned
      # commit of google/fonts. SIL Open Font License.
      reenie-beanie = pkgs.stdenvNoCC.mkDerivation {
        pname = "reenie-beanie";
        version = "0-unstable-2026-11-20";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/google/fonts/8ccda7bf739842777d42661d1b384b926194e24b/ofl/reeniebeanie/ReenieBeanie.ttf";
          hash = "sha256-DqYIqjJb+eEclZDMC2Pc980hXicHhPHrvm+tSSezH/g=";
        };
        dontUnpack = true;
        installPhase = ''
          install -Dm444 $src $out/share/fonts/truetype/ReenieBeanie.ttf
        '';
        meta.license = lib.licenses.ofl;
      };
    in
    {
      fonts = {
        packages = [
          pkgs.cormorant
          reenie-beanie
        ];
        # Ahead of the shared set's serif list.
        fontconfig.defaultFonts.serif = lib.mkBefore [ "Cormorant" ];
      };
    };
}
