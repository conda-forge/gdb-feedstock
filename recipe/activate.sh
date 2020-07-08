#!/bin/bash

# Check gdb is codesigned
if  ! codesign -vv $CONDA_PREFIX/bin/gdb > /dev/null 2>&1; then
  echo "Warning: GDB is not codesigned."
  cat $CONDA_PREFIX/etc/gdb/.messages.txt
fi
