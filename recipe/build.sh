#!/bin/bash

# Download the right script to debug python processes
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
    --with-python \
    --with-system-gdbinit="$PREFIX/etc/gdbinit" || (cat config.log && exit 1)
make -j${CPU_COUNT}
make install
