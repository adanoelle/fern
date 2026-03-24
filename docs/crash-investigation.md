# Crash Investigation: Fan Ramp-Up + Hard Power-Off

## Problem

The system (Ryzen 5 5600X, RTX 3070, 125 GB RAM, NVMe, NixOS Zen kernel)
experiences fan ramp-up followed by instant power loss. No freeze, no kernel
panic, no warning -- just off. This happens during light workloads (browsing
Pinterest) as well as heavier tasks. The hardware is 3+ years old.

## Diagnosis

**Initial hypothesis: PSU degradation.**

| Evidence | Points to |
|----------|-----------|
| Instant power-off (no freeze/throttle/panic) | Power delivery failure |
| Happens during light loads | Failing capacitors can't handle transients |
| 3+ year old hardware | Electrolytic capacitor aging |
| RTX 3070 transient power spikes (even during video decode) | Trips degraded PSU |
| No MCE, PCIe, or thermal errors in journal | Not CPU/memory/bus fault |

**Updated after first check-in (2026-02-24): thermal issue is now the primary suspect.**

The first sensor readings revealed CPU idle temps of **71-89C** (Tctl/Tccd1),
which is 25-30C above the expected 35-50C idle range for a Ryzen 5 5600X.
The Gigabyte WMI motherboard sensors corroborate this (temp3 mirrors Tctl).
GPU is healthy at 38C / 10-16W idle. NVMe drives are cool (29-31C).

This strongly suggests **degraded thermal paste and/or clogged CPU heatsink**.
Under any sustained load, the CPU would hit 90C+ and trigger thermal shutdown,
which matches the crash pattern. The fan ramp-up before crashes is the CPU
cooler reacting to a temperature spike it can't contain.

PSU failure remains possible but is now a secondary concern -- the thermal
issue alone can explain the crashes and should be addressed first.

**Can't fully rule out yet:**
- PSU degradation (could be a compounding factor)
- Motherboard VRM failure under transient load
- Loose GPU 8-pin or 24-pin ATX power connector

## What Was Added

### Monitoring packages (`monitoring.nix`)

- **lm_sensors** -- `sensors` CLI for CPU, motherboard, VRM temps/voltages/fans
- **s-tui** -- terminal UI showing CPU temp, frequency, power, and built-in stress mode
- **stress-ng** -- CPU/memory stress testing tool
- **nct6775 kernel module** -- loaded for motherboard Super I/O chip; on this Gigabyte board the
  `gigabyte_wmi` virtual device provides 6 temp channels instead (temp3 tracks CPU)

### Sensor logging service

A systemd timer runs every 30 seconds, logging `sensors` and `nvidia-smi`
output to `/var/log/sensors.log`. The script calls `sync` after writing to
ensure data reaches disk before the next potential crash. The log auto-rotates
at 10 MB (old data kept in `sensors.log.old`).

### Zram swap

25% of RAM as compressed in-memory swap. Safety net against OOM edge cases
(unlikely with 125 GB but costs nothing).

## After a Crash: What to Check

After rebooting, run these commands:

```bash
# 1. Check the last sensor readings before the crash
tail -60 /var/log/sensors.log

# 2. Check systemd journal for any hardware errors
journalctl -b -1 -p err     # errors from previous boot (if journal survived)
journalctl -b -1 | grep -i -E "mce|thermal|gpu|nvidia|pcie"

# 3. Check current sensor readings (baseline)
sensors
nvidia-smi

# 4. Verify the logging service is running
systemctl status sensor-logger.timer
```

## How to Read the Sensor Log

Each entry looks like:

```
=== 2026-02-24T10:37:11-05:00 ===
iwlwifi_1-virtual-0          (WiFi adapter -- not useful)
temp1:        +30.0°C

k10temp-pci-00c3             (AMD CPU sensor -- primary)
Tctl:         +77.0°C        ← CPU temp (target: <50C idle, <85C load)
Tccd1:        +80.0°C        ← CCD (chiplet) temp

nvme-pci-0100                (NVMe drive)
Composite:    +30.9°C

acpitz-acpi-0                (ACPI -- often inaccurate, ignore)
temp1:        +16.8°C

gigabyte_wmi-virtual-0       (Motherboard sensors via Gigabyte WMI)
temp1:        +25.0°C        ← unknown (possibly chipset)
temp2:        +21.0°C        ← unknown
temp3:        +76.0°C        ← mirrors CPU Tctl
temp4:        +28.0°C        ← unknown (possibly VRM)
temp5:        +40.0°C        ← unknown
temp6:        +37.0°C        ← unknown

nvme-pci-0900                (second NVMe drive)
Composite:    +28.9°C

38, 15.77 W, 0 %, 0 %       ← GPU: temp(C), power(W), fan(%), util(%)
```

### Normal ranges

| Sensor | Idle | Load | Concerning |
|--------|------|------|------------|
| CPU (Tctl) | 35-50C | 65-85C | >90C |
| GPU temp | 30-45C | 65-80C | >85C |
| GPU power | 10-30W | 200-250W | >280W |
| VRM (SYSTIN) | 30-45C | 45-65C | >75C |
| Vcore | 0.8-1.1V | 1.1-1.4V | >1.45V or <0.7V |
| CPU fan | 600-900 RPM | 1000-1800 RPM | 0 RPM or erratic jumps |

### What to look for

- **Temps normal right before crash** → PSU failure (replace PSU)
- **CPU temp spiking to 90C+** → thermal paste degraded, clean heatsink and reapply
- **VRM temp spiking** → motherboard VRM cooling issue, improve case airflow
- **GPU power spiking to 280W+** → transient spike tripping PSU, replace PSU
- **Fan RPM drops to 0** → fan failure, replace fan
- **Vcore erratic** → motherboard VRM failure

## Physical Hardware Checks

Do these with the system powered off and unplugged:

1. **Dust** -- open the case, check CPU heatsink, GPU heatsink, PSU intake/exhaust,
   case fans. Compressed air to clean. Dust is the #1 cause of thermal issues on
   3+ year old systems.
2. **Reseat GPU power cables** -- unplug and replug the 8-pin connectors on both
   the GPU end and PSU end. Loose connections cause intermittent power drops.
3. **Reseat 24-pin ATX and 8-pin CPU power** -- same as above for the motherboard
   power connectors.
4. **Check PSU fan** -- with the system running, verify the PSU fan spins. A dead
   PSU fan means the PSU itself overheats.
5. **Note PSU wattage and brand** -- RTX 3070 + Ryzen 5600X needs a quality 550W+
   PSU. Budget or aging units can't handle the 3070's transient spikes.

## Decision Tree

```
After crash, check /var/log/sensors.log
│
├─ Temps normal (CPU <85C, GPU <80C, VRM <65C)
│  └─ PSU failure → Replace PSU (quality 650W+ recommended)
│
├─ CPU temp spiking (>90C)
│  ├─ Fan RPM normal → Thermal paste dried out → Reapply paste
│  └─ Fan RPM low/zero → Fan failure → Replace CPU cooler
│
├─ GPU temp spiking (>85C)
│  └─ Check GPU fans spinning → Clean GPU heatsink or replace thermal pads
│
├─ VRM temp spiking (>75C)
│  └─ Improve case airflow, check VRM heatsink contact
│
├─ Voltage erratic (Vcore swinging wildly)
│  └─ Motherboard VRM failure → May need motherboard replacement
│
└─ No log entries (timer wasn't running)
   └─ Check: systemctl status sensor-logger.timer
      Then verify manually: sensors && nvidia-smi
```

## Stress Testing (Optional)

If crashes don't reproduce quickly under normal use:

```bash
# CPU stress test -- watch temps in another terminal with s-tui
s-tui                         # has built-in stress mode (press 's')

# Or manual stress test
stress-ng --cpu 12 --timeout 300s

# GPU stress (install separately if needed)
# Use s-tui to monitor CPU while GPU is loaded

# Monitor in real time
watch -n 1 'sensors; echo; nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv'
```

If the system crashes with normal temperatures during stress testing, that
strongly confirms PSU failure.

## Baseline Readings (2026-02-24)

Captured immediately after `nixos-rebuild switch` and a few minutes of idle.

| Sensor | Reading | Expected Idle | Assessment |
|--------|---------|---------------|------------|
| CPU Tctl | 71-89C | 35-50C | **HIGH** -- 25-30C above normal |
| CPU Tccd1 | 70-81C | 35-50C | **HIGH** -- matches Tctl |
| GPU temp | 38C | 30-45C | Normal |
| GPU power | 10-16W | 10-30W | Normal |
| GPU fan | 0% | 0% (zero-RPM mode) | Normal |
| NVMe #1 | 30-35C | 25-40C | Normal |
| NVMe #2 | 29-36C | 25-40C | Normal |
| Gigabyte temp3 | 71-89C | -- | Mirrors CPU Tctl |
| Gigabyte temp4 | 28-29C | -- | Cool (possibly VRM) |
| Gigabyte temp5 | 40-42C | -- | Warm but not concerning |

**Conclusion**: CPU thermal interface is degraded. Everything else looks healthy.

## Action Items

- [ ] **Open case, inspect CPU heatsink for dust** -- clean with compressed air
- [ ] **Reapply thermal paste** -- original is 3+ years old and likely dried out
- [ ] **Verify CPU cooler mounting** -- all screws tight, even pressure
- [ ] **Re-check idle temps after repaste** -- target: Tctl <50C idle
- [ ] **Monitor for crashes after thermal fix** -- if crashes stop, thermal was the cause
- [ ] **If crashes persist with good temps** -- investigate PSU (see decision tree above)
- [ ] **Reseat GPU and motherboard power connectors** -- while the case is open
