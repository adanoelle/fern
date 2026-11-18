# Browsers

> Three browsers, three jobs. Zen is the daily driver everywhere (fast,
> Firefox-based, native workspaces and nestable tab folders, declaratively
> configured). Ungoogled Chromium is the fallback for web apps that a
> Gecko browser falls over on. On the work laptop, a system-installed
> Google Chrome is used for exactly one site that requires it, through an
> isolated launcher.

## Why Zen, and why not a Chromium fork

The daily browser has to work on two very different machines: the NixOS
hosts and the work laptop (Ubuntu 24.04, standalone home-manager).
Ubuntu 24.04 sets `kernel.apparmor_restrict_unprivileged_userns=1`. A
Chromium-family browser only gets its sandbox with a root-owned SUID
helper (which a Nix-store binary can't be) or an AppArmor profile
granting `userns` to a fixed path (Ubuntu ships those only for the vendor
installs under `/opt`). That is why the laptop's Electron apps run with
`--no-sandbox`. For a browser that is not acceptable, so Vivaldi, Brave,
Helium, and Chromium were ruled out for the laptop even though Vivaldi's
tab stacks are the strongest native tab management around.

Firefox-family browsers degrade to their seccomp sandbox without user
namespaces and just run. Zen adds what Firefox lacks: workspaces (an
isolated set of tabs and pinned tabs per workspace, optionally bound to a
container), tab folders that can nest, vertical tabs, split view, and a
compact UI. Extensions and profiles carry over from Firefox. (Firefox
itself gained flat tab groups in 137 and vertical tabs in 136, so staying
on Firefox was the cheap alternative.)

Zen is not in nixpkgs. The `zen-browser` flake input
(`0xc000022070/zen-browser-flake`) re-hosts the upstream release
artifacts (`twilight` variant, reproducible) and provides the
`programs.zen-browser` home-manager module. In-app updates are disabled
by policy; the flake input is the update path.

## Zen (`den.aspects.zen`)

Included by the `desktop-apps` bundle (fern, yarrow) and `ada-work`
(laptop). `setAsDefaultBrowser` makes it the xdg handler for http(s) and
HTML. On the NixOS hosts `Mod+B` in niri spawns `zen-twilight` and a
window rule routes it to the research workspace; the laptop has a
dedicated browser channel instead.

Configuration layers, from enforced to user-overridable:

| Layer | Where | Used for |
| ----- | ----- | -------- |
| `policies` | `policies.json` | no app updates, telemetry, studies, Pocket, password saving (Bitwarden owns passwords), tracking protection on |
| `profiles.default.settings` | `prefs.js` | welcome screen seen, workspaces resume where left off, no close-tabs warning |
| `profiles.default.userChrome` | `userChrome.css` | not used yet; the hook for a garden-palette theme |

On the laptop Zen inherits GL from the nixGL-wrapped compositor like
Firefox did; no per-app wrap. The Nix Firefox stays installed as a
fallback until the migration settles.

## An isolated system Chrome (`den.aspects.repd-chrome`, laptop only)

One site the laptop needs must be opened in Chrome. Chrome itself comes
from Google's apt repository (see
[Standalone Home on Ubuntu](../operations/work-laptop.md)) so it gets its
SUID sandbox helper and Ubuntu's AppArmor profile. Nix owns everything
around it:

- The launcher starts `/opt/google/chrome/google-chrome` with its own
  `--user-data-dir` and app-id, so that profile shares no cookies,
  history or extensions with anything else, and Chrome is used for
  nothing but that site.
- It checks the VPN first: from a terminal it connects interactively;
  from the launcher it warns and still opens the browser.
- It strips the session's nixGL `LD_LIBRARY_PATH` so the native Chrome
  loads Ubuntu's mesa.
- It adds a launcher entry and is deliberately not registered as an
  http(s) handler.

## Chromium (`den.aspects.chromium`)

Ungoogled Chromium is the secondary browser on fern and yarrow
(desktop-apps bundle)
for web apps that misbehave in Gecko. Wayland via Ozone, VAAPI decode,
sync disabled, basic password store, FedCM and cohort features off. Not
on the laptop (same sandbox reasoning as above).

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/zen.nix` | Zen browser: policies, prefs, xdg default, niri rule |
| `modules/foreign/repd-chrome.nix` | isolated launcher around the system Chrome (laptop) |
| `modules/desktop/chromium.nix` | Ungoogled Chromium with Wayland/privacy flags |
