#!/bin/bash

# Download the right script to debug python processes.
# This is an useful script provided by CPython project to help debugging
# crashes in Python processes.
# See https://devguide.python.org/gdb for some
# examples on how to use it.
#
# Normally someone needs to download this script manually and properly
# setup gdb to load it (if you are lucky gdb was compiled with python
# support).
#
# Providing this in conda-forge's gdb makes the experience much smoother,
# avoiding all the hassles someone can find when trying to configure gdb
# for that.
curl -SL https://raw.githubusercontent.com/python/cpython/$PY_VER/Tools/gdb/libpython.py \
    > "$SP_DIR/libpython.py"

# Install a gdbinit file that will be automatically loaded
mkdir -p "$PREFIX/etc"
echo '
python
import gdb
import sys
import os
def setup_python(event):
    import libpython
gdb.events.new_objfile.connect(setup_python)
end
' >> "$PREFIX/etc/gdbinit"

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
# Setting /usr/lib/debug as debug dir makes it possible to debug the system's
# python on most Linux distributions

mkdir build
cd build

$SRC_DIR/configure \
    --prefix="$PREFIX" \
    --with-separate-debug-dir="$PREFIX/lib/debug:/usr/lib/debug" \
    --with-python=${PYTHON} \
    --with-system-gdbinit="$PREFIX/etc/gdbinit" || (cat config.log && exit 1)
make -j${CPU_COUNT}  VERBOSE=1
make install
