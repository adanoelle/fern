# modules/desktop/zen.nix — Zen browser (daily driver)
#
# Firefox-based, so extensions and profiles carry over from Firefox and
# it needs no Chromium sandbox helper: on the Ubuntu work laptop
# (apparmor_restrict_unprivileged_userns=1) a Chromium-family browser
# from the Nix store would have to run --no-sandbox, while Firefox's
# sandbox degrades gracefully. Native workspaces + nestable tab folders
# + vertical tabs are the tab-management story.
#
# Not in nixpkgs: the package and the programs.zen-browser module come
# from inputs.zen-browser (community flake re-hosting upstream release
# artifacts — "twilight" is the reproducible variant). The Nix build
# updates the browser; in-app updates are disabled by policy.
#
# On the laptop the browser inherits GL from the nixGL-wrapped
# compositor like Firefox did (see modules/foreign/ubuntu-desktop.nix);
# no per-app wrap needed.
{ inputs, ... }:
{
  den.aspects.zen.homeManager = {
    imports = [ inputs.zen-browser.homeModules.twilight ];

    programs.zen-browser = {
      enable = true;
      # xdg default handler for http(s) and html. Replaces Firefox.
      setAsDefaultBrowser = true;

      # Enforced (policies.json). Reference:
      # https://mozilla.github.io/policy-templates/
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableFeedbackCommands = true;
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        # Passwords live in Bitwarden (den.aspects.bitwarden / rbw).
        OfferToSaveLogins = false;
        AutofillCreditCardEnabled = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = false;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };

      # User-overridable defaults (prefs.js). Zen keys under "zen.*".
      profiles.default.settings = {
        "zen.welcome-screen.seen" = true;
        "zen.workspaces.continue-where-left-off" = true;
        "browser.tabs.warnOnClose" = false;
        "browser.aboutConfig.showWarning" = false;
      };
    };

    # Route the browser to the research workspace. The Wayland app-id
    # follows the binary name (zen-twilight / zen-beta).
    programs.niri.settings.window-rules = [
      {
        matches = [ { app-id = "^zen(-twilight|-beta)?$"; } ];
        open-on-workspace = "research";
      }
    ];
  };
}
