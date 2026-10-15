# Command & Automation Reference Guide

This document provides a concise and comprehensive technical reference of all automation scripts, commands, and flags across the **OrangeFox Recovery** device tree and its companion **LineageOS 21 (whyred)** build ecosystem.

---

## 1. OrangeFox Recovery Workflow & Automation

### 1.1 Cloud Compilation via GitHub Actions CLI (`gh`)

Run directly from within the `orangefox_device_xiaomi_whyred` repository:

```bash
gh workflow run build.yml [FLAGS]
```

#### Supported Flags (`-f` inputs)
| Flag / Input | Permitted Values | Default | Description |
|---|---|---|---|
| `-f MANIFEST_BRANCH="<ver>"` | `12.1`, `14.1` | `12.1` | OrangeFox minimal manifest branch. `12.1` is recommended stable; `14.1` is experimental. |
| `-f BUILD_TYPE="<type>"` | `Unofficial`, `Beta`, `Release` | `Unofficial` | OrangeFox build tag and naming qualifier applied to generated ZIP and image artifacts. |

#### Example
```bash
# Trigger standard build with default options
gh workflow run build.yml

# Trigger build on experimental 14.1 manifest with Beta qualifier
gh workflow run build.yml -f MANIFEST_BRANCH="14.1" -f BUILD_TYPE="Beta"
```

**Actions executed automatically by the cloud workflow:**
1. Provisions an Ubuntu 22.04 virtual runner and installs build dependencies (`aria2`, `python3`, `rsync`).
2. Sinks disk space and sets up 12 GB virtual swap storage.
3. Clones `https://gitlab.com/OrangeFox/sync.git` and runs `./orangefox_sync.sh` to download/sync minimal source tree.
4. Integrates `device/xiaomi/whyred` into the build tree.
5. Sinks environmental flags (`FOX_BUILD_DEVICE=whyred`, `ALLOW_MISSING_DEPENDENCIES=true`) and compiles `mka adbd recoveryimage`.
6. Produces `OrangeFox-*.img` and `OrangeFox-*.zip`, generates SHA-256 and MD5 checksums, compiles git changelog, and creates a tagged GitHub Release automatically.

---

### 1.2 Telegram Bot Automation (`Release Watcher`)

The Telegram bot linked to the `release-watcher` Cloudflare Worker and GitHub repository dispatches cloud builds on demand:

| Command | Arguments | Description |
|---|---|---|
| `/build_fox` | None | Dispatches `build.yml` with `MANIFEST_BRANCH=12.1` and `BUILD_TYPE=Unofficial`. |
| `/build_fox 14.1` | `14.1` | Dispatches `build.yml` targeting experimental `fox_14.1` branch. |
| `/check` | None | Forces immediate check of upstream repositories and monitored APKs. |
| `/list` | None | Lists monitored repositories, latest tracked commit hashes, and versions. |

---

### 1.3 Local OrangeFox Recovery Compilation

When compiling locally on a Linux workstation:

```bash
# 1. Sync official OrangeFox manifest
mkdir -p ~/OrangeFox/fox_12.1 && cd ~/OrangeFox
git clone https://gitlab.com/OrangeFox/sync.git -b master
cd sync
./orangefox_sync.sh --branch 12.1 --path ~/OrangeFox/fox_12.1

# 2. Place device tree
cd ~/OrangeFox/fox_12.1
git clone https://github.com/kveld9/orangefox_device_xiaomi_whyred.git device/xiaomi/whyred

# 3. Setup environment and build
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_DEVICE=whyred
export LC_ALL="C"
source build/envsetup.sh
lunch twrp_whyred-eng
mka adbd recoveryimage
```

---

## 2. Cross-Ecosystem Synchronization (LineageOS → OrangeFox)

Because OrangeFox does not compile the Linux kernel from source and instead requires a prebuilt binary (`prebuilt/Image.gz-dtb`), the `sync_fox_kernel.sh` script bridges the LineageOS kernel build artifacts directly into the recovery device tree.

Location: `../lineageos-whyred/sync_fox_kernel.sh`

```bash
./sync_fox_kernel.sh [ACTION]
```

### Supported Actions
| Action | Description |
|---|---|
| `check` *(default)* | Compares SHA-256 hashes of compiled LineageOS stock kernel (`Image.gz-dtb-stock`), local OrangeFox prebuilt, and remote `origin/main`. Reports if synchronization is pending. |
| `--sync` | Copies kernel from LineageOS output directory to `orangefox.../prebuilt/Image.gz-dtb`, creates an atomic commit in the OrangeFox repo, and pushes to `origin main`. |
| `--build` | Executes `--sync` (if changes exist) and then triggers cloud compilation via `gh workflow run build.yml`. |
| `--trigger-only` | Bypasses local kernel checks and directly triggers OrangeFox cloud compilation on GitHub Actions. |
| `--help`, `-h` | Displays help message and parameter syntax. |

### Environment Variables
* `DEVICE`: Target codename (default: `whyred`).
* `FOX_DIR`: Path to the OrangeFox device tree repository (default: `../orangefox_device_xiaomi_whyred`).

---

## 3. LineageOS ROM & Kernel Pipeline

The companion LineageOS 21 workspace (`lineageos-whyred`) provides orchestrators for updating upstream sources, building custom kernel variants, and publishing ROM releases.

### 3.1 Upstream Synchronization & Build: `update_whyred.sh`

Coordinates upstream updates from LineageOS, merges security updates, and optionally triggers builds.

```bash
./update_whyred.sh [ACTION]
```

| Action | Description |
|---|---|
| `sync` *(default)* | Inspects upstream status via `check_updates.sh`, runs `repo sync`, merges platform and device branches, and verifies sister kernel branch parity without compiling. |
| `--build` | Runs the `sync` routine and then compiles the clean LineageOS ROM (`mka bacon`). |
| `--all` | Runs full end-to-end pipeline: syncs upstream, compiles ROM, builds all 3 kernel variants (Stock, KernelSU Next, ReSukiSU), exports stock kernel to OrangeFox, and publishes GitHub Release. |

---

### 3.2 Compilation & Release Orchestrator: `build_whyred.sh`

Compiles the ROM, standalone kernel boot images, and manages release publication.

```bash
./build_whyred.sh [ACTION]
```

| Action | Description |
|---|---|
| `--build` | Compiles clean LineageOS ROM package (`mka bacon`) using stock kernel. Preserves `Image.gz-dtb-stock`. |
| `--build-ksu` | Compiles standalone boot image integrated with KernelSU Next and SuSFS (`boot-ksu.img`). |
| `--build-resukisu` | Compiles standalone boot image integrated with ReSukiSU and SuSFS (`boot-resukisu.img`). |
| `--publish` | Forwards execution to `publish_release.sh` to upload existing build artifacts to GitHub. |
| `--all` | Compiles ROM, triggers `sync_fox_kernel.sh --build`, compiles KSU and ReSukiSU boot images, and automatically publishes GitHub release. |

---

### 3.3 Upstream Monitor: `check_updates.sh`

Inspects upstream LineageOS repositories for monthly Android Security Bulletins (ASB) and commits.

```bash
./check_updates.sh [OPTIONS]
```

| Option | Description |
|---|---|
| `--verbose` | Displays individual commit subjects and author details for pending updates. |
| `--no-fetch` | Evaluates pending commits against cached tracking refs without querying remote servers. |
| `--notify` | Triggers a desktop notification via `notify-send` when updates are detected. |

---

### 3.4 GitHub Release Publisher: `publish_release.sh`

Packages ROM ZIPs, standalone boot images, generates multi-repo changelogs, computes SHA-256 hashes, and publishes releases.

```bash
./publish_release.sh [FLAGS]
```

| Flag | Description |
|---|---|
| `--yes` | Auto-confirms publication prompts for non-interactive automated pipelines. |
| `--dry-run` | Generates changelogs, metadata, and calculates hashes without creating or modifying GitHub Releases. |
| `--tag=<name>` | Overrides the target release tag name (default: `v21.0-YYYYMMDD-whyred`). |
| `--kernel-only` | Publishes only standalone kernel boot images instead of the full ROM release. |
| `--kernel-release=<variant>` | Targets a specific kernel variant (`stock`, `ksu`, `resukisu`, or `all`). |
