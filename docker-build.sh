#!/usr/bin/env bash
# Docker build script for reproducible whisper.cpp static library builds
# Usage: ./docker-build.sh [--extract-to PATH]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRACT_TO=""
IMAGE_TAG="whisper-go:ubuntu24.04-cuda12.0"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --extract-to)
            EXTRACT_TO="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--extract-to PATH]"
            exit 1
            ;;
    esac
done

echo "Building Docker image: $IMAGE_TAG"
docker build -t "$IMAGE_TAG" "$SCRIPT_DIR"

if [ -n "$EXTRACT_TO" ]; then
    echo "Extracting artifacts to: $EXTRACT_TO"
    mkdir -p "$EXTRACT_TO"
    
    # Create temporary container to extract artifacts
    CONTAINER_ID=$(docker create "$IMAGE_TAG")
    docker cp "$CONTAINER_ID:/workspace/whisper/internal/static-lfs/." "$EXTRACT_TO/"
    docker rm "$CONTAINER_ID"
    
    echo "Artifacts extracted:"
    ls -lah "$EXTRACT_TO"
else
    echo "To extract build artifacts, run: $0 --extract-to /path/to/extract"
fi
