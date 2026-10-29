#
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Xiaomi Mi A2 (jasmine_sprout): SDM660, eMMC, A/B with retrofit dynamic
# partitions, recovery-as-boot. Matches the LineageOS 23.2 (20261028) ROM:
# 4.19 kernel, EROFS, f2fs /data with FBE v2 + metadata encryption.
#

DEVICE_PATH := device/xiaomi/jasmine_sprout

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a73

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53

# Platform
TARGET_BOARD_PLATFORM := sdm660
TARGET_BOARD_PLATFORM_GPU := qcom-adreno512
QCOM_BOARD_PLATFORMS += sdm660

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sdm660
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

# A/B, recovery-as-boot (no recovery partition)
AB_OTA_UPDATER := true
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_NO_RECOVERY := true

# Kernel: the LineageOS 23.2 20261028 ROM kernel (4.19, commit 097a761ddc3e, see README),
# same config as the ROM: prebuilt/kernel.config.20261028
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.configfs=true androidboot.usbcontroller=a800000.dwc3 loop.max_part=7 printk.devkmsg=on kpti=off androidboot.boot_devices=soc/c0c4000.sdhci init.is_inline=1
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOT_HEADER_VERSION := 0
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/$(BOARD_KERNEL_IMAGE_NAME)
TARGET_KERNEL_ARCH := arm64

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 48318382080
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_USES_METADATA_PARTITION := true

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

# Retrofit dynamic partitions (same layout as the ROM)
BOARD_SUPER_PARTITION_GROUPS := jasmine_dynamic_partitions
BOARD_JASMINE_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product system_ext odm
$(foreach p, $(call to-upper, $(BOARD_JASMINE_DYNAMIC_PARTITIONS_PARTITION_LIST)), \
    $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := erofs) \
    $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 3221225472
BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 2147483648
BOARD_SUPER_PARTITION_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE))
BOARD_JASMINE_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304 )

BOARD_ROOT_EXTRA_SYMLINKS := \
    /vendor/dsp:/dsp \
    /vendor/firmware_mnt:/firmware \
    /vendor/bt_firmware:/bt_firmware \
    /mnt/vendor/persist:/persist

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_WIPE := $(DEVICE_PATH)/recovery/root/system/etc/recovery.wipe
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_USES_MKE2FS := true

# Anti-rollback hack (recovery only)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Decryption: FBE v2 (aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized) +
# metadata encryption (dm-default-key, keys in /metadata = logdump),
# QTI Keymaster 3.0 + Gatekeeper 1.0 + qseecomd from the ROM's vendor
BOARD_USES_QCOM_FBE_DECRYPTION := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2
TW_PREPARE_DATA_MEDIA_EARLY := true

# TWRP
TW_THEME := portrait_hdpi
TW_FRAMERATE := 60
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 4095
TW_DEFAULT_BRIGHTNESS := 1600
TW_NO_SCREEN_BLANK := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := en
TW_EXCLUDE_APEX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_USE_TOOLBOX := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_LPTOOLS := true
TW_INCLUDE_LPDUMP := true
TW_INCLUDE_NTFS_3G := true
TW_INCLUDE_FASTBOOTD := true
TW_HAS_EDL_MODE := true
TW_USE_LEGACY_BATTERY_SERVICES := true
TW_IGNORE_MISC_WIPE_DATA := true
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
TW_OVERRIDE_SYSTEM_PROPS := \
    "ro.build.date.utc;ro.build.product;ro.build.fingerprint=ro.system.build.fingerprint;ro.build.version.incremental;ro.product.device=ro.product.system.device;ro.product.model=ro.product.system.model;ro.product.name=ro.product.system.name"
TW_BACKUP_EXCLUSIONS := /data/fonts

# Debug (logcat, debuggerd)
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TARGET_RECOVERY_DEVICE_MODULES += debuggerd
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd

# Libraries the vendor blobs and services need in recovery
TARGET_RECOVERY_DEVICE_MODULES += \
    libion \
    libxml2 \
    android.hardware.boot@1.1

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libxml2.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.boot@1.1.so

# Vibration: the ROM's QTI AIDL vibrator HAL (built from vibrator/, see vibrator/SOURCE),
# driving the qti-haptics input device; started by init.recovery.qcom.rc
TW_SUPPORT_INPUT_AIDL_HAPTICS := true
TARGET_RECOVERY_DEVICE_MODULES += vendor.qti.hardware.vibrator.service
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_VENDOR_EXECUTABLES)/hw/vendor.qti.hardware.vibrator.service
RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/vendor.qti.hardware.vibrator.impl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/vendor.qti.hardware.vibratorOL.impl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/vendor.qti.hardware.vibratorSel.impl.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libqtivibratoreffect.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libqtivibratoreffectoffload.so \
    $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)/libexpat.so

# OrangeFox
OF_MAINTAINER := iamimmanuelraj
OF_SCREEN_H := 2160
OF_STATUS_H := 72
OF_STATUS_INDENT_LEFT := 48
OF_STATUS_INDENT_RIGHT := 48
OF_ALLOW_DISABLE_NAVBAR := 0
OF_QUICK_BACKUP_LIST := /boot;/data;
OF_USE_GREEN_LED := 1
OF_FLASHLIGHT_ENABLE := 1
OF_FL_PATH1 := /sys/class/leds/led:torch_0
OF_FL_PATH2 := /sys/class/leds/led:switch_0
OF_ENABLE_LPTOOLS := 1
OF_USE_DMCTL := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
OF_DEFAULT_KEYMASTER_VERSION := 3.0
OF_FORCE_PREBUILT_KERNEL := 1
