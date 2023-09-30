#!/bin/bash

AndroidSystemVersion="24"
AndroidSdkDir="$SDK"
AndroidCmakeExe="$AndroidSdkDir/cmake/3.22.1/bin/cmake"
AndroidNinjaExe="$AndroidSdkDir/cmake/3.22.1/bin/ninja"
NdkBundle="$NDK"
ToolchainFile="$NdkBundle/build/cmake/android.toolchain.cmake"
ArchTargets=( "arm64-v8a" )
ArchTriples=( "aarch64-linux-android" )
LlvmTargets=( "AArch64" )
BuildRootPath="android-build"

echo "Building LLVM for Android..."
ArchsLength=${#ArchTargets[*]}
for (( archCounter=0; archCounter < $ArchsLength; archCounter++ ))
do
    rm -rf build
    archTarget=${ArchTargets[$archCounter]}
    archTriple=${ArchTriples[$archCounter]}
    llvmTarget=${LlvmTargets[$archCounter]}
    buildDir="$BuildRootPath/$archTarget"
    
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
        -DANDROID_ABI="$archTarget" \
        -DANDROID_PLATFORM="$AndroidSystemVersion" \
        -DLLVM_HOST_TRIPLE="$archTriple" \
        -DLLVM_TARGETS_TO_BUILD="$llvmTarget" \
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
        
    if [ $? -ne 0 ]; then
        echo "Project Generation failed for Architecture : $archTarget !"
        popd > /dev/null
        exit 1
    fi
    
    echo "Building LLVM for Architecture : $archTarget ..."
    $AndroidCmakeExe --build build --target install -j4
    if [ $? -ne 0 ]; then
        echo "Compilation failed for Architecture : $archTarget !"
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null
    
    echo "Successfully built LLVM for Architecture : $archTarget !"
done
echo "Successfully built LLVM for Android!"