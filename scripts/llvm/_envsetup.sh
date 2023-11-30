#!/bin/sh -e

__export_envvar "LLVM" "$TOOLCHAINS_DIR/llvm"
__append_path "$LLVM_INSTALL/bin"
__append_path "$CMAKE_INSTALL/bin"
__append_path "$NINJA_INSTALL/bin"
export CLANG="$LLVM_INSTALL/bin/clang"
export LLVM_VERSION="llvmorg-12.0.1"
