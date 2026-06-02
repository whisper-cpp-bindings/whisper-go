#!/usr/bin/bash
set -e

DIR="$(pwd)"
WHISPER_REPO="https://github.com/ggml-org/whisper.cpp.git"
STATIC_LFS_DIR="$DIR/whisper/internal/static-lfs"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to build whisper.cpp for a specific target
build_target() {
    local target_name=$1
    local os=$2
    local arch=$3
    local cmake_flags=$4
    local build_dir="whisper.cpp/build_${target_name}"

    export CMAKE_BUILD_PARALLEL_LEVEL=8
    
    echo -e "${BLUE}=== Building $target_name ($os/$arch) ===${NC}"
    
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # Configure and build
    cmake -DCMAKE_BUILD_TYPE=Release -DGGML_STATIC=ON $cmake_flags ..
    cmake --build . --config Release 
    
    cd "$DIR"
    
    # Extract headers and libraries
    mkdir -p "$STATIC_LFS_DIR/${target_name}"
    cp "whisper.cpp/include/whisper.h" "$STATIC_LFS_DIR/${target_name}/"
    cp "${build_dir}/src/libwhisper.a" "$STATIC_LFS_DIR/${target_name}/" || \
        cp "${build_dir}/src/Release/libwhisper.a" "$STATIC_LFS_DIR/${target_name}/" || \
        (echo "ERROR: libwhisper.a not found in $build_dir"; exit 1)
    
    echo -e "${GREEN}✓ Built $target_name${NC}"
}

# Clone or update whisper.cpp
if [ ! -d "whisper.cpp" ]; then
    echo -e "${BLUE}Cloning whisper.cpp...${NC}"
    git clone "$WHISPER_REPO"
else
    echo -e "${BLUE}Updating whisper.cpp...${NC}"
    cd whisper.cpp
    git pull origin master
    cd "$DIR"
fi

# Clean static-lfs directory
rm -rf "$STATIC_LFS_DIR"
mkdir -p "$STATIC_LFS_DIR"

echo -e "${BLUE}Building whisper.cpp for configured targets...${NC}"

# Detect host OS/ARCH to avoid attempting impossible native builds
HOST_UNAME=$(uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH=$(uname -m)

echo -e "Host detected: ${HOST_UNAME}/${HOST_ARCH}"

# Common safe CMake flags to produce position-independent static libs
COMMON_CMAKE_FLAGS="-DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON"

# Helper to merge common flags
add_common_flags() {
    if [ -z "$1" ]; then
        echo "$COMMON_CMAKE_FLAGS"
    else
        echo "$COMMON_CMAKE_FLAGS $1"
    fi
}

# Currently supported: Linux x86_64 (CPU and CUDA)
# Unsupported (placeholder stubs only): Linux ARM64, Darwin ARM64
# Only build linux_x86_64 targets on matching hosts.
if [[ "$HOST_UNAME" == "linux" && ("$HOST_ARCH" == "x86_64" || "$HOST_ARCH" == "amd64") ]]; then
    DO_LINUX_X86_64=1
    # CUDA builds enabled if nvcc is present
    if command -v nvcc >/dev/null 2>&1; then
        echo -e "${BLUE}nvcc found; CUDA builds enabled${NC}"
        DO_LINUX_X86_64_CUDA=1
    else
        echo -e "${BLUE}nvcc not found; CPU-only builds${NC}"
        DO_LINUX_X86_64_CUDA=0
    fi
else
    echo -e "${BLUE}Unsupported host: ${HOST_UNAME}/${HOST_ARCH}. Only Linux x86_64 is supported.${NC}"
    echo -e "${BLUE}Placeholder stubs exist for Linux ARM64 and Darwin ARM64 in whisper/internal/{{unsupported}}_*.go${NC}"
    exit 1
fi

# If clang is available, prefer it as the CUDA host compiler to avoid
# certain GCC flags being forwarded by nvcc that GCC rejects.
if command -v clang >/dev/null 2>&1; then
    CUDA_HOST_COMPILER=$(command -v clang)
    echo -e "${BLUE}clang found; will use $CUDA_HOST_COMPILER as CUDA host compiler${NC}"
    CUDA_COMPILER_FLAG="-DCMAKE_CUDA_HOST_COMPILER=$CUDA_HOST_COMPILER"
else
    CUDA_COMPILER_FLAG=""
fi

# If a local wrapper exists that strips problematic flags, prefer it
if [ -x "$DIR/tools/cuda_host_compiler_wrapper.sh" ]; then
    echo -e "${BLUE}Using local CUDA host compiler wrapper: $DIR/tools/cuda_host_compiler_wrapper.sh${NC}"
    CUDA_COMPILER_FLAG="-DCMAKE_CUDA_HOST_COMPILER=$DIR/tools/cuda_host_compiler_wrapper.sh"
fi

# Build selected targets

# Build linux_x86_64 targets (CPU always, CUDA if available)
if [ "$DO_LINUX_X86_64" = "1" ]; then
    build_target "linux_x86_64_cpu" "linux" "x86_64" "$(add_common_flags "")"
fi

if [ "$DO_LINUX_X86_64_CUDA" = "1" ]; then
    # Disable CUDA compression mode to avoid passing -compress-mode to host compiler
    build_target "linux_x86_64_cuda" "linux" "x86_64" "$(add_common_flags "-DGGML_CUDA=ON -DGGML_CUDA_CC=75;80;86;89;90 -DGGML_CUDA_COMPRESSION_MODE=none $CUDA_COMPILER_FLAG")"
fi

echo -e "${GREEN}=== Supported targets built (see above for details) ===${NC}"
echo -e "${GREEN}Libraries and headers are in: $STATIC_LFS_DIR${NC}"

