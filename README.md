# OrangeFox Recovery Device Tree for Xiaomi Redmi Note 5 Pro (whyred)

This repository contains the recovery device tree to compile **OrangeFox Recovery** (based on `fox_12.1` / `fox_11.0` minimal manifest) for the **Xiaomi Redmi Note 5 Pro / AI** (`whyred`).

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
| **Partition Scheme** | Non-dynamic (dedicated `/recovery` partition, A-only) |
| **Encryption Support** | File-Based Encryption (FBE) via Keymaster 3.0 & Gatekeeper 1.0 |

---

## Features & Highlights

- **OrangeFox Manifest Compatibility:** Designed for `fox_12.1` and `fox_11.0` trees.
- **FBE Decryption:** Full support for File-Based Encryption on Android 11, 12, 13, and 14 ROMs.
- **Prebuilt Tested Kernel:** Includes stable kernel `Image.gz-dtb` configured for whyred display, touchscreen, and cryptographic hardware access.
- **Automated CI/CD:** Built-in GitHub Actions workflow to build release flashable `.zip` and `.img` artifacts in the cloud without local environment overhead.

---

## Building via GitHub Actions (Recommended)

1. Go to the **Actions** tab of this repository.
2. Select **OrangeFox - Build Recovery**.
3. Click **Run workflow**:
   - Choose `MANIFEST_BRANCH` (`12.1` recommended).
   - Choose `BUILD_TYPE` (`Unofficial`, `Beta`, or `Release`).
4. Wait for the workflow to complete.
5. Download artifacts from GitHub Actions or the created GitHub Release.

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
