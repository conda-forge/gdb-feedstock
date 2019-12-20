#!/usr/bin/env bash
set -ex

echo "CONDA_PY:$CONDA_PY"
export CONDA_PY=`python -c "import sys;print('%s%s'%sys.version_info[:2])"`
echo "CONDA_PY:$CONDA_PY"

gdb -batch -ex "run" -ex "py-bt" --args python "$RECIPE_DIR/testing/process_to_debug.py" | tee gdb_output
if [[ "$CONDA_PY" != "27" ]]; then
    grep "built-in method kill" gdb_output
fi
# Unfortunately some python packages do not have enough debug info for py-bt
if [[ "$CONDA_PY" != "36" && "$CONDA_PY" != "27" && "$CONDA_PY" != "38" ]]; then
    grep "line 3" gdb_output
    grep "process_to_debug.py" gdb_output
    grep 'os.kill(os.getpid(), signal.SIGSEGV)' gdb_output
else
    if grep "line 3" gdb_output; then
        echo "This test was expected to fail due to missing debug info in python"
        echo "As it passed the test should be re-enabled"
        exit 1
    fi
fi

grep "Program received signal SIGSEGV" gdb_output
