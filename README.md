# OrangeFox for Xiaomi Mi A2 (jasmine_sprout)

OrangeFox Recovery `fox_16.0` (R12.0, Android 16 base) device tree for the Xiaomi Mi A2.

| | |
|---|---|
| SoC | Qualcomm SDM660, eMMC |
| Partitions | A/B, retrofit dynamic partitions (super on `system` + `vendor`), recovery-as-boot (no recovery partition) |
| File systems | EROFS (system, vendor, product, system_ext, odm), f2fs `/data`, ext4 `/metadata` |
| Encryption | FBE v2 + metadata encryption (QTI Keymaster 3.0, Gatekeeper 1.0) |
| Kernel | 4.19, prebuilt (see [Kernel](#kernel)) |

## Status

Tested (RAM boot with `fastboot boot`, LineageOS 24 on the phone):

- Boot, adb, logcat
- Decryption: metadata, and user data with the lock screen PIN
- system/vendor/product/system_ext/odm mounted from super (EROFS), `/data` (f2fs)
- Vibration (QTI haptics)
- Notification LED: lit while charging

Not tested yet: flashlight, brightness, MTP, OTG, backup/restore, flashing ROM zips, permanent install.

Made for ROMs with the layout of LineageOS 23.2/24 for jasmine_sprout (EROFS, retrofit super, FBE v2 + metadata encryption). Other ROMs with the same layout should work. Old ROMs without dynamic partitions (stock Android 10) are not supported.

## How to use

1. Download `OrangeFox-R12.0-Unofficial-jasmine.img` from the release.
2. Reboot the phone to the bootloader: `adb reboot bootloader`, or hold Power + Volume down while it is off.
3. Boot OrangeFox from the PC (nothing is written to the phone):

   ```bash
   fastboot boot OrangeFox-R12.0-Unofficial-jasmine.img
   ```

4. Enter your lock screen PIN/password when asked, to decrypt your files.
5. When you are done: Reboot > System.

Permanent install is not supported yet. The Mi A2 has no recovery partition: the recovery lives in the boot image together with the ROM, and installing OrangeFox there is not tested. Do not flash the `.img` to the `boot` partition: the ROM boots from that partition, and this image only contains the recovery.

## Reporting problems

Open an issue at https://github.com/iamimmanuelraj/AOSP/issues with:

- your ROM and its version
- what you did and what happened
- the logs, while OrangeFox is still running:

  ```bash
  adb pull /tmp/recovery.log
  adb shell dmesg > dmesg.txt
  adb logcat -d > logcat.txt
  ```

## Building

Needs a Linux machine set up for Android builds, Git, [Repo](https://source.android.com/source/using-repo.html), about 100 GB of disk and 16 GB of RAM (more with swap is better: the build analysis alone uses close to 20 GB).

### 1. Get the OrangeFox source

The OrangeFox manifest (https://gitlab.com/OrangeFox/Manifest, branch `fox_16.0`), shallow:

```bash
mkdir orangefox_16
cd orangefox_16
repo init -u https://gitlab.com/OrangeFox/Manifest.git -b fox_16.0 --depth=1
repo sync
```

### 2. Add this device tree

Clone it into the source tree (a symlink is not picked up by the build):

```bash
git clone -b fox_16.0 https://github.com/iamimmanuelraj/ofox_device_xiaomi_jasmine_sprout device/xiaomi/jasmine_sprout
```

Everything else the device needs is in this tree: the decryption blobs from the ROM's vendor (`recovery/root`, listed with SHA-1 in `recovery-blobs.txt`), bootctrl (`bootctrl/SOURCE`), the vibrator HAL source (`vibrator/SOURCE`) and the kernel (`prebuilt/`).

### 3. Build

Use Bash:

```bash
export FOX_BUILD_DEVICE=jasmine_sprout
source build/envsetup.sh
lunch twrp_jasmine_sprout-bp2a-eng
mka adbd bootimage
```

The Mi A2 is recovery-as-boot, so the target is `bootimage`, not `recoveryimage`.

### 4. Output

In `out/target/product/jasmine_sprout/`:

| File | What it is |
|---|---|
| `OrangeFox-R12.0-Unofficial-jasmine.img` | The image for `fastboot boot` (same as `boot.img`) |
| `OrangeFox-R12.0-Unofficial-jasmine.zip` | OrangeFox installer zip (contains the same image as `recovery.img`) |
| `*.md5` | Checksums |

## Kernel

`prebuilt/Image.gz-dtb` is the kernel of the LineageOS 23.2 20261028 ROM, so the recovery has the same drivers and file system support as the ROM (EROFS, f2fs, inline encryption, dm-default-key).

| | |
|---|---|
| Source | https://github.com/iamimmanuelraj/android_kernel_xiaomi_sdm660 |
| Commit | `097a761ddc3e` "ARM64: configs: jasmine_sprout: Enable the LED timer trigger" (on branches `lineage-23.2` and `lineage-24.0`) |
| Version | `4.19.325-cip136-st20-perf-g097a761ddc3e` |
| Config | `prebuilt/kernel.config.20261028` |
| Toolchain | AOSP clang `r563880c` (clang 21) |

### Building the kernel

```bash
git clone https://github.com/iamimmanuelraj/android_kernel_xiaomi_sdm660 kernel
git -C kernel checkout 097a761ddc3e

mkdir clang-r563880c
curl -L https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android16-qpr2-release/clang-r563880c.tar.gz \
  | tar -xz -C clang-r563880c

KERNEL_DIR=kernel CLANG_DIR=$PWD/clang-r563880c OUT_DIR=kernel-out \
  device/xiaomi/jasmine_sprout/prebuilt/build-kernel.sh
```

`prebuilt/build-kernel.sh` builds it the way LineageOS does for the ROM: `sdm660-perf_defconfig` plus the `sdm660`, `wayne` and `jasmine_sprout` fragments. The host tools (make, flex, bison, perl, OpenSSL headers, lz4) come from your system.

Output: `kernel-out/arch/arm64/boot/Image.gz-dtb` (and `kernel-out/.config`). To use it, copy it over `prebuilt/Image.gz-dtb` and build OrangeFox again. A kernel from another commit or with another config can miss what the ROM needs (for example EROFS or inline encryption), so check its `.config` against `prebuilt/kernel.config.20261028`.

## Credits

- [OrangeFox Recovery Project](https://gitlab.com/OrangeFox) and [TeamWin (TWRP)](https://github.com/TeamWin)
- [LineageOS](https://github.com/LineageOS) (bootctrl, vibrator HAL)
- xiaoleGun's TWRP 12.1 tree for jasmine_sprout, used as a reference
