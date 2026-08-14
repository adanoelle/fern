_: {
  den.aspects.teams = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ teams-for-linux ];
      };

    homeManager =
      { pkgs, config, ... }:
      let
        # On non-NixOS the Electron SUID sandbox binary in the Nix store
        # can't be setuid root. Disable it so Electron falls back to the
        # kernel namespace sandbox. teams-for-linux doesn't expose
        # commandLineArgs, so use symlinkJoin to inject the flag.
        teams =
          if config.targets.genericLinux.enable then
            pkgs.symlinkJoin {
              name = "teams-for-linux-nosandbox";
              paths = [ pkgs.teams-for-linux ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/teams-for-linux --add-flags "--no-sandbox"
              '';
            }
          else
            pkgs.teams-for-linux;
      in
      {
        home.packages = [ (config.lib.nixGL.wrap teams) ];
      };
  };
}
