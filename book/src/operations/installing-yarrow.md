# Installing yarrow (Framework Laptop 13 Pro)

yarrow is the portable art, game-development and playtesting machine.
Its configuration (`modules/host-yarrow.nix`) is already in the flake;
what is missing until the machine is installed is its real
`hosts/yarrow/hardware.nix` and its registration as a secrets recipient.
Both happen during the install below.

Choices already made: ext4, no disk encryption, no hibernation (zram
swap only), systemd-boot.

## Before you start

- A recent **nixos-unstable** installer ISO. The hardware is new, so an
  older ISO may not bring up Wi-Fi; a USB Ethernet adapter or phone
  tethering is the fallback.
- In the firmware setup (F2 at boot), turn **Secure Boot off**:
  systemd-boot is not signed here.
- fern within reach. The key that can re-encrypt the secrets
  (`~/.config/sops/age/keys.txt`) lives there.

## 1. Partition and format

Check the disk name with `lsblk` first; this assumes `/dev/nvme0n1` and
**erases it**.

```bash
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary ext4 1GiB 100%

sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkfs.ext4 -L nixos /dev/nvme0n1p2

sudo mount /dev/disk/by-label/nixos /mnt
sudo mount --mkdir -o umask=077 /dev/disk/by-label/BOOT /mnt/boot
```

## 2. Create the host key and register it for secrets

The `secrets` aspect decrypts with the machine's SSH host key, so the
key has to exist, and be a recipient, before the first build.

On yarrow (installer):

```bash
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -C root@yarrow -f /mnt/etc/ssh/ssh_host_ed25519_key
nix shell nixpkgs#ssh-to-age -c ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

That prints one `age1…` line. It is a public key; get it to fern any
way that is convenient.

On fern, in a new worktree and branch (for example
`chore/register-yarrow`):

1. In `.sops.yaml`, add `- &host_yarrow age1…` under `keys`, and add
   `*host_yarrow` to the `secrets/main.yaml` rule.
2. `sops updatekeys secrets/main.yaml`
3. Commit and push the branch.

## 3. Bring in the configuration

Back on yarrow:

```bash
sudo mkdir -p /mnt/home/ada/src
sudo chown "$USER" /mnt/home/ada/src      # so git runs without sudo
git clone https://github.com/adanoelle/fern /mnt/home/ada/src/fern
cd /mnt/home/ada/src/fern
git switch chore/register-yarrow

sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/yarrow/hardware.nix
git add hosts/yarrow/hardware.nix
```

This assumes the yarrow host itself is already merged to main, so that
`chore/register-yarrow` was branched from a main that contains it.
Ownership of the checkout is handed to `ada` in the next step.

The generated file replaces the placeholder. It is the one time that
file is written; never edit it by hand afterwards.

## 4. Install

```bash
sudo nixos-install --flake .#yarrow
sudo nixos-enter --root /mnt -c 'passwd ada'
sudo nixos-enter --root /mnt -c 'chown -R ada:users /home/ada'
reboot
```

`nixos-install` asks for a root password at the end.

## 5. First boot

Log in as `ada` and pick Niri in the greeter, then:

```bash
cd ~/src/fern
git remote set-url origin git@github.com:adanoelle/fern
git commit -m "feat(yarrow): add generated hardware configuration"
git push            # then open the PR for chore/register-yarrow

sudo tailscale up   # one-time, interactive
fwupdmgr refresh && fwupdmgr update
```

The GitHub SSH key arrives through sops, so pushing works once the
secrets step above was done.

## 6. Check the hardware

| Check | How |
| --- | --- |
| Wi-Fi, Bluetooth | connect, pair headphones |
| Graphics | `vulkaninfo --summary`, `glxinfo -B` |
| Speakers, mic, headphone jack | `pavucontrol`; the "Noise-suppressed microphone" source should be listed |
| Brightness keys | the garden OSD should follow |
| Suspend | close the lid, reopen: lock screen, Wi-Fi returns |
| Idle | on battery: locks after 10 minutes, suspends after 20 |
| Power profiles | `powerprofilesctl list` |
| Controller | plug in or pair, then Steam → Settings → Controller |
| Steam | start once and let it update; `gamescope -- vkcube` |

If graphics, audio or Wi-Fi misbehave, the first thing to try is a newer
kernel: yarrow already takes `linuxPackages_latest`, so that means
`just update`. That bumps the nixpkgs pin every machine shares, and on
the work laptop a bump has meant several hundred local source builds, so
plan it rather than doing it mid-install.

## Afterwards

- **Fingerprint reader**: disabled in `host-yarrow.nix` until it has
  been tried with tuigreet and the garden lock. Remove the
  `services.fprintd.enable = false` line to try it, then `fprintd-enroll`.
- **Recording with an interface**: `studio-mode on` forces 48 kHz and a
  128-frame buffer; `studio-mode off` returns to the defaults.
- **Speakers**: no tuning is shipped. EasyEffects is installed if a
  preset for this model turns out to be worth using.
- **Heavier layers**: `music` is a one-line addition to
  `provides.to-users.includes` in `host-yarrow.nix`. `ada-hyprland` also
  needs `programs.hyprland.enable = true` on the host, and `obs` is
  built with CUDA support today, which this machine does not want.
