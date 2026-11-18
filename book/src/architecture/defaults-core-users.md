# Defaults, Core & Users

> The configuration every NixOS host starts from: `den.default` (state
> version fallbacks and the den helpers that define the user and the
> hostname), the `core` aspect (Nix settings and overridable fleet
> defaults), the `users` aspect (accounts, centralised group membership,
> key-only SSH, NetworkManager) and the `boot` aspect. Also the policy
> for `system.stateVersion`.

**Goes on:** `den.default` applies to every host and home, the work
laptop included. `core` and `users` reach fern and yarrow through the
`workstation` role (and are in the `server` role); `boot` is included by
each x86 host aspect directly. None of the system side applies to the
work laptop, which has no NixOS system.

## `modules/defaults.nix`: `den.default`

`den.default` is applied to every host and user without being included
by anything. It holds two things.

**State version fallbacks.** `system.stateVersion` and
`home.stateVersion` are both set to `"25.11"` with `lib.mkDefault`. They
are fallbacks only; see [State versions](#state-versions) below.

**Three den helpers** (`den._.<name>`, den's built-in aspects):

| Helper | What it does here |
| ------ | ----------------- |
| `den._.define-user` | For each topology user: creates `users.users.<name>` as a normal user with home `/home/<name>` on the system side, and sets `home.username` / `home.homeDirectory` on the Home Manager side. Also works for a standalone home |
| `den._.primary-user` | Adds the user to `wheel` and `networkmanager` |
| `den._.hostname` | Sets `networking.hostName` from the topology name |

So nothing in the repository writes a hostname or a home directory:
both come from `modules/hosts.nix`. `modules/users.nix` also grants
`wheel` and `networkmanager`, so those two groups appear twice in the
evaluated list, which is harmless.

One more helper, `den._.mutual-provider`, is used in
`modules/dendritic.nix`; see
[The Flake & Bootstrap](flake-and-bootstrap.md).

## `modules/core.nix`: the `core` aspect

| Setting | Value | Overridable |
| ------- | ----- | ----------- |
| `nixpkgs.config.allowUnfree` | `true` | |
| `nixpkgs.overlays` | rust-overlay, claude-code | see [overlays](flake-and-bootstrap.md#overlays-declared-in-two-places) |
| `nix.settings.experimental-features` | `nix-command`, `flakes` | |
| `nix.settings.trusted-users` | `root` plus every topology user of the host | appends; see below |
| `programs.nix-ld.enable` | `true` | `mkDefault` |
| `time.timeZone` | `America/New_York` | `mkDefault` |

### `mkDefault` versus a plain definition

The convention for fleet defaults is `lib.mkDefault`: a host that
differs just sets the option normally and wins, with no `mkForce`. A
host in another timezone sets `time.timeZone` and nothing else.

`trusted-users` is the exception, and the comment in `core.nix` records
why. nixpkgs itself *defines* `nix.settings.trusted-users = [ "root" ]`
at normal priority. A `mkDefault` list has lower priority than that
definition, so it does not merge with it: it is silently dropped. The
option is therefore defined plainly, which merges with the nixpkgs
value; hosts can still append to it, or `mkForce` to replace it.

The general rule: `mkDefault` is safe only when nothing else defines the
option at normal priority. An option *default* does not count (that is
why `mkDefault` works for `programs.nh.flake` in `modules/cli/nh.nix`),
but a definition inside a nixpkgs module does. For list options, check
before reaching for `mkDefault`.

The users are added by a parametric include that maps over
`host.users`; see
[Aspects & Composition](aspects.md#parametric-includes).

## `modules/users.nix`: the `users` aspect

**Accounts.** One normal user per topology user, with fish as the login
shell (`programs.fish.enable` is set system-wide for that) and one
authorised SSH public key. No user name appears in the file.

**Group membership is centralised and conditional.** Service aspects do
not touch `users.users.<name>.extraGroups`. This one file grants every
group, keyed on whether the relevant service is enabled on the host:

| Group | Granted when |
| ----- | ------------ |
| `wheel`, `networkmanager` | always |
| `i2c` | `hardware.i2c.enable` (the DDC brightness aspect) |
| `docker` | `virtualisation.docker.enable` |
| `audio` | `services.pipewire.enable` |
| `gamemode` | `programs.gamemode.enable` |
| `video`, `input`, `seat` | `services.greetd.enable` |

A new service that needs a group gets a line here, not an `extraGroups`
in its own aspect. This also avoids a half-defined user ("exactly one of
isSystemUser / isNormalUser") on a host that includes the service but
not `users`.

**SSH is key-only.** `services.openssh` is enabled with
`PasswordAuthentication` and `KbdInteractiveAuthentication` off. Because
of that every account needs an authorised key or a freshly built host is
unreachable over SSH, which is why the key is set here rather than in a
user layer.

**Networking.** `networking.networkmanager.enable = true` lives here
too, so it arrives with the aspect. The `server` role's header notes
that a real server host would want this split out.

## `modules/boot.nix`: the `boot` aspect

systemd-boot with `canTouchEfiVariables = true`: the UEFI x86 default.
It deliberately sets no kernel; each host aspect chooses its own. Apple
Silicon uses `boot-asahi` (`modules/asahi/boot.nix`) instead, where
`canTouchEfiVariables` must be `false`.

`boot` is not part of any role: a host aspect includes its bootloader
aspect itself.

## State versions

`system.stateVersion` records the release a machine was **installed**
with. It gates stateful data migrations, not features.

- Each host pins its own, in its host aspect, as a plain definition.
  The values differ between machines; each machine page gives its own.
- Never bump it, on any host, including after an upgrade.
- A new host pins the release current at install time. Do not copy
  another host's value.
- The `mkDefault "25.11"` in `den.default` is only a fallback for a host
  that has not pinned yet, and is correct for a host only by
  coincidence.

`home.stateVersion` is not pinned per host anywhere: every home,
including the work laptop's, takes the `"25.11"` fallback from
`den.default`. A few aspects pin individual Home Manager options whose
default changes with the state version, each with a comment saying so.

## Key files

| File | Role |
| ---- | ---- |
| `modules/defaults.nix` | `den.default`: state version fallbacks, den helpers |
| `modules/core.nix` | Nix settings, overlays, fleet defaults |
| `modules/users.nix` | Accounts, groups, sshd, NetworkManager |
| `modules/boot.nix` | systemd-boot |
| `modules/host-*.nix` | Per-host `system.stateVersion` |
| `modules/hosts.nix` | Topology the helpers and parametric includes read |
