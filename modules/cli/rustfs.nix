# modules/cli/rustfs.nix — rc, an S3 client for the research group's object stores
#
# rustfs/cli's `rc`, for listing and copying objects in S3-compatible
# stores, such as the group's data repository. It isn't in nixpkgs, so
# this fetches the upstream release: a static binary, pinned to the hash
# in the release's SHA256SUMS, and its shell completions.
#
# Which stores to reach, and their keys, are NOT here: this repository
# is public, so each store is set up by hand on the machine that needs
# it (see book/src/operations/work-laptop.md), and rc keeps it in
# ~/.config/rc/config.toml:
#
#   rc alias set NAME URL ACCESS_KEY SECRET_KEY   once per store
#   rc ls NAME/BUCKET                             what a bucket holds
#   rc cp NAME/BUCKET/KEY .                       copy an object here
#
# An alias may not start with a digit. nixpkgs' `rc` is the Plan 9
# shell, an unrelated program with the same name; don't install both.
_: {
  den.aspects.rustfs.homeManager =
    { lib, pkgs, ... }:
    let
      version = "0.1.37";
      release = "https://github.com/rustfs/cli/releases/download/v${version}";
      rc = pkgs.stdenvNoCC.mkDerivation {
        pname = "rustfs-cli";
        inherit version;
        src = pkgs.fetchurl {
          url = "${release}/rustfs-cli-linux-amd64-v${version}.tar.gz";
          hash = "sha256-Meef52l8hw5g9bXJAIrbs61a9/nyq0Wj1oWFxfhyONE=";
        };
        completions = pkgs.fetchurl {
          url = "${release}/completions.tar.gz";
          hash = "sha256-IqrYxkZWkCYRi4s+7/XYSUHKJACef2M0IxJ2REaF2BU=";
        };
        # The archive holds the binary and its licences, with no top directory.
        sourceRoot = ".";
        nativeBuildInputs = [ pkgs.installShellFiles ];
        # Static and already stripped: nothing for the fixup to do.
        dontPatchELF = true;
        dontStrip = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 rc "$out/bin/rc"
          tar xzf "$completions"
          installShellCompletion --cmd rc \
            --bash completions/rc.bash \
            --fish completions/rc.fish \
            --zsh completions/_rc
          runHook postInstall
        '';
        meta = {
          description = "S3-compatible command-line client (rustfs/cli)";
          homepage = "https://github.com/rustfs/cli";
          license = with lib.licenses; [
            asl20
            mit
          ];
          mainProgram = "rc";
          platforms = [ "x86_64-linux" ];
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        };
      };
    in
    {
      home.packages = [ rc ];
    };
}
