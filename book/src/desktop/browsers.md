# Browsers

> Zen is the daily browser on every graphical machine. Ungoogled
> Chromium is the second browser on the NixOS hosts, for web apps that
> misbehave in a Gecko browser. On the work laptop a system-installed
> Google Chrome is used for one site that requires it, through a
> launcher that keeps it in an isolated profile.

| Aspect | Goes on | Included from |
| ------ | ------- | ------------- |
| `zen` | fern, yarrow, work laptop | `desktop-apps` bundle; `ada-work` |
| `chromium` | fern, yarrow | `desktop-apps` bundle |
| `repd-chrome` | work laptop only | `ada-work` |

## Why a Firefox-family daily browser

The same browser has to run on NixOS and on the work laptop's Ubuntu
24.04, which restricts unprivileged user namespaces. A Chromium-family
browser gets its sandbox there only through a root-owned SUID helper or
an AppArmor profile tied to a fixed install path; a binary in the Nix
store has neither and would have to run with `--no-sandbox`. Firefox's
sandbox degrades gracefully instead, so a Firefox-based browser from Nix
works on both.

## Zen (`den.aspects.zen`)

Zen is not in nixpkgs. The `zen-browser` flake input provides the
package (the `twilight` variant) and the `programs.zen-browser` Home
Manager module.

| Layer | Set |
| ----- | --- |
| `policies` (enforced) | no in-app updates, telemetry, studies, feedback or Pocket; no default-browser prompt; no password saving or card autofill (passwords live in the [password manager](../security/password-manager.md)); tracking protection on |
| `profiles.default.settings` (user-overridable) | welcome screen seen, workspaces resume where left off, no close-tabs warning, no `about:config` warning |

Other behaviour:

- `setAsDefaultBrowser` makes Zen the handler for http(s) and HTML.
- Updates arrive by updating the flake input, never in the app.
- `xdg.configFile."mimeapps.list".force = true`: applications rewrite
  `~/.config/mimeapps.list` in place, which would otherwise make the
  next activation abort. Associations that should persist belong in
  `xdg.mimeApps`.
- A niri window rule opens Zen on the `research` channel. The work
  laptop's channel table overrides that with its own browser channel.
- [`Mod+B`](niri.md#keybinds) spawns `zen-twilight`.

## Chromium (`den.aspects.chromium`)

`pkgs.ungoogled-chromium` through `programs.chromium`, with native
Wayland (Ozone), VA-API video decode and encode, sync disabled, the
basic password store, and FedCM, interest cohorts and autofill server
communication turned off. `NIXOS_OZONE_WL=1` is set as a session
variable. Not on the work laptop, for the sandbox reason above.

## Isolated system Chrome (`den.aspects.repd-chrome`)

One site the work laptop needs must be opened in Chrome. Chrome itself
is installed from its vendor apt repository, outside Nix, so that it
has its sandbox helper and the distribution's AppArmor profile (the
install step is in [Work laptop](../machines/work-laptop.md)). The
aspect owns everything around it:

- A launcher script starts `/opt/google/chrome/google-chrome` with its
  own `--user-data-dir` under `$XDG_DATA_HOME` and its own window class,
  so that profile shares no cookies, history or extensions with
  anything else. If Chrome is missing it says so and exits.
- It checks the VPN first: from a terminal it starts the connection,
  from the desktop launcher it only warns, and it opens the browser
  either way.
- It unsets the session's Nix GL environment variables so the native
  Chrome loads the distribution's graphics libraries.
- A desktop entry makes it available from the launcher. It is
  deliberately not registered as an http(s) handler.
- A Home Manager activation step adds intermediate certificates to the
  user's NSS database with no trust flags, to complete a certificate
  chain that the site does not send in full.

## Key files

| File | Purpose |
| ---- | ------- |
| `modules/desktop/zen.nix` | Zen: policies, prefs, default handler, niri rule |
| `modules/desktop/chromium.nix` | Ungoogled Chromium flags |
| `modules/foreign/repd-chrome.nix` | launcher around the system Chrome |
| `flake.nix` | the `zen-browser` input |
