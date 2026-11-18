# Mail

> Thunderbird, configured for the work mailbox: a Microsoft 365
> (Exchange Online) account reached through the Microsoft Graph API,
> which Thunderbird supports natively from version 154. The profile and
> preferences are declared; the account is added by hand.

**Goes on:** work laptop only (`den.aspects.thunderbird`, included from
`modules/user-ada-work.nix`). No mail client is configured on fern or
yarrow.

## What is declared

`modules/desktop/thunderbird.nix` enables `programs.thunderbird` with
one default profile, `work`:

- update prompts, the default-client check, telemetry and the start
  page are off;
- addresses are not collected from outgoing mail;
- `mailto:` links open in Thunderbird.

The work layer's channel table decides which niri channel it opens on.

Graph support covers mail only; calendar and address book are not
available through it yet.

## What is not declared

The account. Signing in is interactive and the OAuth tokens belong in
the profile, not in the repository. On first run:

1. Account Settings → Add Mail Account.
2. Enter the work address and choose **Microsoft Graph** as the
   protocol.
3. Complete the sign-in in the browser window Thunderbird opens.

If the sign-in ends with a request for administrator approval, the
tenant does not accept Thunderbird's default application registration.
Thunderbird's manual setup accepts a custom client id and tenant id for
that case.

## The package pin

Graph needs Thunderbird 154 or newer, and the shared `nixpkgs` pin
carries an older release. The package therefore comes from a separate
flake input, `nixpkgs-thunderbird`, which tracks `nixos-unstable` and
deliberately does not follow `nixpkgs`: Thunderbird is then substituted
from the binary cache, and the shared pin (and every overlay package
built against it) is left alone.

This is temporary. Once an update of the shared pin moves it past 154,
remove the `package` line in the aspect and the input in `flake.nix`.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/thunderbird.nix` | profile, preferences, `mailto:` handler, package override |
| `flake.nix` | the `nixpkgs-thunderbird` input |
| `modules/user-ada-work.nix` | the only includer |
