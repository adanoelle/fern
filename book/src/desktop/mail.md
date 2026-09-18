# Mail

> Thunderbird, on the ORNL work laptop only, talking to the Exchange
> Online mailbox through the Microsoft Graph API. Chosen because it is the
> one shipped, non-beta Graph client on Linux and the only route that
> survives Microsoft's EWS shutdown without depending on IMAP staying
> enabled in the tenant. Nothing is configured on fern or moss yet.

## Why Graph, and why Thunderbird

A local client reaches Exchange Online through one of three doors:

| Door | Status | Clients |
| ---- | ------ | ------- |
| Exchange Web Services (EWS) | phased shutdown from 2026-10-01, retired 2027-04-01 | Evolution (classic), DavMail (default), Thunderbird ≤ 153 Exchange |
| IMAP + OAuth2 | survives, but tenants can disable it per mailbox | aerc + oama, neomutt, mbsync |
| Microsoft Graph API | the replacement | Thunderbird 154+ (mail only), DavMail 6.8 (beta), Evolution 3.60 (incomplete) |

Thunderbird 154 (September 2026) added native Graph support for Microsoft
365 mail. Calendar and address book over Graph are still in development,
so meeting invites stay on the web or in Teams for now. Every client also
needs the ORNL tenant to accept its OAuth2 app registration, which you
only find out at first sign-in.

## Thunderbird (`den.aspects.thunderbird`)

`modules/desktop/thunderbird.nix`, included by `ada-work`. Declares a
default `work` profile with update nags, telemetry, and the start page
off, remote content left at Thunderbird's default (blocked), and
`mailto:` links routed to Thunderbird. A niri rule puts it on the
research workspace.

The account is **not** declared in Nix: Graph sign-in is interactive
and the OAuth tokens belong in the profile. First run:

1. Account Settings → Account Actions → Add Mail Account.
2. Enter the ORNL address; Thunderbird detects Microsoft 365 and offers
   **Microsoft Graph**. Pick it, not Exchange/EWS and not IMAP.
3. Sign in through the Microsoft page (same Entra ID + MFA as Outlook
   web).

If the sign-in ends in "needs admin approval", the tenant blocks
Thunderbird's default app registration. Options, in order: ask ORNL IT to
grant consent for Thunderbird's client id; or register your own app in
Entra ID (if user app registration is allowed) and use the manual Graph
setup with that client and tenant id, per the
[Thunderbird wiki](https://blog.thunderbird.net/2026/09/thunderbird-desktop-new-protocol-support-microsoft-graph-api/).

Graph needs Thunderbird ≥ 154 and the shared nixpkgs pin carried 152, so
the package temporarily comes from a separate `nixpkgs-thunderbird`
input (a fresh nixos-unstable pin that does *not* follow `nixpkgs`).
Bumping the shared pin instead would have rebuilt every overlay package
that follows it (ghostty, nixd's Nix libraries, herdr's crates) from
source on the laptop. After the next `just update`, drop the input and
the `package` line in the aspect.

## Not chosen

- **aerc + oama** (terminal, XOAUTH2 over IMAP) — the best fit for the
  keyboard-driven desktop, but only if IMAP is enabled for the mailbox
  (Outlook web → Settings → Mail → Sync email) and the tenant accepts
  the client id. Candidate for a second phase once Thunderbird proves
  third-party clients are allowed at all.
- **DavMail** — Graph mode is beta; useful later as a CalDAV bridge if
  calendar matters before Thunderbird ships it.
- **Evolution** — Graph backend incomplete, and the GNOME data-server
  stack from Nix on Ubuntu is fragile.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/thunderbird.nix` | Thunderbird profile, prefs, mailto handler, niri rule |
| `modules/user-ada-work.nix` | includes the aspect (laptop only) |
