# modules/desktop/thunderbird.nix — Thunderbird mail client
#
# Written for the ORNL work mailbox (Exchange Online) and included only
# from ada-work for now. Thunderbird 154+ talks to Microsoft 365 through
# the Microsoft Graph API natively — the one shipped, non-beta Graph
# client on Linux, and the only route that survives Microsoft's Exchange
# Web Services shutdown (phased from 2026-10-01) without depending on
# the tenant leaving IMAP enabled. Graph support is mail-only as of
# Thunderbird 154; calendar and address book are still in development.
#
# The account itself is a one-time interactive sign-in (Account
# Settings → Add Mail Account → enter the ORNL address → pick
# "Microsoft Graph"); the OAuth tokens live in the profile, not in this
# repo. If the tenant refuses Thunderbird's default app registration
# ("needs admin approval"), the manual setup takes a custom client and
# tenant id — see book/src/desktop/mail.md.
#
# On the laptop Thunderbird inherits GL from the nixGL-wrapped
# compositor like Firefox/Zen; no per-app wrap.
#
# TEMPORARY: the package comes from inputs.nixpkgs-thunderbird (a fresh
# nixos-unstable pin) because the shared nixpkgs pin still carries 152.
# Once `just update` moves the shared pin past 154, delete the `package`
# line below and the input in flake.nix.
{ inputs, ... }:
{
  den.aspects.thunderbird.homeManager =
    { pkgs, ... }:
    {
      programs.thunderbird = {
        enable = true;
        package = inputs.nixpkgs-thunderbird.legacyPackages.${pkgs.stdenv.hostPlatform.system}.thunderbird;

        profiles.work = {
          isDefault = true;
          settings = {
            # Nix updates the package; keep Thunderbird from nagging.
            "app.update.auto" = false;
            "mail.shell.checkDefaultClient" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "toolkit.telemetry.enabled" = false;
            "mailnews.start_page.enabled" = false;
            # Reading: plain-text-friendly, no remote content by default.
            "mailnews.message_display.disable_format_flowed_support" = false;
            "mailnews.display.prefer_plaintext" = false;
            "mail.compose.default_to_paragraph" = false;
            "privacy.donottrackheader.enabled" = true;
            # Don't collect addresses from every outgoing mail.
            "mail.collect_email_address_outgoing" = false;
          };
        };
      };

      # mailto: links from Zen open here.
      xdg.mimeApps.defaultApplications."x-scheme-handler/mailto" = [ "thunderbird.desktop" ];

      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^thunderbird$"; } ];
          open-on-workspace = "research";
        }
      ];
    };
}
