//go:build linux && amd64 && !whispercuda

package internal

/*
#cgo CFLAGS: -I${SRCDIR}/static-lfs/linux_x86_64_cpu
#cgo LDFLAGS: -L${SRCDIR}/static-lfs/linux_x86_64_cpu -lwhisper -lm
*/
import "C"

const (
	Platform = "Linux x86_64 CPU"
)
