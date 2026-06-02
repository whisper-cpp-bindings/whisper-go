# whisper-go Build & Deployment

## Supported Targets

Currently, the project supports:
- **Linux x86_64 CPU** (`linux_x86_64_cpu`)
- **Linux x86_64 CUDA** (`linux_x86_64_cuda`)

Placeholder stubs exist for future support:
- Linux ARM64 (CPU & CUDA) — `//go:build ignore` in Go files
- Darwin ARM64 (CPU & Metal) — `//go:build ignore` in Go files

## Local Build (Linux x86_64 only)

Prerequisites:
- `cmake` ≥ 3.18
- `gcc` & `g++` or `clang` & `clang++`
- `nvcc` (CUDA Toolkit) for GPU build
- `git`

```bash
./build.sh
```

Outputs:
- `whisper/internal/static-lfs/linux_x86_64_cpu/` — CPU static library & header
- `whisper/internal/static-lfs/linux_x86_64_cuda/` — CUDA static library & header (if nvcc available)

## Docker Build (Reproducible)

Build using Ubuntu 24.04 + CUDA 12.0 in a Docker container:

```bash
chmod +x docker-build.sh
./docker-build.sh --extract-to ./build-artifacts
```

This:
1. Builds the Docker image with Ubuntu 24.04 + CUDA 12.0
2. Compiles whisper.cpp for both targets
3. Extracts artifacts to `./build-artifacts/`

## GitHub Actions

Automatic builds on push/PR to `main` or `develop`:
- Builds both CPU and CUDA targets
- Verifies Go fmt and vet
- Uploads artifacts to GitHub releases

Trigger manually:
```bash
gh workflow run build.yml
```

## Go Integration

Supported build modes:

```bash
# CPU only (default)
go build ./...

# CPU + CUDA
go build -tags whispercuda ./...
```

Unsupported builds (will fail gracefully):
```bash
# Darwin/ARM64 not yet supported
GOOS=darwin GOARCH=arm64 go build ./... # ERROR: no matching Go files
```

## Architecture Notes

- **Build tags**: `linux_cpu_x86_64.go`, `linux_cuda_x86_64.go` are active
- **Placeholders** (ignored): `*_arm64.go`, `darwin_*.go` files have `//go:build ignore`
- **Future**: When support is added, replace `ignore` with proper build tags and populate `static-lfs/` directories

## Troubleshooting

**CUDA compilation fails with macro errors:**
- Docker build is recommended (handles all toolchain compatibility)
- Or install gcc version compatible with your CUDA toolkit

**nvcc not found:**
- CPU build only: `./build.sh` will build `linux_x86_64_cpu` and skip CUDA
- To enable CUDA: install CUDA Toolkit or use Docker build

**Docker build fails:**
- Ensure Docker and Docker Buildx are installed
- Check disk space (build can require ~20GB)
