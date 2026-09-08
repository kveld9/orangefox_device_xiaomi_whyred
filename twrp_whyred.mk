#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 The TWRP Open Source Project
# Copyright (C) 2026 The OrangeFox Recovery Project
#

# Release name
# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Device identifier
PRODUCT_DEVICE := whyred
PRODUCT_NAME := twrp_whyred
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi Note 5 Pro
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.secure=1 \
    ro.adb.secure=0 \
    ro.allow.mock.location=0 \
    ro.hardware.keystore=sdm660 \
    ro.hardware.gatekeeper=sdm660
