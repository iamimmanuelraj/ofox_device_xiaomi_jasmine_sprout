#!/bin/bash
# build-kernel.sh: build prebuilt/Image.gz-dtb from the kernel source, the same way
# LineageOS builds it for the ROM (vendor/lineage/build/tasks/kernel.mk): sdm660-perf_defconfig,
# then the sdm660, wayne and jasmine_sprout fragments merged one by one, clang + LLVM=1.
#
#   KERNEL_DIR=<kernel source> CLANG_DIR=<AOSP clang, e.g. clang-r563880c> [OUT_DIR=<build dir>] \
#     prebuilt/build-kernel.sh
#
# Output: $OUT_DIR/arch/arm64/boot/Image.gz-dtb and $OUT_DIR/.config
# Host tools (make, flex, bison, perl, openssl headers, lz4) come from PATH.
set -e
: "${KERNEL_DIR:?set KERNEL_DIR to the kernel source}"
: "${CLANG_DIR:?set CLANG_DIR to an AOSP clang directory (with bin/clang)}"
KERNEL_DIR=$(realpath "$KERNEL_DIR")
OUT_DIR=$(realpath -m "${OUT_DIR:-$KERNEL_DIR/out}")
export PATH=$CLANG_DIR/bin:$PATH LD_LIBRARY_PATH=$CLANG_DIR/lib64:$LD_LIBRARY_PATH

mk() {
  make -j$(nproc --all) -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- \
    CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 "$@"
}

C=$KERNEL_DIR/arch/arm64/configs/vendor
mkdir -p "$OUT_DIR"
cp "$C/sdm660-perf_defconfig" "$OUT_DIR/.config"
mk olddefconfig
for f in xiaomi/sdm660.config xiaomi/wayne.config xiaomi/jasmine_sprout.config; do
  ( cd "$OUT_DIR" && "$KERNEL_DIR/scripts/kconfig/merge_config.sh" -m -O "$OUT_DIR" "$OUT_DIR/.config" "$C/$f" )
  mk olddefconfig
done
mk Image.gz-dtb
ls -la "$OUT_DIR/arch/arm64/boot/Image.gz-dtb"
