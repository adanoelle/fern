# modules/foreign/repd-chrome.nix — Google Chrome for the REPD enclave
#
# The enclave admins want the REPD portal opened in Chrome. Chrome
# itself is deliberately NOT from Nix: Ubuntu 24.04 restricts
# unprivileged user namespaces (apparmor_restrict_unprivileged_userns=1),
# so a Chromium-family browser only gets its sandbox with a root-owned
# SUID helper or an AppArmor profile granting `userns`. Google's .deb
# ships the SUID helper and Ubuntu ships /etc/apparmor.d/chrome for
# /opt/google/chrome/chrome; a Nix-store Chrome would have neither and
# would have to run --no-sandbox — fine for Teams, not for an enclave.
# Install Chrome from Google's apt repo (root checklist in
# book/src/operations/work-laptop.md); this aspect owns everything
# around it.
#
# `repd` launches the system Chrome with its own user-data-dir and
# app-id, so the enclave profile never shares cookies, history, or
# extensions with anything else, and Chrome is used for nothing but
# REPD. It also checks the GlobalProtect VPN first: the portal is only
# reachable on the VPN, and the browser logins (RSA SecurID PIN+token,
# then username/password) come after that.
_: {
  den.aspects.repd-chrome.homeManager =
    { pkgs, config, ... }:
    let
      chrome = "/opt/google/chrome/google-chrome";
      dataDir = "${config.xdg.dataHome}/repd-chrome";

      repd = pkgs.writeShellApplication {
        name = "repd";
        runtimeInputs = [
          pkgs.libnotify
          pkgs.gnugrep
        ];
        text = ''
          chrome=${chrome}
          data_dir=${dataDir}

          if [ ! -x "$chrome" ]; then
            msg="Google Chrome is not installed at $chrome. See the work-laptop root checklist (Chrome for REPD)."
            echo "repd: $msg" >&2
            notify-send -u critical "REPD" "$msg" || true
            exit 1
          fi

          # GlobalProtect must be up before the portal is reachable.
          # From a terminal, connect interactively; from the launcher,
          # just warn and still open the browser.
          if command -v globalprotect >/dev/null 2>&1; then
            if ! globalprotect show --status 2>/dev/null | grep -q "status: Connected"; then
              if [ -t 0 ]; then
                echo "repd: GlobalProtect is not connected — connecting." >&2
                globalprotect connect || true
              else
                notify-send -u normal "REPD" \
                  "GlobalProtect VPN is not connected. Run: globalprotect connect" || true
              fi
            fi
          fi

          # Chrome is a native Ubuntu binary launched from inside the
          # nixGL-wrapped niri session; drop the Nix GL environment so it
          # loads Ubuntu's mesa, not the Nix store's.
          unset LD_LIBRARY_PATH LIBGL_DRIVERS_PATH LIBVA_DRIVERS_PATH __EGL_VENDOR_LIBRARY_FILENAMES

          mkdir -p "$data_dir"
          exec "$chrome" \
            --user-data-dir="$data_dir" \
            --class=repd-chrome \
            --ozone-platform-hint=auto \
            --no-first-run \
            --no-default-browser-check \
            "$@"
        '';
      };
    in
    {
      home.packages = [ repd ];

      # Launcher entry. Not a registered http(s) handler on purpose:
      # ordinary links must keep going to the daily browser.
      xdg.desktopEntries.repd = {
        name = "REPD (Chrome)";
        genericName = "Enclave Browser";
        comment = "Google Chrome, isolated profile, REPD enclave only";
        exec = "repd %U";
        icon = "google-chrome";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        settings.StartupWMClass = "repd-chrome";
      };

      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^repd-chrome$"; } ];
          open-on-workspace = "research";
        }
      ];
    };
}
