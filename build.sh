#!/usr/bin/bash
DIR="$(pwd)"
git clone https://github.com/ggml-org/whisper.cpp.git
cd whisper.cpp/bindings/go
make whisper
cd $DIR
rm static-lfs/*
cp whisper.cpp/include/whisper.h static-lfs/
cp whisper.cpp/build_go/src/libwhisper.a static-lfs/

