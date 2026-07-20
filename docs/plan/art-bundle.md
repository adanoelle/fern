# Art bundle — design note

Status: **planning** (not yet implemented). Companion to the garden
screenshot flow (2026-07): satty covers annotation, imv covers viewing;
this bundle covers actual art and image *creation*.

## Motivation

Art tooling currently has no home of its own:

- **Aseprite** ships via `modules/devtools/gamedev.nix` — installed as a
  gamedev asset tool, but it's also the pixel-art editor, and until the
  imv aspect pinned image defaults it was the accidental `xdg-open`
  handler for every PNG on the system.
- Nothing covers painting (Krita), vectors (Inkscape), or photo raster
  work (GIMP) at all.

An `art` aspect gives creative tools one declared destination, the same
way `gamedev` does for engine libraries and `desktop-apps` does for
daily drivers.

## Candidate tools

| Tool | Niche | Verdict |
|---|---|---|
| **Krita** | Digital painting, brushes, frame animation | **Core.** Best-in-class open-source painting; the main reason this bundle exists |
| **Aseprite** | Pixel art + sprite animation | **Core.** Already installed via gamedev (see ownership question below) |
| **Inkscape** | Vector / SVG | **Core.** No overlap with the other two; SVG is the lingua franca for icons and wallpaper sources |
| **GIMP 3** | Photo retouch / compositing | **Probable.** Distinct niche from Krita ("GIMP for photos, Krita for painting"); UI is clunky but nothing else fills the slot |
| **Blender** | 3D / sculpt / grease pencil | **Defer.** Heavy closure; add only when there's an actual 3D project |
| **darktable** | RAW photo development | **Defer.** Only relevant with a camera workflow |
| **Pinta** | Light raster edits | **Skip.** Satty (annotate) + imv + Krita cover the spectrum; a fourth raster tool is drawer-junk |
| **Graphite** | Emerging Rust vector/raster hybrid | **Watch.** Revisit when it stabilizes; not packaged maturely yet |

Starting lineup: **krita, aseprite, inkscape, gimp**.

## Shape

Follow the `gamedev` / `imv` aspect pattern — flat package aspect, no
config management until a real need appears:

```nix
# modules/desktop/art.nix — art & image creation tools
{ den, ... }:
{
  den.aspects.art.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        krita
        aseprite
        inkscape
        gimp
      ];
    };
}
```

Wire into `modules/desktop/bundle.nix` (`den.aspects.desktop-apps`)
alongside imv. Alternative — a `role` include for a hypothetical
art-machine split — is premature: one user, one workstation.

## Decisions to make at implementation time

1. **Aseprite ownership.** Options:
   - *Leave in gamedev, also list in art.* Nix dedupes the store path;
     `home.packages` merges. Cost: two declaration sites.
   - *Move to art, gamedev includes `den.aspects.art`.* Pulls painting
     tools onto any gamedev host — probably fine, possibly surprising.
   - *Move to art only.* Gamedev hosts lose it unless they also take art.

   Leaning: **first option** (list in both). Cheapest, no coupling, and
   "sprite tool for gamedev" / "pixel-art editor for art" are genuinely
   two reasons to want it.

2. **GIMP in or out of the initial commit.** Zero cost to defer; add
   the day a photo-compositing task actually appears.

## Invariants (lessons already paid for)

- **Image mime defaults belong to `modules/desktop/imv.nix`.** Every
  tool in this bundle registers `.desktop` handlers for `image/*`; the
  HM-managed `xdg.mimeApps.defaultApplications` pins are what keep
  `xdg-open` (and the garden screenshot card's `open` action) resolving
  to a viewer. Installing Krita/GIMP must NOT move those pins — if an
  image suddenly opens in an editor again, the regression is in imv.nix,
  not here.
- **Filing:** per `FILING.md`, exports/finished pieces go to
  `~/media/pictures/`; per-project sources live with the project under
  `~/src/<project>/`. No tool gets to invent `~/Pictures` back into
  existence.
- **No config management yet.** Krita/GIMP configs are mutable app
  state; don't HM-manage them until there's a proven reason (the
  settings.json seed-once pattern in garden is the template if ever
  needed).

## Deployment

Standard: new file needs `git add -N` before flake eval sees it
(learned during imv), then `nix flake check` and `just switch` from
fern (garden-shell uninvolved).
