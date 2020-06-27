Note: the macOS build uses Travis because the conda-forge Travis config uses macOS 10.13,
and running an executable in GDB on macOS 10.14+ (including the Travis and Azure images) makes GDB hang about half the time. 

This is probably a manifestation of this bug :
https://sourceware.org/bugzilla/show_bug.cgi?id=24069

With the included patch, GDB shows
```
During startup program terminated with signal ?, Unknown signal
```

upon `run` about half the time instead of hanging.

Note also that building this recipe locally on macOS will fail in the test phase because the GDB executable will not be codesigned[2] (unless your user has passwordless `sudo` permissions).

[2]: https://sourceware.org/gdb/wiki/PermissionsDarwin#Sign_and_entitle_the_gdb_binary
