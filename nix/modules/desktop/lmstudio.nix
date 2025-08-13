# nix/modules/desktop/lmstudio.nix
{ lib, pkgs, ... }:

let
  version = "0.3.23-3";
  src = pkgs.fetchurl {
    url = "https://installers.lmstudio.ai/linux/x64/${version}/LM-Studio-${version}-x64.AppImage";
    sha256 = "1slfd8plsw8jqvm95w54a50m6fm3jd14x8w9bkcf73ll7v6c4v8l";
  };

  lmstudio = pkgs.appimageTools.wrapType2 {
    pname = "lmstudio";
    inherit version src;

    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      cat > "$out/share/applications/lmstudio-appimage.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=LM Studio (AppImage)
      TryExec=$out/bin/lmstudio
      Exec=$out/bin/lmstudio %U
      Terminal=false
      Categories=Development;Utility;
      Icon=lmstudio
      EOF

      # Best-effort icon from inside the AppImage
      icon="$(find "$appimageContents" -type f -iname '*lm*studio*.png' -o -iname 'icon*.png' | sort -V | tail -n1 || true)"
      if [ -n "$icon" ]; then
        install -Dm444 "$icon" "$out/share/icons/hicolor/512x512/apps/lmstudio.png"
      fi
    '';

    meta = with lib; {
      description = "LM Studio (AppImage) wrapped";
      homepage    = "https://lmstudio.ai";
      license     = licenses.unfree;
      mainProgram = "lmstudio";
      platforms   = platforms.linux;
    };
  };
in
{
  environment.systemPackages = [ lmstudio ];

  hardware.graphics = { enable = true; enable32Bit = true; };
  networking.firewall.allowedTCPPorts = [ 1234 ];
}

