#
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FDEVICE="whyred"

fox_get_target_device() {
  if echo "$BASH_SOURCE" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif set | grep BASH_ARGV | grep -w \"$FDEVICE\"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "${BASH_SOURCE[0]}" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "$0" | grep -q "$FDEVICE"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
    export FOX_BUILD_DEVICE="whyred"
    export FOX_VARIANT="FBE"
    export TARGET_DEVICE="whyred"
    export TW_DEFAULT_LANGUAGE="en"
    export LC_ALL="C"
    export ALLOW_MISSING_DEPENDENCIES=true

    # OrangeFox UI and Display
    export OF_SCREEN_H=2160
    export OF_STATUS_H=80
    export OF_STATUS_INDENT_LEFT=48
    export OF_STATUS_INDENT_RIGHT=48
    export OF_USE_GREEN_LED=1

    # Security & Decryption
    export OF_DEFAULT_KEYMASTER_VERSION=3.0
    export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
    export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
    export OF_PATCH_AVB20=1
    export OF_FBE_METADATA_MOUNT_IGNORE=1

    # Utilities & Binaries
    export FOX_USE_BASH_SHELL=1
    export FOX_ASH_IS_BASH=1
    export FOX_USE_NANO_EDITOR=1
    export FOX_USE_TAR_BINARY=1
    export FOX_USE_SED_BINARY=1
    export FOX_USE_XZ_UTILS=1
    export FOX_USE_ZIP_BINARY=1
    export FOX_REPLACE_BUSYBOX_PS=1
    export FOX_DELETE_AROMAFM=1
    export FOX_ENABLE_APP_MANAGER=1

    # Magisk & Patches
    export OF_USE_MAGISKBOOT=1
    export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
    export OF_USE_SYSTEM_FINGERPRINT=1
    export OF_USE_TWRP_SAR_DETECT=1

    # Backup & Recovery behavior
    export OF_QUICK_BACKUP_LIST="/boot;/data;/system_image;/vendor_image;"
    export OF_RUN_POST_FORMAT_PROCESS=1
    export OF_SUPPORT_ALL_BLOCK_OTA_UPDATES=1
    export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR=1
    export OF_DISABLE_MIUI_OTA_BY_DEFAULT=0
    export OF_NO_MIUI_PATCH_WARNING=1
    export OF_CHECK_OVERWRITE_ATTEMPTS=1

    # Kernel
    export OF_FORCE_PREBUILT_KERNEL=1

    # R11 settings
    export FOX_R11=1
else
    if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
        echo "I: This script requires bash. Not processing $FDEVICE $(basename $0)"
    fi
fi
