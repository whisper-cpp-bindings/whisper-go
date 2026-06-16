//go:build linux && amd64 && whispercuda

package internal

/*
#cgo CFLAGS: -I${SRCDIR}/static-lfs/linux_x86_64_cuda
#cgo LDFLAGS: -L${SRCDIR}/static-lfs/linux_x86_64_cuda -lwhisper -lcuda -lcudart -lm
*/
import "C"

const (
	platform = "Linux x86_64 CUDA"
)
