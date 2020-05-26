Note: the macOS build uses Travis because the conda-forge Travis config uses macOS 10.13,
and running an executable in GDB under SSH on macOS 10.14+ (including the Travis and Azure images) makes GDB hang. 

This is probably related to the fact that some system security settings need to be adjusted
for the debugger to be able to run unimpeded (I'm guessing that it's waiting for a graphical
authentication popup window somehow.)

[This person][1] suggests using an entitlement file with additional entitlements compared to the [official recommendation][2], so it could be worth investigating adding these entitlements when the 10.13 Travis image is decomissioned.

Note also that building this recipe locally on macOS will fail in the test phase because the GDB executable will not be codesigned (unless your user has passwordless `sudo` permissions).

[1]: https://timnash.co.uk/getting-gdb-to-semi-reliably-work-on-mojave-macos/
[2]: https://sourceware.org/gdb/wiki/PermissionsDarwin#Sign_and_entitle_the_gdb_binary
