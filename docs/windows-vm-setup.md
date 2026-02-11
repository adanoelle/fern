# Windows VM with GPU Passthrough and Looking Glass

This guide explains how to run a Windows VM on your NixOS system with
near-native performance using GPU passthrough and Looking Glass for seamless
integration.

## Architecture Overview

The setup consists of three NixOS modules:

1. **VFIO** (`vfio.nix`) - Binds your RTX 3070 to the VFIO driver for
   passthrough
2. **Windows VM** (`windows-vm.nix`) - Configures libvirtd, QEMU, and management
   tools
3. **Looking Glass** (`looking-glass.nix`) - Enables seamless display sharing
   via shared memory

## Hardware Configuration

- **GPU**: NVIDIA RTX 3070 (PCI ID: 10de:2484)
- **CPU**: AMD (IOMMU support enabled)
- **Audio**: Separate DAC setup (GPU audio stays on host)

## Installation

### 1. Enable the Modules

Add these modules to your `hosts/fern/configuration.nix`:

```nix
imports = [
  # ... existing imports ...
  self.nixosModules.vfio
  self.nixosModules.windows-vm
  self.nixosModules.looking-glass
];

# Enable GPU passthrough
virtualisation.vfio.enable = true;

# Enable Windows VM infrastructure
virtualisation.windows-vm.enable = true;

# Enable Looking Glass client
programs.looking-glass.enable = true;
```

### 2. Rebuild Your System

```bash
# Format the Nix files
nixpkgs-fmt .

# Check for errors
nix flake check

# Test the configuration (important!)
sudo nixos-rebuild test --flake .#fern

# If test succeeds, apply permanently
sudo nixos-rebuild switch --flake .#fern

# Reboot to load VFIO modules
sudo reboot
```

### 3. Verify VFIO is Working

After reboot, check that your GPU is bound to VFIO:

```bash
# Check VFIO binding
lspci -nnk -d 10de:2484

# Should show: Kernel driver in use: vfio-pci
```

## Creating the Windows VM

### 1. Launch virt-manager

```bash
virt-manager
```

### 2. Create New VM

1. Click "Create a new virtual machine"
2. Choose "Local install media (ISO or CDROM)"
3. Browse to your Windows 11 ISO
4. Set Memory: 16GB (or more)
5. Set CPUs: 8 cores (or more)
6. Create a disk: 100GB (or more)
7. Name it: "windows-11-dev"

### 3. Configure VM Before Starting

Before starting the VM, we need to configure it for GPU passthrough:

1. **Select the VM** → Right-click → "Open"
2. **Click the light bulb** ("Show virtual hardware details")
3. **Overview**:
   - Chipset: Q35
   - Firmware: UEFI (OVMF_CODE.fd)
4. **CPUs**:
   - Enable "Copy host CPU configuration"
   - Set topology: 8 cores, 1 socket, 1 thread (adjust for your CPU)
5. **Add Hardware** → PCI Host Device:
   - Select your NVIDIA RTX 3070 (0b:00.0)
6. **Add Hardware** → Input:
   - Type: Keyboard
   - Type: Mouse
   - Type: Tablet (for better mouse integration)

### 4. Add Looking Glass Shared Memory Device

The VM needs access to the shared memory device for Looking Glass:

1. **Edit VM XML**:
   - In virt-manager, go to VM → "Show the virtual machine console"
   - Menu: View → Details
   - Click "XML" tab
   - Add before `</devices>`:

```xml
<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>32</size>
</shmem>
```

2. **Apply and save**

### 5. Install Windows

1. Start the VM
2. Install Windows normally
3. Complete Windows setup

## Installing Looking Glass Guest Application

Inside your Windows VM:

### 1. Download Looking Glass Host Application

Visit: https://looking-glass.io/downloads

Download the latest Windows host application (looking-glass-host-setup.exe)

### 2. Install the Host Application

1. Run the installer
2. The host application will start automatically
3. Configure it to start on login:
   - Add to: `shell:startup` folder
   - Or: Install as a service (recommended for auto-start)

### 3. Install IVSHMEM Driver

1. Download the IVSHMEM driver from the Looking Glass website
2. Install the driver
3. Reboot Windows

## Using Looking Glass

### 1. Start the Windows VM

```bash
# In virt-manager, start your Windows VM
# Or via command line:
virsh start windows-11-dev
```

### 2. Launch Looking Glass Client

On your NixOS host:

```bash
looking-glass-client
```

The Windows desktop should appear in a window on your host!

### 3. Key Bindings

- **Scroll Lock** - Toggle input capture (keyboard/mouse)
- **Scroll Lock + F** - Toggle fullscreen
- **Scroll Lock + Q** - Quit client
- **Scroll Lock + M** - Toggle mouse capture

### 4. Optimal Settings

For best performance, run Looking Glass in fullscreen:

```bash
looking-glass-client -F
```

Or with additional options:

```bash
looking-glass-client \
  -F \                        # Fullscreen
  -K 60 \                     # 60 FPS capture
  -f /dev/kvmfr0              # KVMFR device
```

## Audio Setup

Looking Glass only handles video. For audio:

### Option 1: QEMU Audio (Recommended)

Add to your VM XML in the `<devices>` section:

```xml
<sound model='ich9'>
  <audio id='1'/>
</sound>
<audio id='1' type='pipewire'>
  <input mixingEngine='no'/>
  <output mixingEngine='no'/>
</audio>
```

### Option 2: Scream (Network Audio)

1. Install Scream receiver on host
2. Configure Scream driver in Windows VM
3. Audio streams over virtual network

## Performance Tuning

### CPU Pinning (Advanced)

For even better performance, pin VM CPUs to physical cores:

```bash
# Check your CPU topology
lscpu -e

# Edit VM XML to pin vCPUs to physical cores
```

### Huge Pages

Enable huge pages for better memory performance:

```nix
# Add to configuration.nix
boot.kernelParams = [ "hugepagesz=1G" "hugepages=16" ];
```

### Disk I/O

Use virtio-scsi for best disk performance:

- In virt-manager: Disk Bus = VirtIO

## Troubleshooting

### GPU Not Detected in VM

```bash
# Verify VFIO binding
lspci -nnk | grep -A 3 NVIDIA

# Should show vfio-pci as kernel driver
```

### NVIDIA Error 43

If Windows shows "Error 43" in Device Manager:

1. Edit VM XML, add in `<features>` section:

```xml
<hyperv>
  <vendor_id state='on' value='whatever'/>
</hyperv>
<kvm>
  <hidden state='on'/>
</kvm>
```

### Looking Glass Black Screen

1. Verify shared memory exists:

```bash
ls -la /dev/shm/looking-glass
```

2. Check Looking Glass host is running in Windows

3. Check permissions:

```bash
# Should show: -rw-rw---- ada qemu-libvirtd
ls -la /dev/shm/looking-glass
```

### Poor Performance

1. Enable CPU pinning
2. Use huge pages
3. Ensure VM is using VirtIO devices
4. Check host isn't under heavy load

## Backup and Snapshots

### Create a Snapshot

```bash
virsh snapshot-create-as windows-11-dev \
  --name "clean-install" \
  --description "Fresh Windows install"
```

### List Snapshots

```bash
virsh snapshot-list windows-11-dev
```

### Restore Snapshot

```bash
virsh snapshot-revert windows-11-dev clean-install
```

## Advanced: Multiple Monitors

For multi-monitor support with Looking Glass:

1. Increase shared memory size in `configuration.nix`:

```nix
programs.looking-glass.sharedMemorySize = 64;  # For 4K
```

2. Configure multiple displays in VM
3. Looking Glass will capture all displays

## Module Configuration Reference

### VFIO Options

```nix
virtualisation.vfio = {
  enable = true;
  gpuPciIds = [ "10de:2484" ];  # Your GPU PCI ID
  iommuType = "amd";            # or "intel"
};
```

### Windows VM Options

```nix
virtualisation.windows-vm = {
  enable = true;
  user = "ada";
  enableVirtManager = true;
};
```

### Looking Glass Options

```nix
programs.looking-glass = {
  enable = true;
  sharedMemorySize = 32;  # MB
  user = "ada";
};
```

## Resources

- [Looking Glass Documentation](https://looking-glass.io/docs/)
- [Arch Wiki: PCI Passthrough](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [NixOS Wiki: VFIO](https://nixos.wiki/wiki/PCI_passthrough)

## Safety Notes

- Always test configuration changes with `nixos-rebuild test` first
- Keep a rollback option available
- Document any hardware-specific tweaks
- Back up important VMs regularly

---

Happy VM'ing with near-native performance!
