#!/bin/bash

AndroidSystemVersion="24"
AndroidSdkDir="$SDK"
AndroidCmakeExe="$AndroidSdkDir/cmake/3.22.1/bin/cmake"
AndroidNinjaExe="$AndroidSdkDir/cmake/3.22.1/bin/ninja"
NdkBundle="$NDK"
ToolchainFile="$NdkBundle/build/cmake/android.toolchain.cmake"
ArchTarget="arm64-v8a"
ArchTriple="aarch64-linux-android"
LlvmTarget="AArch64"
BuildRootPath="android-build"

echo "Building LLVM for Android..."

rm -rf build
buildDir="$BuildRootPath/$ArchTarget"

if [ -d $buildDir ]
then
    echo "Removing existing Build directory : $buildDir ..."
    rm -rf "$buildDir"
fi

echo "Creating Build directory : $buildDir ..."
mkdir -p $buildDir
buildFullPath=$(realpath "./$buildDir")

$AndroidCmakeExe \
    -S llvm \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE="MinSizeRel" \
    -DLLVM_ENABLE_PROJECTS="lld" \
    -DCMAKE_INSTALL_PREFIX="$buildFullPath" \
    -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" \
    -DCMAKE_MAKE_PROGRAM="$AndroidNinjaExe" \
    -DCMAKE_C_FLAGS="-fvisibility=hidden -fdata-sections -ffunction-sections -Oz" \
    -DCMAKE_CXX_FLAGS="-fvisibility=hidden -fdata-sections -ffunction-sections -fno-exceptions -Oz" \
    -DANDROID_ABI="$ArchTarget" \
    -DANDROID_PLATFORM="android-$AndroidSystemVersion" \
    -DLLVM_HOST_TRIPLE="$ArchTriple" \
    -DLLVM_TARGETS_TO_BUILD="$LlvmTarget" \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_RUNTIMES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_TOOLS=ON \
    -DLLVM_INCLUDE_UTILS=OFF \
    \
    -DLLVM_BUILD_BENCHMARKS=OFF \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_BUILD_RUNTIME=OFF \
    -DLLVM_BUILD_RUNTIMES=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_BUILD_TOOLS=OFF \
    -DLLVM_BUILD_UTILS=OFF \
    \
    -DLLVM_BUILD_LLVM_DYLIB=OFF \
    \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_LTO="Thin" \
    
if [ $? -ne 0 ]; then
    echo "Project Generation failed for Architecture : $ArchTarget !"
    popd > /dev/null
    exit 1
fi

echo "Building LLVM for Architecture : $ArchTarget ..."
$AndroidCmakeExe --build build --target install -j4
if [ $? -ne 0 ]; then
    echo "Compilation failed for Architecture : $ArchTarget !"
    popd > /dev/null
    exit 1
fi
popd > /dev/null

echo "Successfully built LLVM for Architecture : $ArchTarget !"

echo "Successfully built LLVM for Android!"