#!/usr/bin/env bash
# Wrapper to filter out arguments unsupported by host compiler when invoked by nvcc
# It forwards all arguments except those starting with -compress-mode

REAL_COMPILER=/usr/bin/g++

# Find the real compiler if g++ not present
if [ ! -x "$REAL_COMPILER" ]; then
    REAL_COMPILER=$(command -v g++ || command -v c++ || command -v gcc)
fi

args=()
for a in "$@"; do
    case "$a" in
        -compress-mode*|--compress-mode*)
            # drop this flag
            continue
            ;;
        *)
            args+=("$a")
            ;;
    esac
done

exec "$REAL_COMPILER" "${args[@]}"
