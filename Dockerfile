FROM nvidia/cuda:12.9.0-devel-ubuntu24.04

# Install build essentials and tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    clang \
    ninja-build \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set clang as the CUDA host compiler to avoid GCC incompatibilities
ENV CMAKE_CUDA_HOST_COMPILER=/usr/bin/clang

WORKDIR /workspace

# Copy the entire whisper-go repo
COPY . /workspace/

# Remove previous builds
RUN rm -rf whisper.cpp/build*

# Build the static libraries
RUN ./build.sh

# Verify build artifacts exist
RUN ls -lah whisper/internal/static-lfs/ && \
    ls -lah whisper/internal/static-lfs/linux_x86_64_cpu/ && \
    ls -lah whisper/internal/static-lfs/linux_x86_64_cuda/ || true

CMD ["bash"]
