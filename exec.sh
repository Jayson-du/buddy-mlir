#!/usr/bin/bash

if [ ! -d "build" ]; then
    mkdir build
fi


cd build


if [ -f "CMakeCache.txt" ]; then
    rm CMakeCache.txt
fi

cmake -G Ninja .. \
    -DMLIR_DIR=/home/jayson/github/llvm-project/build/lib/cmake/mlir \
    -DLLVM_DIR=/home/jayson/github/llvm-project/build/lib/cmake/llvm \
    -DLLVM_SRC=/home/jayson/github/llvm-project/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG

ninja -j 16