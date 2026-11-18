# Gaming

> Steam with a Gamescope session, GameMode, and controller support on
> the system side; an overlay, launcher and Proton helpers on the user
> side. Two aspects, taken together by the machines that play games.

**Goes on:** fern, yarrow. Each includes `gaming` in its host aspect
and forwards `gaming-hm` to its users. Not on the work laptop.

## System side: `gaming`

`modules/gaming.nix`, NixOS only.

| Setting                               | Value                              |
| ------------------------------------- | ---------------------------------- |
| `programs.steam`                      | enabled, with a Gamescope session  |
| Steam extra packages                  | `gamescope`, `mangohud`            |
| `programs.gamescope`                  | enabled, `capSysNice = true`       |
| `programs.gamemode`                   | enabled; `renice = 10`; GPU optimisations accepted for device 0 |
| `hardware.steam-hardware`             | enabled (udev rules for Steam-supported controllers) |
| `services.joycond`                    | enabled                            |

Membership of the `gamemode` group is granted in `modules/users.nix`
whenever GameMode is enabled; see
[Defaults, core and users](../architecture/defaults-core-users.md).

On yarrow the `laptop` role enables power-profiles-daemon, which
GameMode can switch while a game runs (`modules/roles/laptop.nix`).

### Firewall

| Option                                   | Value   | Effect                    |
| ---------------------------------------- | ------- | ------------------------- |
| `steam.remotePlay.openFirewall`          | `true`  | Remote Play ports opened on every interface |
| `steam.dedicatedServer.openFirewall`     | `false` | server ports stay closed  |

Remote Play is the only thing in this configuration that opens ports
for games. As evaluated, it adds TCP 27036 and 27037, UDP 27036, 10400
and 10401, and UDP 27031 to 27035; the list comes from the nixpkgs
Steam module and can change with a nixpkgs update.

### Controllers

Three kernel modules are loaded at boot:

| Module            | Controllers                 |
| ----------------- | --------------------------- |
| `xpad`            | Xbox                        |
| `hid_playstation` | DualShock 4, DualSense      |
| `hid_nintendo`    | Switch Pro, Joy-Con         |

`joycond` handles Joy-Con pairing and combining.

## User side: `gaming-hm`

`modules/desktop/gaming-hm.nix`, home-manager only. Installs
`mangohud`, `protonup-qt`, `lutris` and `protontricks`.

It is forwarded from each host's `provides.to-users` list, not from
the shared desktop bundle: gaming is an opt-in layer per host
(`modules/desktop/bundle.nix`).

## Related

Tools for making games, as opposed to playing them, are on
[Game development and art](../gamedev/gamedev-and-art.md).

## Key files

| File                            | Purpose                                     |
| ------------------------------- | ------------------------------------------- |
| `modules/gaming.nix`            | Steam, Gamescope, GameMode, controllers     |
| `modules/desktop/gaming-hm.nix` | MangoHud, ProtonUp-Qt, Lutris, Protontricks |
| `modules/users.nix`             | `gamemode` group membership                 |
| `modules/host-fern.nix`, `modules/host-yarrow.nix` | where both aspects are included |
