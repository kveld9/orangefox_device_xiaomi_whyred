# OrangeFox Recovery Device Tree for Xiaomi Redmi Note 5 Pro (whyred)

This repository contains the recovery device tree to compile **OrangeFox Recovery R12.0** (based on `fox_12.1` minimal manifest) for the **Xiaomi Redmi Note 5 Pro / AI** (`whyred`).

---

## Device Specifications

| Feature | Specification |
| :--- | :--- |
| **Chipset** | Qualcomm SDM660 Snapdragon 660 |
| **CPU** | Octa-core (4x2.2 GHz Kryo 260 Gold & 4x1.8 GHz Kryo 260 Silver) |
| **GPU** | Adreno 512 / 509 |
| **Display** | 2160 x 1080 pixels, 18:9 ratio (~403 ppi) |
| **Storage** | 32 GB / 64 GB eMMC 5.1 |
| **Battery** | Li-Po 4000 mAh |
| **Architecture** | ARM64 (`arm64-v8a`) |
| **Partition Scheme** | Non-dynamic, legacy eMMC (dedicated `/recovery` partition, 64 MiB, A-only) |
| **Encryption Support** | File-Based Encryption (FBE) via Keymaster 3.0 & Gatekeeper 1.0 |

---

## Features & Highlights

- **Upstream OrangeFox R12.0 Engine:** Built on the latest official OrangeFox `fox_12.1` manifest (with `fox_14.1` experimental option).
- **FBE Decryption Support:** Tailored for modern Android 11, 12, 13, and 14 ROMs (including LineageOS 21).
- **Hardware Validated:**
  - Full touchscreen response across panel variants (Tianma, EBBG, Shenchao).
  - Accurate battery capacity and charging status via native `hwservicemanager` and `android.hardware.health@2.1-service`.
  - Flashlight, vibration, display backlight, and RTC clock fix.
  - Backup creation, partition formatting (`mke2fs`), wipe, and ADB / MTP transfers.
- **Prebuilt Stable Kernel:** Prebuilt 4.19 kernel (`Image.gz-dtb`) matching device display panels, touchscreen bus, and hardware crypto engines.
- **Automated CI/CD Releases:** Automated GitHub Actions build workflow generating flashable ZIPs, standalone recovery images, `SHA256SUM.txt`, `MD5SUM.txt`, and release commit changelogs.

---

## Installation & Flashing Guide

> [!IMPORTANT]
> **Qualcomm `aboot` Fastboot Buffer Limit**:  
> The Xiaomi bootloader on *whyred* has a hardcoded RAM download buffer limit of **~36 MiB** in Fastboot mode. Because modern Android 12.1 recovery images exceed this threshold (~37.8 MiB), running `fastboot flash recovery OrangeFox-*.img` will fail with:  
> `FAILED (remote: 'Requested download size is more than max allowed')`.  
> Physical eMMC recovery partition capacity is **64 MiB**. Therefore, install using one of the two supported methods below.

### Method 1: From Existing Recovery (Recommended)

If your device already has TWRP or an older OrangeFox installed:

1. Boot into your current recovery (`Power + Volume Up`).
2. Connect your phone to your PC.
3. Install via `adb sideload`:
   ```bash
   adb sideload OrangeFox-R12.0_FBE-Unofficial-whyred.zip
   ```
   *Alternatively*, transfer the ZIP to the internal storage or `/tmp` and flash it from the recovery GUI.
4. The installer script will automatically flash the 64 MiB eMMC block and reboot into the new OrangeFox Recovery.

### Method 2: From Fastboot (Clean Slate / Rescue)

If your device has no working recovery installed:

1. Flash a compact recovery image (< 36 MiB, such as OrangeFox R11.1 base) via Fastboot:
   ```bash
   fastboot flash recovery recovery_compact.img
   fastboot reboot recovery
   ```
2. Once booted into recovery, flash the latest `OrangeFox-R12.0_FBE-Unofficial-whyred.zip` following **Method 1**.

> [!TIP]
> **AMD Ryzen USB 3.x Fastboot Communication**:  
> On AMD Ryzen systems (B450, B550, X570), Qualcomm bootloaders may hang on `usbfs_start_wait_urb` when connected to chipset USB 3.2 ports. If Fastboot commands freeze or disconnect, plug your phone into a **USB 2.0 port** (such as the PC front panel headers), a **USB 2.0 hub**, or native CPU-routed USB ports.

---

## Building via GitHub Actions (Recommended)

1. Navigate to the **Actions** tab of this repository.
2. Select **OrangeFox - Build Recovery**.
3. Click **Run workflow**:
   - Choose `MANIFEST_BRANCH` (`12.1` recommended; `14.1` experimental).
   - Choose `BUILD_TYPE` (`Unofficial`, `Beta`, or `Release`).
4. Wait for the workflow to complete.
5. Download artifacts from the created GitHub Release, which includes:
   - Recovery flashable ZIP (`OrangeFox-*.zip`)
   - Direct recovery image (`OrangeFox-*.img`)
   - `SHA256SUM.txt` and `MD5SUM.txt` checksum files
   - In-line commit history / changelog in the release description

---

## Building Locally

### 1. Requirements
- 64-bit Linux installation (Ubuntu 20.04 / 22.04 recommended).
- At least 45 GB of free storage for `fox_12.1`.
- Android build dependencies and `python2` / `python3`.

### 2. Sync Manifest
```bash
mkdir -p ~/OrangeFox/fox_12.1
cd ~/OrangeFox
git clone https://gitlab.com/OrangeFox/sync.git -b master
cd sync
./orangefox_sync.sh --branch 12.1 --path ~/OrangeFox/fox_12.1
```

### 3. Clone Device Tree
```bash
cd ~/OrangeFox/fox_12.1
git clone https://github.com/kveld9/orangefox_device_xiaomi_whyred.git device/xiaomi/whyred
```

### 4. Build
```bash
cd ~/OrangeFox/fox_12.1
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_DEVICE=whyred
export LC_ALL="C"

lunch twrp_whyred-eng
mka adbd recoveryimage
```

The output recovery images and flashable zip files will be located at:
```text
out/target/product/whyred/OrangeFox-*.img
out/target/product/whyred/OrangeFox-*.zip
```

---

## Credits & Thanks
- [OrangeFox Recovery Project](https://gitlab.com/OrangeFox)
- [TeamWin Recovery Project (TWRP)](https://github.com/TeamWin)
- Xiaomi & the whyred developer community
