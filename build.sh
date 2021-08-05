#!/bin/bash
BUILD_START=$(date +"%s")
tcdir=${HOME}/android/TOOLS/GCC

[ -d "out" ] && rm -rf out && mkdir -p out || mkdir -p out

[ -d $tcdir ] && \
echo "ARM64 TC Present." || \
echo "ARM64 TC Not Present. Downloading..." | \
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 $tcdir/los-4.9-64

[ -d $tcdir ] && \
echo "ARM32 TC Present." || \
echo "ARM32 TC Not Present. Downloading..." | \
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 $tcdir/los-4.9-32

make O=out ARCH=arm64 Lion_kernel_a37f_defconfig

PATH="$tcdir/los-4.9-64/bin:$tcdir/los-4.9-32/bin:${PATH}" \
make    O=out \
        ARCH=arm64 \
        CC="ccache $tcdir/los-4.9-64/bin/aarch64-linux-android-gcc" \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        CONFIG_DEBUG_SECTION_MISMATCH=y \
        -j$(nproc --all) || exit

cp out/arch/arm64/boot/Image anykernel3

cc anykernel3/dtbtool.c -o out/arch/arm64/boot/dts/dtbtool
( cd out/arch/arm64/boot/dts; ./dtbtool -v -s 2048 -o dt.img )
( cp out/arch/arm64/boot/dts/dt.img anykernel3 )

( cd anykernel3; zip -r ../out/Lion_KERNEL_by_Technical-Jigar`date +%d\.%m\.%Y_%H\:%M\:%S`.zip . -x 'LICENSE' 'README.md' 'dtbtool.c' )

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "\e[1;32m**** Enjoy New Shit!! ****\e[0m"
echo -e "\e[1;42mBuild completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\e[0m"