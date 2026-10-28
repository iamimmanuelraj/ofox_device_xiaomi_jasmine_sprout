#
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/xiaomi/jasmine_sprout

# A/B (retrofit dynamic partitions, recovery-as-boot)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    system \
    vendor \
    product \
    system_ext \
    odm

PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_RETROFIT_DYNAMIC_PARTITIONS := true
PRODUCT_SHIPPING_API_LEVEL := 27

# Recovery-only build: the prebuilt kernel carries no VINTF kernel metadata
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    $(LOCAL_PATH)/bootctrl

# Boot control (same QTI AIDL HAL as the ROM, see bootctrl/SOURCE)
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti.recovery

# A/B updates and sideload
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot@1.1-impl-mock

# Decryption (device/qcom/twrp-common)
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fuse.passthrough.enable=true

