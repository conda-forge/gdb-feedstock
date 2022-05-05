Note: the macOS build now uses Azure as Travis usage for macOS was discontinued by conda-forge.
Most of the tests are skipped on macOS as GDB hangs at program startup on macOS 10.14+ the first time the debugee is ran (at least on CI).

This is probably a manifestation of this bug :
https://sourceware.org/bugzilla/show_bug.cgi?id=24069

Note also that building this recipe locally on macOS will fail in the test phase because the GDB executable will not be codesigned[2] (unless your user has passwordless `sudo` permissions).

[2]: https://sourceware.org/gdb/wiki/PermissionsDarwin#Sign_and_entitle_the_gdb_binary
