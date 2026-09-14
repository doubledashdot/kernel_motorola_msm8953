#!/usr/bin/env bash

# this script assumes this:
#          sudo apt-get update -yqq
#          sudo apt-get install -yqq bc bison device-tree-compiler flex \
#            gcc-aarch64-linux-gnu libssl-dev lz4 make python3

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- vendor/moto8953-perf_defconfig
          ./scripts/kconfig/merge_config.sh -m .config \
            arch/arm64/configs/vendor/motorola/sanders.config

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig


make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
            -j$(nproc) dtbs Image.gz modules

git clone --depth 1 --branch lineage-18.1 \
            https://github.com/LineageOS/android_system_tools_dtbtool.git dtbtool

 gcc -O2 -o dtbToolLineage dtbtool/dtbtool.c
          ./dtbToolLineage -o dt.img -s 2048 -p "$PWD/scripts/dtc/" \
            arch/arm64/boot/dts/vendor/qcom/
          test "$(od -An -tx1 -N4 dt.img | tr -d ' \n')" = "51434454"

rm -rf ok
mkdir ok

cp dt.img ok/dt.img
cp arch/arm64/boot/Image.gz ok/Image.gz
ls ok
