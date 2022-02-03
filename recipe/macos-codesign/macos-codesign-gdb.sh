#!/bin/bash

set -eu

# macOS specificities: codesign the GDB executable
# Generate code-signing certificate (needs `sudo`)
$CONDA_PREFIX/bin/macos-setup-codesign.sh
# unset a variable set by old versions of the clang activation script that prevents using `/usr/bin/codesign`
# (in case old builds of conda-forge compilers are installed in the installation environment)
# see https://github.com/conda-forge/clang-compiler-activation-feedstock/issues/18
# and https://github.com/conda-forge/clang-compiler-activation-feedstock/pull/19
unset CODESIGN_ALLOCATE
# Sign the GDB binary
/usr/bin/codesign --entitlements $CONDA_PREFIX/etc/gdb/gdb-entitlement.xml --force --sign gdb_codesign $CONDA_PREFIX/bin/gdb
