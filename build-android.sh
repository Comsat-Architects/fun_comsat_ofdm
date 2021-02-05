#!/bin/bash

# Recommended to configure PATH:
# LLVM_TOOLS_PATH=$HOME/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/
# PLATFORM_TOOLS_PATH=$HOME/Android/Sdk/platform-tools/
# export PATH=$PATH:$PLATFORM_TOOLS_PATH # Adds adb and fastboot tools to path
# export PATH=$PATH:$LLVM_TOOLS_PATH # Adds build tools to PATH

SYSROOT_LOC=$1

mkdir build || true

cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DANDROID=true \
    -DANDROID_ABI=29 \
    -DANDROID_ARCH=aarch64 \
    -DANDROID_SYSROOT=${SYSROOT_LOC} \
&& make
