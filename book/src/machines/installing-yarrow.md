# Installing yarrow

> A walkthrough for the first install of [yarrow](yarrow.md), the
> Framework Laptop 13 Pro. Its configuration is already in the flake.
> The install supplies the two things that are missing: the real
> `hosts/yarrow/hardware.nix`, and the machine's registration as a
> secrets recipient.

Choices already made: ext4, no disk encryption, no hibernation (zram
swap only), systemd-boot.

## Before you start

- A recent **nixos-unstable** installer ISO. The hardware is new, so an
  older ISO may not bring up Wi-Fi; a USB Ethernet adapter or phone
  tethering is the fallback.
- In the firmware setup (F2 at boot), turn **Secure Boot off**: the
  systemd-boot this configuration installs is not signed.
- fern within reach. The age key that can re-encrypt the secrets
  (`~/.config/sops/age/keys.txt`) lives there.
- `nixosConfigurations.yarrow` on `main`, so that the branch made in
  step 2 contains it.

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

The labels `nixos` and `BOOT` are the ones the placeholder
`hosts/yarrow/hardware.nix` uses.

## 2. Create the host key and register it for secrets

The `secrets` aspect decrypts with the machine's SSH host key
(`/etc/ssh/ssh_host_ed25519_key`), so the key has to exist, and be a
recipient, before the first build. Background is in
[sops-nix](../security/sops-nix.md).

On yarrow (installer):

```bash
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -C root@yarrow -f /mnt/etc/ssh/ssh_host_ed25519_key
nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#ssh-to-age -c ssh-to-age < /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

That prints one `age1…` line. It is a public key; get it to fern any
way that is convenient.

On fern, in a new worktree and branch (for example
`chore/register-yarrow`):

1. In `.sops.yaml`, replace the commented `host_yarrow` line under
   `keys` with `- &host_yarrow age1…`, and add `*host_yarrow` to the
   `age` list of the `secrets/main.yaml` rule.
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

If the installer has no `git`, get one with `nix-shell -p git`.

The generated file replaces the placeholder. `git add` matters: a flake
only sees files git knows about. This is the one time
`hosts/yarrow/hardware.nix` is written; never edit it by hand
afterwards. Ownership of the checkout is handed to `ada` in the next
step.

## 4. Install

```bash
sudo nixos-install --flake .#yarrow
sudo nixos-enter --root /mnt -c 'passwd ada'
sudo nixos-enter --root /mnt -c 'chown -R ada:users /home/ada'
reboot
```

`nixos-install` asks for a root password at the end. `ada` has no
password in the configuration, so the `passwd` step is what makes the
first login possible.

## 5. First boot

Log in as `ada` at the greeter (Niri is the only session), then:

```bash
cd ~/src/fern
git commit -m "feat(yarrow): add generated hardware configuration"
git push            # then open the PR for chore/register-yarrow

sudo tailscale up   # one-time, interactive
fwupdmgr refresh && fwupdmgr update
```

The GitHub SSH key (`~/.ssh/github`) arrives through sops, and the
shared git configuration rewrites `https://github.com/` to SSH, so the
HTTPS clone pushes over SSH without changing the remote. Both depend on
step 2 having been done.

From here on, rebuild with `just test` and `just switch`; see
[Day to day](../operations/day-to-day.md).

## 6. Check the hardware

| Check | How |
| --- | --- |
| Wi-Fi, Bluetooth | connect, pair headphones |
| Graphics | `vulkaninfo --summary`, `glxinfo -B` |
| Speakers, mic, headphone jack | `pavucontrol`; the "Noise-suppressed microphone" source should be listed |
| Brightness keys | the panel dims and the garden OSD follows |
| Suspend | close the lid, reopen: lock screen, Wi-Fi returns |
| Idle | locks after 10 minutes; on battery, suspends after 20 |
| Power profiles | `powerprofilesctl list` |
| Controller | plug in or pair, then Steam → Settings → Controller |
| Steam | start once and let it update; `gamescope -- vkcube` |

If graphics, audio or Wi-Fi misbehave, the first thing to try is a newer
kernel. yarrow already takes `linuxPackages_latest`, so that means
`just update`. That bumps the nixpkgs pin every machine shares, and on
the [work laptop](work-laptop.md#day-to-day) a bump is expensive, so
plan it instead of doing it mid-install.

## Afterwards

- **Fingerprint reader**: disabled in `modules/host-yarrow.nix` until
  it has been tried with tuigreet and the garden lock. Remove the
  `services.fprintd.enable = false` line to try it, then
  `fprintd-enroll`.
- **Recording with an interface**: `studio-mode on` forces 48 kHz and a
  128-frame buffer (`studio-mode on <frames>` for another size);
  `studio-mode off` returns to the defaults. See
  [Audio](../services/audio.md).
- **Speakers**: no tuning is shipped. EasyEffects is installed if a
  preset for this model turns out to be worth using.
- **Heavier layers**: what yarrow leaves out, and what each would take
  to add, is listed on the [yarrow](yarrow.md#what-it-deliberately-leaves-out)
  page.
