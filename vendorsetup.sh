#
#	This file is part of the OrangeFox Recovery Project
#	Copyright (C) 2026 The OrangeFox Recovery Project
#
#	SPDX-License-Identifier: GPL-3.0-or-later
#
FDEVICE="jasmine_sprout"

fox_get_target_device() {
local chkdev=$(echo "$BASH_SOURCE" | grep -w \"$FDEVICE\")
   if [ -n "$chkdev" ]; then
      FOX_BUILD_DEVICE="$FDEVICE"
   else
      chkdev=$(set | grep BASH_ARGV | grep -w \"$FDEVICE\")
      [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
   fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	# A/B, recovery-as-boot, retrofit dynamic partitions (not Virtual A/B)
	export FOX_AB_DEVICE=1
	export FOX_VANILLA_BUILD=1
	export FOX_TARGET_DEVICES="jasmine_sprout,jasmine"
	export TARGET_DEVICE_ALT="jasmine"
	# Reflash OrangeFox to both slots after a ROM install
	export OF_RECOVERY_AB_FULL_REFLASH_RAMDISK=1

	# Tools and addons
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_NANO_EDITOR=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_GREP_BINARY=1
	export FOX_USE_DATE_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_ZSTD_BINARY=1
	export FOX_USE_LZ4_BINARY=1
	export FOX_USE_FSCK_EROFS_BINARY=1
	export FOX_USE_PATCHELF_BINARY=1
	export FOX_USE_UPDATED_MAGISKBOOT=1
	export FOX_ENABLE_APP_MANAGER=1
	export FOX_DELETE_AROMAFM=1
	export FOX_DELETE_INITD_ADDON=0
fi
