#!/bin/bash


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

pushd gdb/testsuite
make  site.exp
echo  "set gdb_test_timeout 120" >> site.exp
runtest
popd

make install
