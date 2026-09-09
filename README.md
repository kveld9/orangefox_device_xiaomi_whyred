# OrangeFox Recovery Device Tree for Xiaomi Redmi Note 5 Pro (whyred)

This repository contains the recovery device tree to compile **OrangeFox Recovery R12.0** (based on `fox_12.1` minimal manifest) for the **Xiaomi Redmi Note 5 Pro / AI** (`whyred`).

---

## Downloads

Precompiled recovery packages and flashable ZIP files are available under the [Releases](../../releases) tab.

---

## Features & Highlights

- **Upstream OrangeFox R12.0 Engine:** Built on the official OrangeFox `fox_12.1` manifest (with `fox_14.1` experimental option).
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

### Prerequisites

Before proceeding, ensure the following requirements are met:
- **Device:** Xiaomi Redmi Note 5 Pro / AI (codename: `whyred`).
- **Unlocked Bootloader:** The device bootloader must be officially unlocked via the Xiaomi Mi Unlock tool.
- **Battery:** At least 50% battery level.
- **PC Tools:** Android SDK Platform-Tools (`adb` and `fastboot`) installed and accessible from the terminal.
- **USB Cable:** Micro-USB data cable.

> [!IMPORTANT]
> **Qualcomm `aboot` Fastboot Buffer Limit**:  
> The Xiaomi bootloader on *whyred* has a hardcoded RAM download buffer limit of **~36 MiB** in Fastboot mode. Because modern Android 12.1 recovery images exceed this threshold (~37.8 MiB), running `fastboot flash recovery OrangeFox-*.img` will fail with:  
> `FAILED (remote: 'Requested download size is more than max allowed')`.  
> Physical eMMC recovery partition capacity is **64 MiB**. Therefore, install using one of the two supported methods below.

### Method 1: From Existing Recovery (Recommended)

If your device already has TWRP or an older OrangeFox installed:

1. Download the latest `OrangeFox-*.zip` release from the [Releases](../../releases) section.
2. Boot into your current recovery (`Power + Volume Up`).
3. Connect your phone to your PC via USB.
4. Install via `adb sideload`:
   ```bash
   adb sideload OrangeFox-*.zip
   ```
   *Alternatively*, transfer the ZIP file to your internal storage, micro SD card, or `/tmp` and flash it directly from the recovery user interface.
5. The installer script will automatically flash the 64 MiB eMMC block and reboot into the new OrangeFox Recovery.

### Method 2: From Fastboot (Clean Slate / Rescue)

If your device currently has no functional custom recovery installed:

1. Obtain a legacy lightweight recovery image under 36 MiB (such as an official older OrangeFox R11.1 release or official TWRP 3.x image for whyred).
2. Boot your phone into Fastboot mode (`Power + Volume Down`) and connect it to your PC.
3. Flash the compact image to gain temporary recovery access:
   ```bash
   fastboot flash recovery legacy_compact_recovery.img
   fastboot reboot recovery
   ```
4. Once booted into temporary recovery, install the latest `OrangeFox-*.zip` following **Method 1** above. This writes directly to the 64 MiB eMMC partition without Fastboot buffer constraints.

> [!TIP]
> **Recommended Partition Backups**:  
> After booting into recovery, navigate to **Backup** and create a backup of **EFS** (`modemst1`, `modemst2`, `fsc`, `fsg`) and **Persist** to external storage (Micro SD card or USB-OTG). This protects your device IMEI, MAC addresses, and sensor calibrations against accidental loss.

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
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_DEVICE=whyred
export LC_ALL="C"
source build/envsetup.sh

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
