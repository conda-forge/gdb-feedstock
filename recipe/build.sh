#!/bin/bash

set -eu

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

# macOS specificities
if [[ $target_platform == "osx-64" ]]; then
  # prevent a VERSION file being confused by clang++ with $CONDA_PREFIX/include/c++/v1/version
  mv intl/VERSION intl/VERSION.txt
  # install needed scripts to generate a codesigning certificate and sign the gdb executable
  cp $RECIPE_DIR/macos-codesign/macos-setup-codesign.sh $PREFIX/bin/
  cp $RECIPE_DIR/macos-codesign/macos-codesign-gdb.sh   $PREFIX/bin/
  cp $RECIPE_DIR/macos-codesign/macos-show-caveats.sh   $PREFIX/bin/
  # copy the entitlement file
  mkdir -p $PREFIX/etc/gdb
  cp $RECIPE_DIR/macos-codesign/gdb-entitlement.xml $PREFIX/etc/gdb/
  # add libiconv and expat flags
  libiconv_flag="--with-libiconv-prefix=$PREFIX"
  expat_flag="--with-libexpat-prefix=$PREFIX"
  # Setup the necessary GDB startup command for macOS Sierra and later
  echo "set startup-with-shell off" >> "$PREFIX/etc/gdbinit"
  # Copy the activate script to the installation prefix
  mkdir -p "${PREFIX}/etc/conda/activate.d"
  cp $RECIPE_DIR/activate.sh "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
fi

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
# Setting /usr/lib/debug as debug dir makes it possible to debug the system's
# python on most Linux distributions

mkdir build
cd build

$SRC_DIR/configure \
    --prefix="$PREFIX" \
    --with-separate-debug-dir="$PREFIX/lib/debug:/usr/lib/debug" \
    --with-python=${PYTHON} \
    --with-python \
    --with-system-gdbinit="$PREFIX/etc/gdbinit" \
    ${libiconv_flag:-} \
    ${expat_flag:-} \
    || (cat config.log && exit 1)
make -j${CPU_COUNT} VERBOSE=1
make install

